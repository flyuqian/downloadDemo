//
//  SimpleDownloadCell.m
//  Download
//
//  Created by IOS3 on 2019/2/13.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "SimpleDownloadCell.h"


@interface SimpleDownloadCell () <RDItemDelegate>

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (weak, nonatomic) IBOutlet UILabel *state;

@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *cancel;

@end

@implementation SimpleDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self.start addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancel addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}



- (void)startBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.shouldStart) {
            self.shouldStart(self.model);
        }
    }
    else {
        if (self.shouldPause) {
            self.shouldPause(self.model);
        }
    }
}
- (void)cancelBtnClick:(UIButton *)sender {
    if (self.shouldCancel) {
        self.shouldCancel(self.model);
    }
}


- (void)setModel:(DModel1 *)model {
    _model = model;
    
    self.name.text = model.name;
    self.speed.text = model.speed;
    self.progress.text = [NSString stringWithFormat:@"%.2f%s", model.progress * 100, "%"];
    self.state.text = [self stateText:model.state];
    model.delegate = self;
}


- (void)item:(RDItem *)item speedChanged:(NSString *)speed {
    if ([item isEqual:self.model]) {
        self.speed.text = item.speed;
    }
    
}
- (void)item:(RDItem *)item stateChanged:(RDItemState)state {
    if ([item isEqual:self.model]) {
        self.state.text = [self stateText:state];
        if (state == RDItemStateSuccess) {
            [self.start setTitle:@"已完成" forState:UIControlStateNormal];
            [self.start setEnabled:NO];
        }
    }
}
- (void)item:(RDItem *)item progressChanged:(double)progress {
    if ([item isEqual:self.model]) {
        self.progress.text = [NSString stringWithFormat:@"%.2f%s", progress * 100, "%"];
    }
}


- (NSString *)stateText:(RDItemState)state {
    switch (state) {
        case RDItemStateNone:
            return @"未下载";
            break;
            
        case RDItemStateWait:
            return @"等待下载";
            break;
            
        case RDItemStateLoading:
            return @"下载中";
            break;
            
        case RDItemStateSuccess:
            return @"下载成功";
            break;
            
        case RDItemStateFailure:
            return @"下载失败";
            break;
            
        case RDItemStateSuspend:
            return @"下载暂停";
            break;
            
        case RDItemStateCancel:
            return @"下载取消";
            break;
            
        default:
            break;
    }
}


@end
