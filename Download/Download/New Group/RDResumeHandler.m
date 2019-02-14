//
//  RDResumeManager.m
//  Download2
//
//  Created by IOS3 on 2019/1/30.
//  Copyright © 2019 IOS3. All rights reserved.
//



#import "RDResumeHandler.h"


static NSString *const NSURLSessionResumeInfoVersion = @"NSURLSessionResumeInfoVersion";
static NSString *const NSURLSessionResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
static NSString *const NSURLSessionResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
static NSString *const NSURLSessionResumeByteRange = @"NSURLSessionResumeByteRange";
static NSString *const NSURLSessionResumeInfoTempFileName = @"NSURLSessionResumeInfoTempFileName";
static NSString *const NSURLSessionResumeInfoLocalPath = @"NSURLSessionResumeInfoLocalPath";
static NSString *const NSURLSessionResumeBytesReceived = @"NSURLSessionResumeBytesReceived";



@interface RDResumeHandler ()


@property (nonatomic, strong) NSMutableDictionary *resumeDatas;
@property (nonatomic, copy) NSString *resumePath;

@end

@implementation RDResumeHandler



#pragma mark -  处理 data
+ (NSData *)handleResumeData:(NSData *)data {
    if (@available(iOS 11.3, *)) {
        return data;
    }
    else if (@available(iOS 11.0, *)) {
        return [self deleteResumeByteRange:data];
    }
    else if (@available(iOS 10.2, *)) {
        return data;
    }
    else if (@available(iOS 10.0, *)) {
        [self correctResumData:data];
    }
    else {
        return data;
    }
    return data;
}

+ (NSData *)deleteResumeByteRange:(NSData *)data {
    NSMutableDictionary *resumeDictionary = [self getResumeDictionary:data];
    [resumeDictionary removeObjectForKey:NSURLSessionResumeByteRange];
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListWriteInvalidError error:nil];
    return newData;
}

+ (NSData *)correctResumData:(NSData *)data {
    NSMutableDictionary *resumeDictionary = [self getResumeDictionary:data];
    if (!data || !resumeDictionary) {
        return nil;
    }
    
    resumeDictionary[NSURLSessionResumeCurrentRequest] = [self correctRequestData:[resumeDictionary objectForKey:NSURLSessionResumeCurrentRequest]];
    resumeDictionary[NSURLSessionResumeOriginalRequest] = [self correctRequestData:[resumeDictionary objectForKey:NSURLSessionResumeOriginalRequest]];
    
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}





// 一下忽略警告为iOS12.0弃用方法, 而一下方法均不在iOS12.0及以上调用
+ (NSMutableDictionary *)getResumeDictionary:(NSData *)data {
    
    NSMutableDictionary *iresumeDictionary;
    if (@available(macOS 10.11, iOS 9.0, *)) {
        NSMutableDictionary *root;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
#pragma clang diagnostic pop
        NSError *error = nil;
        root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:&error];
        if (!root) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:&error];
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = root;
    }
    
    if (!iresumeDictionary) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:nil];
    }
    return iresumeDictionary;
}


+ (NSData *)correctRequestData:(NSData *)data {
    
    if (!data) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) {
        return data;
    }
#pragma clang diagnostic pop
    NSMutableDictionary *archive = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    if (!archive) {
        return nil;
    }
    int k = 0;
    while ([[archive[@"$objects"] objectAtIndex:1] objectForKey:[NSString stringWithFormat:@"$%d", k]]) {
        k += 1;
    }
    
    int i = 0;
    while ([[archive[@"$objects"] objectAtIndex:1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]]) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = [arr objectAtIndex:1];
        id obj;
        if (dic) {
            obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]];
            if (obj) {
                [dic setObject:obj forKey:[NSString stringWithFormat:@"$%d",i + k]];
                [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%d", i]];
                arr[1] = dic;
                archive[@"$objects"] = arr;
            }
        }
        i += 1;
    }
    if ([[archive[@"$objects"] objectAtIndex:1] objectForKey:@"__nsurlrequest_proto_props"]) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = [arr objectAtIndex:1];
        if (dic) {
            id obj;
            obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
            if (obj) {
                [dic setObject:obj forKey:[NSString stringWithFormat:@"$%d",i + k]];
                [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
                arr[1] = dic;
                archive[@"$objects"] = arr;
            }
        }
    }
    
    id obj = [archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"];
    if (obj) {
        [archive[@"$top"] setObject:obj forKey:NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

@end





