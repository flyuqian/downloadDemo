//
//  RDItem.h
//  Item2
//
//  Created by IOS3 on 2019/1/29.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, RDItemState) {
    RDItemStateNone,
    RDItemStateWait,
    RDItemStateLoading,
    RDItemStateSuspend,
    RDItemStateFailure,
    RDItemStateSuccess,
    RDItemStateCancel,
};

@class RDItem;
@protocol RDItemDelegate <NSObject>

- (void)item:(RDItem *)item stateChanged:(RDItemState)state;
- (void)item:(RDItem *)item progressChanged:(double)progress;
- (void)item:(RDItem *)item speedChanged:(NSString *)speed;

@end


@interface RDItem : NSObject

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, weak) id<RDItemDelegate> delegate;

@property (nonatomic, assign) RDItemState state;
@property (nonatomic, assign) double progress;
@property (nonatomic, copy) NSString *speed;

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

+ (instancetype)itemWithUrl:(NSString *)urlString;

- (NSString *)downloadSavePath;


@end

NS_ASSUME_NONNULL_END
