//
//  RDItem.m
//  Download2
//
//  Created by IOS3 on 2019/1/29.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "RDItem.h"





@interface RDItem ()
{
    NSData *_resumeData;
}

@property (nonatomic, copy) NSString *savePath;
@property (nonatomic, copy) NSString *defaultSavePath;
@property (nonatomic, copy) NSString *resumePath;

@end


@implementation RDItem
@dynamic resumeData;



//- (void)checkState {
//    if (self.state != RDItemStateNone) {
//        return;
//    }
//    if ([NSFileManager.defaultManager fileExistsAtPath:[self downloadSavePath]]) {
//        self.state = RDItemStateSuccess;
//        return;
//    }
//    if (self.resumeData) {
//        self.state = RDItemStateSuspend;
//    }
//    else {
//        self.state = RDItemStateNone;
//    }
//}



- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = RDItemStateNone;
    }
    return self;
}
+ (instancetype)itemWithUrl:(NSString *)urlString {
    id instance = [[self class] new];
    if ([instance isKindOfClass:RDItem.class]) {
        RDItem *item = (RDItem *)instance;
        item.urlString = urlString;
    }
    return instance;
}



//- (void)setUrlString:(NSString *)urlString {
//    _urlString = urlString;
//    [self checkState];
//}



// downloadPath
- (NSString *)downloadSavePath {
    return self.savePath ? self.savePath : self.defaultSavePath;
}



// resumeData
- (NSData *)resumeData {
    if (!_resumeData) {
        _resumeData = [NSData dataWithContentsOfFile:self.resumePath];
    }
    return _resumeData;
}
- (void)setResumeData:(NSData *)resumeData {
    _resumeData = resumeData;
    if (resumeData == nil) {
        [NSFileManager.defaultManager removeItemAtPath:self.resumePath error:nil];
        return;
    }
    if ([NSFileManager.defaultManager fileExistsAtPath:self.resumePath]) {
        [NSFileManager.defaultManager removeItemAtPath:self.resumePath error:nil];
    }
    [_resumeData writeToFile:self.resumePath atomically:YES];
}





//
- (void)setProgress:(double)progress {
    _progress = progress;
    if ([self.delegate respondsToSelector:@selector(item:progressChanged:)]) {
        [self.delegate item:self progressChanged:progress];
    }
}
- (void)setSpeed:(NSString *)speed {
    _speed = speed;
    if ([self.delegate respondsToSelector:@selector(item:speedChanged:)]) {
        [self.delegate item:self speedChanged:speed];
    }
}

- (void)setState:(RDItemState)state {
    _state = state;
    if ([self.delegate respondsToSelector:@selector(item:stateChanged:)]) {
        [self.delegate item:self stateChanged:state];
    }
}




// 默认存储路径
- (NSString *)defaultSavePath {
    if (!_defaultSavePath) {
        NSAssert(self.urlString, @"urlString is not null");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fileName = [self.urlString componentsSeparatedByString:@"/"].lastObject;
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        NSString *dir = @"download_default";
        NSString *defaultDir = [cachePath stringByAppendingPathComponent:dir];
        if (![fileManager fileExistsAtPath:defaultDir]) {
            [fileManager createDirectoryAtPath:defaultDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _defaultSavePath = [defaultDir stringByAppendingPathComponent:fileName];
    }
    
    return _defaultSavePath;
}
// resumeData缓存路径
- (NSString *)resumePath {
    if (!_resumePath) {
        NSAssert(self.urlString, @"urlString is not null");
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fileNameWithType = [self.urlString componentsSeparatedByString:@"/"].lastObject;
        NSString *fileName = [fileNameWithType componentsSeparatedByString:@"."].firstObject;
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        NSString *dir = @"resumeData";
        NSString *defaultDir = [cachePath stringByAppendingPathComponent:dir];
        if (![fileManager fileExistsAtPath:defaultDir]) {
            [fileManager createDirectoryAtPath:defaultDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _resumePath = [defaultDir stringByAppendingPathComponent:fileName];;
    }
    return _resumePath;
}



- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:RDItem.class]) {
        return NO;
    }
    RDItem *item = (RDItem *)object;
    return item.urlString == self.urlString;
}
- (NSUInteger)hash {
    return [self.urlString hash];
}
@end
