//
//  TCTableVCDemo.m
//  TCBaseTableVC_Example
//
//  Created by fengunion on 2020/5/27.
//  Copyright © 2020 chencheng2046@126.com. All rights reserved.
//

#import "TCTableVCDemo.h"
#import "TCViewController.h"

@interface TCTableVCDemo ()

@end

@implementation TCTableVCDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.myTableView.backgroundColor = [UIColor whiteColor];

    self.isShowRefreshView = YES;
    self.isShowLoadMoreView = YES;
    self.pageSize = 5;
    [self refreshWithoutDrag];
}

- (void)fetchListData:(RequestListDataFinishBlock)finishBlock {
    //开始请求数据
    //拿到结果后
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *datas = @[@"1",@"2",@"3",@"4",@"5",@"6"];
        finishBlock(datas,nil,30);
        //处理完毕
        
        //测试调用父类方法
        TCViewController *vc = (id)weakSelf;
        [vc testChangeSuperClass];
    });
}

- (CellHelper)cellParamsFromFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    return CellHelperMake(nil, nil, NO, UITableViewCellStyleValue1);
}

- (void)setCell:(UITableViewCell *)cell feed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = feed.description;
    cell.detailTextLabel.text = @(indexPath.row).stringValue;
}

@end
