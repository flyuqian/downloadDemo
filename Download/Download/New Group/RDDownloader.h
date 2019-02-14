//
//  RDDownloader.h
//  Download2
//
//  Created by IOS3 on 2019/1/29.
//  Copyright © 2019 IOS3. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RDItem;
@interface RDDownloader : NSObject


/// 同时下载个数, 默认3个
@property (nonatomic, assign) NSInteger maxActivity;

- (void)addDownloadingItems:(NSArray<RDItem *> *)items;

/// 开始下载
- (void)startWith:(RDItem *)item;
/// 暂停下载
- (void)suspendWith:(RDItem *)item;
/// 取消下载
- (void)cancelWith:(RDItem *)item;

/// 暂停全部
- (void)suspendAll;
/// 取消全部
- (void)cancelAll;
/// 全部开始下载
- (void)downloadAll;


@end

NS_ASSUME_NONNULL_END
