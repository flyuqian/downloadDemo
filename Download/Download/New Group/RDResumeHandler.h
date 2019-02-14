//
//  RDResumeManager.h
//  Download2
//
//  Created by IOS3 on 2019/1/30.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RDResumeHandler : NSObject


+ (NSData *)handleResumeData:(NSData *)data;


@end

NS_ASSUME_NONNULL_END
