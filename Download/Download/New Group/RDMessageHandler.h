//
//  RDSpeedManager.h
//  Download2
//
//  Created by IOS3 on 2019/1/30.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RDMessageHandler : NSObject


+ (instancetype)sharedInstance;


- (void)downloadDataChangedWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                               didWriteData:(int64_t)bytesWritten
                          totalBytesWritten:(int64_t)totalBytesWritten
                  totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@property (nonatomic, copy) void(^shouldChangeProgressAndSpeed)(NSString *speed, double progress);

@end

NS_ASSUME_NONNULL_END
