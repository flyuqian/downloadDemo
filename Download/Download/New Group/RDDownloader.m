//
//  RDDownloader.m
//  Download2
//
//  Created by IOS3 on 2019/1/29.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "RDDownloader.h"
#import "RDItem.h"
#import "RDMessageHandler.h"
#import "RDResumeHandler.h"



@interface RDDownloader () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDictionary *itemTasks;

@property (nonatomic, strong) NSMutableArray *downloadingItems;
@property (nonatomic, strong) NSMutableArray *finishedItems;


@end

@implementation RDDownloader


#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialDownloader];
    }
    return self;
}
- (void)initialDownloader {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession
                             sessionWithConfiguration:config delegate:self delegateQueue:NSOperationQueue.mainQueue];
    self.session = session;
    self.itemTasks = NSDictionary.dictionary;
    self.downloadingItems = NSMutableArray.array;
    self.finishedItems = NSMutableArray.array;
    self.maxActivity = 3; // 默认值
}



- (void)addDownloadingItems:(NSArray<RDItem *> *)items {
    for (RDItem *item in items) {
        item.state = RDItemStateWait;
        if (![self.downloadingItems containsObject:item]) {
            [self.downloadingItems addObject:item];
        }
    }
}


- (void)checkDownloadNext {
    NSInteger downloadingCount = self.itemTasks.count;
    if (downloadingCount < self.maxActivity) {
        for (RDItem *item in self.downloadingItems) {
            if (item.state == RDItemStateWait) {
                [self startDownloadWith:item];
                [self checkDownloadNext];
            }
        }
    }
}


- (void)startDownloadWith:(RDItem *)item {
    if (item.state == RDItemStateLoading) {
        return;
    }
    NSURLSessionDownloadTask *task;
    if (item.resumeData) {
        task = [self.session downloadTaskWithResumeData:item.resumeData];
    }
    else {
        task = [self.session downloadTaskWithURL:[NSURL URLWithString:item.urlString]];
    }
    item.task = task;
    item.state = RDItemStateLoading;
    [self itemTasksAddItem:item task:task];
    if (![self.downloadingItems containsObject:item]) {
        [self.downloadingItems addObject:item];
    }
    [task resume];
}


#pragma mark - 外部操作
/// 开始下载
- (void)startWith:(RDItem *)item {
    NSInteger downloadingCount = self.itemTasks.count;
    if (downloadingCount < self.maxActivity) {
        [self startDownloadWith:item];
    }
    else {
        item.state = RDItemStateWait;
        if (![self.downloadingItems containsObject:item]) {
            [self.downloadingItems addObject:item];
        }
    }
}
/// 暂停下载
- (void)suspendWith:(RDItem *)item {
    if (item.state != RDItemStateLoading) {
        return;
    }
    [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([item isEqual:obj]) {
            NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)key;
            [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                item.resumeData = resumeData;
            }];
        }
    }];
    item.state = RDItemStateSuspend;
    [self itemTasksRemoveItem:item];
    [self itemToFinish:item];
    [self checkDownloadNext];
}
/// 取消下载
- (void)cancelWith:(RDItem *)item {
    [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([item isEqual:obj]) {
            NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)key;
            [task cancel];
        }
    }];
    item.state = RDItemStateCancel;
    item.resumeData = nil;
    [self itemTasksRemoveItem:item];
    [self itemToFinish:item];
    [self checkDownloadNext];
}

/// 暂停全部
- (void)suspendAll {

    NSMutableArray *needToFinish = NSMutableArray.array;
    for (RDItem *item in self.downloadingItems) {
        if (item.state == RDItemStateLoading) {
            [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([item isEqual:obj]) {
                    NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)key;
                    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        item.resumeData = resumeData;
                    }];
                }
            }];
            [self itemTasksRemoveItem:item];
        }
        item.state = RDItemStateSuspend;
        [needToFinish addObject:item];
    }
    for (RDItem *item in needToFinish) {
        [self itemToFinish:item];
    }
}
/// 取消全部
- (void)cancelAll {
    
    NSMutableArray *needToFinish = NSMutableArray.array;
    for (RDItem *item in self.downloadingItems) {
        if (item.state == RDItemStateLoading) {
            [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([item isEqual:obj]) {
                    NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)key;
                    [task cancel];
                }
            }];
            [self itemTasksRemoveItem:item];
            
        }
        item.resumeData = nil;
        item.state = RDItemStateCancel;
        [needToFinish addObject:item];
    }
    for (RDItem *item in needToFinish) {
        [self itemToFinish:item];
    }
}
/// 全部开始下载
- (void)downloadAll {
    NSMutableArray *needToLoadings = NSMutableArray.array;
    for (RDItem *item in self.finishedItems) {
        if (item.state != RDItemStateSuccess) {
            item.state = RDItemStateWait;
            [needToLoadings addObject:item];
        }
    }
    for (RDItem *item in self.downloadingItems) {
        if (item.state != RDItemStateLoading) {
            item.state = RDItemStateWait;
        }
    }
    for (RDItem *item in needToLoadings) {
        [self itemToLoading:item];
    }
    [self checkDownloadNext];
}


#pragma mark - NSURLSessionDownloadDelegate
// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    RDItem *item = [self.itemTasks objectForKey:downloadTask];
    if (!item) {
        return;
    }
    item.resumeData = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:[item downloadSavePath]] error:&error];
    [fileManager removeItemAtURL:location error:nil];
    if (error) {
        item.state = RDItemStateFailure;
    }
    else {
        item.state = RDItemStateSuccess;
        item.resumeData = nil;
    }
    [self itemTasksRemoveItem:item];
    [self itemToFinish:item];
    [self checkDownloadNext];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    __block RDItem *item = [self.itemTasks objectForKey:downloadTask];
    RDMessageHandler *manager = RDMessageHandler.sharedInstance;
    [manager downloadDataChangedWithDownloadTask:downloadTask
                                    didWriteData:bytesWritten
                               totalBytesWritten:totalBytesWritten
                       totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    manager.shouldChangeProgressAndSpeed = ^(NSString * _Nonnull speed, double progress) {
        item.progress = progress;
        item.speed = speed;
    };
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    RDItem *item = [self.itemTasks objectForKey:task];
    if (item.state == RDItemStateLoading) {
        item.state = RDItemStateFailure;
        [self itemTasksRemoveItem:item];
        [self itemToFinish:item];
    }
}







#pragma mark - 对 itemTasks 字典的增删操作
- (void)itemTasksAddItem:(RDItem *)item task:(NSURLSessionTask *)task {
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![item isEqual:obj]) {
            [mdict setObject:obj forKey:key];
        }
    }];
    [mdict setObject:item forKey:task];
    self.itemTasks = mdict.copy;
}
- (void)itemTasksRemoveItem:(RDItem *)item {
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    [self.itemTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![item isEqual:obj]) {
            [mdict setObject:obj forKey:key];
        }
    }];
    self.itemTasks = mdict.copy;
}

- (void)itemToLoading:(RDItem *)item {
    if (!item) {
        return;
    }
    [self.finishedItems removeObject:item];
    if (![self.downloadingItems containsObject:item]) {
        [self.downloadingItems addObject:item];
    }
}
- (void)itemToFinish:(RDItem *)item {
    if (!item) {
        return;
    }
    [self.downloadingItems removeObject:item];
    if (![self.finishedItems containsObject:item]) {
        [self.finishedItems addObject:item];
    }
}


@end
