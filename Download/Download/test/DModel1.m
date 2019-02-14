//
//  DModel1.m
//  Download
//
//  Created by IOS3 on 2019/2/13.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "DModel1.h"

@implementation DModel1

- (NSString *)name {
    NSString *name = [[self downloadSavePath] componentsSeparatedByString:@"/"].lastObject;
    if (name.length > 15) {
        name = [name substringToIndex:15];
    }
    return name;
}

@end
