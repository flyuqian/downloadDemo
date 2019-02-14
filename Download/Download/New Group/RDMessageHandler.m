//
//  RDSpeedManager.m
//  Download2
//
//  Created by IOS3 on 2019/1/30.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "RDMessageHandler.h"



NSString *const didWriteDataKey = @"download_calculate_key_didWriteData_key";
NSString *const timeIntervalKey = @"download_calculate_key_timeInterval_key";


@interface RDMessageHandler ()

@property (nonatomic, strong) NSMutableDictionary *info;

@end

@implementation RDMessageHandler


+ (instancetype)sharedInstance {
    static RDMessageHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        instance.info = NSMutableDictionary.dictionary;
    });
    return instance;
}





- (void)downloadDataChangedWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                               didWriteData:(int64_t)bytesWritten
                          totalBytesWritten:(int64_t)totalBytesWritten
                  totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    // 下载完
    if (totalBytesWritten == totalBytesExpectedToWrite) {
        if (self.shouldChangeProgressAndSpeed) {
            self.shouldChangeProgressAndSpeed(@"", 1.0);
        }
        [self.info removeObjectForKey:downloadTask];
        return;
    }
    
    
    
    // 取出缓存的下载信息
    NSTimeInterval now = NSDate.new.timeIntervalSince1970;
    NSMutableDictionary *downloadInfo = [self.info objectForKey:downloadTask];
    
    // 没有缓存过下载信息
    if (!downloadInfo) {
        NSMutableDictionary *dict = @{
                                      timeIntervalKey : [NSNumber numberWithDouble:now],
                                      didWriteDataKey : [NSNumber numberWithLongLong:bytesWritten],
                                      }.mutableCopy;
        
        double progress = [self calculateProgressWithTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        NSString *speed = [self calculateSpeedWithWriteData:bytesWritten];
        if (self.shouldChangeProgressAndSpeed) {
            self.shouldChangeProgressAndSpeed(speed, progress);
        }
        [self.info setObject:dict forKey:downloadTask];
        return;
    }
    
    NSTimeInterval last = [[downloadInfo objectForKey:timeIntervalKey] doubleValue];
    int64_t writen = [[downloadInfo objectForKey:didWriteDataKey] longLongValue];
    writen = writen + bytesWritten;

    // 拿到下载信息, 但是距离上次输出不足1s
    if ((now - last) < 1.0) {
        [downloadInfo setValue:[NSNumber numberWithLongLong:writen] forKey:didWriteDataKey];
        [self.info setObject:downloadInfo forKey:downloadTask];
        return;
    }
    
    double progress = [self calculateProgressWithTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSString *speed = [self calculateSpeedWithWriteData:writen];
    if (self.shouldChangeProgressAndSpeed) {
        self.shouldChangeProgressAndSpeed(speed, progress);
    }
    [downloadInfo setValue:[NSNumber numberWithDouble:now] forKey:timeIntervalKey];
    [downloadInfo setValue:[NSNumber numberWithLongLong:0] forKey:didWriteDataKey];
    [self.info setObject:downloadInfo forKey:downloadTask];

}



- (double)calculateProgressWithTotalBytesWritten:(int64_t)totalBytesWritten
                       totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    return progress;
}

- (NSString *)calculateSpeedWithWriteData:(int64_t)bytesWritten {
    NSString *speed;
    if (bytesWritten > pow(1024, 3)) {
        speed = [NSString stringWithFormat:@"%.2f GB/秒", (float)bytesWritten / (float)pow(1024, 3)];
    }
    else if (bytesWritten > pow(1024, 2)) {
        speed = [NSString stringWithFormat:@"%.2f MB/秒", (float)bytesWritten / (float)pow(1024, 2)];
    }
    else if (bytesWritten > 1024) {
        speed = [NSString stringWithFormat:@"%.2f KB/秒", (float)bytesWritten / (float)1024];
    }
    else {
        speed = [NSString stringWithFormat:@"%lld B/秒", bytesWritten] ;
    }
    return speed;
}


@end
