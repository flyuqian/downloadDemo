//
//  SimpleDownloadController.m
//  Download
//
//  Created by IOS3 on 2019/2/13.
//  Copyright © 2019 IOS3. All rights reserved.
//

#import "SimpleDownloadController.h"
#import "DModel1.h"
#import "SimpleDownloadCell.h"
#import "RDDownloader.h"


@interface SimpleDownloadController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (nonatomic, strong) NSArray *downloaderItems;
@property (nonatomic, strong) RDDownloader *downloader;

@end

@implementation SimpleDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloader = RDDownloader.new;
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.rowHeight = 60;
//    [self.tableVIew registerClass:SimpleDownloadCell.class forCellReuseIdentifier:NSStringFromClass(SimpleDownloadCell.class)];
    NSString *className = NSStringFromClass(SimpleDownloadCell.class);
    [self.tableVIew registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:className];
    [self addBarbutton];
    
    for (NSArray *items in self.downloaderItems) {
        [self.downloader addDownloadingItems:items];
    }
}

- (void)addBarbutton {
    UIButton *startAll = UIButton.new;
    startAll.backgroundColor = UIColor.redColor;
    [startAll setTitle:@"全部开始" forState:UIControlStateNormal];
    [startAll setTitle:@"全部暂停" forState:UIControlStateSelected];
    [startAll addTarget:self action:@selector(startAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *startAllItem = [[UIBarButtonItem alloc] initWithCustomView:startAll];
    
    UIButton *cancelAll = UIButton.new;
    cancelAll.backgroundColor = UIColor.blueColor;
    [cancelAll setTitle:@"取消全部" forState:UIControlStateNormal];
    [cancelAll addTarget:self action:@selector(cancelAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelAllItem = [[UIBarButtonItem alloc] initWithCustomView:cancelAll];
    self.navigationItem.rightBarButtonItems = @[startAllItem, cancelAllItem];
}

- (void)startAllBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.downloader downloadAll];
    }
    else {
        [self.downloader suspendAll];
    }
}
- (void)cancelAllBtnClick:(UIButton *)sender {
    [self.downloader cancelAll];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.downloaderItems.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionItems = self.downloaderItems[section];
    return sectionItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SimpleDownloadCell.class) forIndexPath:indexPath];
    NSArray *sectionItems = self.downloaderItems[indexPath.section];
    DModel1 *model = sectionItems[indexPath.row];
    cell.model = model;
    
    cell.shouldStart = ^(DModel1 * _Nonnull model) {
        [self.downloader startWith:model];
    };
    cell.shouldPause = ^(DModel1 * _Nonnull model) {
        [self.downloader suspendWith:model];
    };
    cell.shouldCancel = ^(DModel1 * _Nonnull model) {
        [self.downloader cancelWith:model];
    };
    
    return cell;
}



- (NSArray *)downloaderItems {
    if (!_downloaderItems) {
        NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"TestResource.json" ofType:nil]];
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSMutableArray *datas = [NSMutableArray array];
        if ([obj isKindOfClass:NSArray.class]) {
            NSArray *rootArr = (NSArray *)obj;
            
            for (id node in rootArr) {
                NSMutableArray *section = [NSMutableArray array];
                if ([node isKindOfClass:NSArray.class]) {
                    for (NSString *str in (NSArray *)node) {
                        DModel1 *model = [DModel1 itemWithUrl:str];
                        
                        [section addObject:model];
                    }
                }
                [datas addObject:section.copy];
            }
            _downloaderItems = datas.copy;
        }
    }
    return _downloaderItems;
}

@end

