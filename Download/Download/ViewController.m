//
//  ViewController.m
//  Download
//
//  Created by IOS3 on 2019/1/30.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "ViewController.h"
#import "RDDownloader.h"
#import "RDItem.h"


@interface ViewController () <RDItemDelegate>


// 单独的下载用的控件
@property (weak, nonatomic) IBOutlet UILabel *speed1;
@property (weak, nonatomic) IBOutlet UILabel *progress1;
@property (weak, nonatomic) IBOutlet UILabel *state1;
@property (nonatomic, strong) RDItem *item1;
@property (nonatomic, strong) RDDownloader *downloader1;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testSimpleDownload];
}




/// 清除默认的
- (IBAction)removeDownloadFIles:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dir = @"download_default";
    NSString *defaultDir = [cachePath stringByAppendingPathComponent:dir];
    [fileManager removeItemAtPath:defaultDir error:nil];
    [fileManager createDirectoryAtPath:defaultDir withIntermediateDirectories:YES attributes:nil error:nil];
}




// 单独的下载用的控件
- (void)testSimpleDownload {
    self.speed1.text = @"";
    self.progress1.text = @"";
    
    NSString *urlString = @"http://tb-video.bdstatic.com/tieba-smallvideo-transcode/27089192_abcedcf00b503195b7d09f2c91814ef2_3.mp4";
    RDItem *item = [[RDItem alloc] init];
    item.urlString = urlString;
    item.delegate = self;
    
    RDDownloader *downloader = RDDownloader.new;
    [downloader addDownloadingItems:@[item]];
    self.item1 = item;
    self.downloader1 = downloader;
}
- (IBAction)start1:(id)sender {
    [self.downloader1 startWith:self.item1];
}
- (IBAction)pause1:(id)sender {
    [self.downloader1 suspendWith:self.item1];
}
- (IBAction)cancle1:(id)sender {
    [self.downloader1 cancelWith:self.item1];
}

- (void)item:(RDItem *)item stateChanged:(RDItemState)state {
    NSString *stateStr = @"";
    switch (state) {
        case RDItemStateNone:
            
            break;
            
        case RDItemStateWait:
            stateStr = @"等待中";
            break;
            
        case RDItemStateLoading:
            stateStr = @"下载中";
            break;
            
        case RDItemStateSuspend:
            stateStr = @"已暂停";
            break;
            
        case RDItemStateCancel:
            stateStr = @"已取消";
            break;
            
        case RDItemStateSuccess:
            stateStr = @"下载成功";
            break;
            
        case RDItemStateFailure:
            stateStr = @"下载失败";
            break;
            
        default:
            break;
    }
    self.state1.text = stateStr;
    if (state == RDItemStateSuccess) {
        self.speed1.text = @"";
        self.progress1.text = @"";
        NSLog(@"下载成功, %@", [item downloadSavePath]);
    }
}
- (void)item:(RDItem *)item progressChanged:(double)progress {
    self.progress1.text = [NSString stringWithFormat:@"%.2f%s", progress * 100, "%"];
}
- (void)item:(RDItem *)item speedChanged:(NSString *)speed {
    self.speed1.text = speed;
}
@end
