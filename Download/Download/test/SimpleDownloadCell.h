//
//  SimpleDownloadCell.h
//  Download
//
//  Created by IOS3 on 2019/2/13.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DModel1.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleDownloadCell : UITableViewCell

@property (nonatomic, strong) DModel1 *model;

@property (nonatomic, copy) void(^shouldStart)(DModel1 *model);
@property (nonatomic, copy) void(^shouldPause)(DModel1 *model);
@property (nonatomic, copy) void(^shouldCancel)(DModel1 *model);

@end

NS_ASSUME_NONNULL_END
