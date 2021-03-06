
//
//  TCBaseTableVC.m
//
//  Created by  tc on 2018/5/9.
//  Copyright © 2018年 xtuck. All rights reserved.
//

#import "TCBaseTableVC.h"

@interface TCBaseTableVC ()

@property (nonatomic,assign,readwrite) BOOL isRequsting;                 //是否正在执行请求中
@property (nonatomic,strong) NSMutableArray *tvConstraints;//添加的原生自动布局约束

@end

@implementation TCBaseTableVC
    
- (NSMutableArray *)cellDataList {
    if (!_cellDataList) {
        _cellDataList = [[NSMutableArray alloc] init];
    }
    return _cellDataList;
}

- (NSMutableArray *)tvConstraints {
    if (!_tvConstraints) {
        _tvConstraints = [[NSMutableArray alloc] init];
    }
    return _tvConstraints;
}

- (void)removeTVAutoLayout {
    [NSLayoutConstraint deactivateConstraints:self.tvConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.beginPageNumber = 1;
    [self createTableView];
}

- (void)createTableView {
    if([self respondsToSelector:@selector(useOtherTableView)]) {
        _myTableView = [self useOtherTableView];
    } else if ([self respondsToSelector:@selector(tableViewCreateParams)]) {
        TableViewHelper helper = [self tableViewCreateParams];
        Class tvClass = helper.tvClass?:UITableView.class;
        _myTableView = [[tvClass alloc] initWithFrame:helper.tvFrame style:helper.tvStyle];
    } else {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    _myTableView.delegate = self;
    _myTableView.dataSource = self;

    //如果设置了空态页图片，才会设置空态页相关代理
    if ([self imageForEmptyDataSet:nil]) {
        _myTableView.emptyDataSetSource = self;
        _myTableView.emptyDataSetDelegate = self;
    }
    if (!_myTableView.superview) {
        [self.view addSubview:_myTableView];
    }
    if (CGRectIsEmpty(_myTableView.frame)) {
        _myTableView.translatesAutoresizingMaskIntoConstraints = NO;
        id item = nil;
        if (@available(iOS 11.0, *)) {
            item = _myTableView.superview.safeAreaLayoutGuide;
        } else {
            item = _myTableView.superview;
        }
        [self.tvConstraints removeAllObjects];
        NSArray *attributes = @[@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom),@(NSLayoutAttributeLeft),@(NSLayoutAttributeRight)];
        for (NSNumber *att in attributes) {
            NSLayoutAttribute attribute = att.integerValue;
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_myTableView
                                                                          attribute:attribute
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:item
                                                                          attribute:attribute
                                                                         multiplier:1.0
                                                                           constant:0.0];
            constraint.active = YES;
            [self.tvConstraints addObject:constraint];
        }
    }
    if (@available(ios 11.0,*)) {
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
    }
    _myTableView.separatorInset = UIEdgeInsetsZero;
    _myTableView.layoutMargins = UIEdgeInsetsZero;
    _myTableView.tableFooterView = [[UIView alloc] init];
    
    if ([self respondsToSelector:@selector(tableViewCreated:)]) {
        [self tableViewCreated:_myTableView];
    }
}

- (void)setIsShowRefreshView:(BOOL)isShowRefreshView {
    _isShowRefreshView = isShowRefreshView;
    if (isShowRefreshView) {
        SEL refreshSel = @selector(tableViewRefresh);
        if ([self respondsToSelector:@selector(customRefreshHeader:refreshSEL:)]) {
            [self customRefreshHeader:_myTableView refreshSEL:refreshSel];
        } else {
            _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                      refreshingAction:refreshSel];
            MJRefreshStateHeader *header = (id)_myTableView.mj_header;
            if ([header isKindOfClass:MJRefreshStateHeader.class]) {
                header.lastUpdatedTimeLabel.hidden =YES;
                if (@available(iOS 8.2, *)) {
                    header.stateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
                } else {
                    header.stateLabel.font = [UIFont systemFontOfSize:13];
                }
            }
        }
    } else {
        _myTableView.mj_header = nil;
    }
}
    
- (void)setIsShowLoadMoreView:(BOOL)isShowLoadMoreView {
    _isShowLoadMoreView = isShowLoadMoreView;
    if (isShowLoadMoreView) {
        SEL loadMoreSel = @selector(tableViewLoadMore);
        if ([self respondsToSelector:@selector(customLoadMoreFooter:loadMoreSEL:)]) {
            [self customLoadMoreFooter:_myTableView loadMoreSEL:loadMoreSel];
        } else {
            _myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                                          refreshingAction:loadMoreSel];
            [_myTableView.mj_footer endRefreshingWithNoMoreData];
            _myTableView.mj_footer.automaticallyChangeAlpha = YES;//初始化时隐藏
            if ([_myTableView.mj_footer respondsToSelector:@selector(setTitle:forState:)]) {
                MJRefreshAutoStateFooter *footer = (id)_myTableView.mj_footer;
                if (@available(iOS 8.2, *)) {
                    footer.stateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
                } else {
                    footer.stateLabel.font = [UIFont systemFontOfSize:13];
                }
            }
        }
    } else {
        _myTableView.mj_footer = nil;
    }
}

- (void)refreshWithoutDrag {
    [self tableViewRefresh];
}

- (void)tableViewRefresh {
    if (self.isRequsting) {
        return;
    }
    if (_myTableView.mj_footer.state==MJRefreshStateRefreshing) {
        [_myTableView.mj_header endRefreshing];
        return;
    }
    _pageNumber = self.beginPageNumber;
    [self fetchListDataIsLoadMore:NO];
}

- (void)tableViewLoadMore {
    if (self.isRequsting) {
        return;
    }
    if (_myTableView.mj_header.state==MJRefreshStateRefreshing) {
        [_myTableView.mj_footer endRefreshing];
        return;
    }
    _pageNumber ++;
    [self fetchListDataIsLoadMore:YES];
}

- (void)fetchListDataEnd:(NSArray *)datas error:(NSError *)error {
}

- (void)fetchListDataIsLoadMore:(BOOL)isLoadMore {
    _isRequsting = YES;
    if ([self respondsToSelector:@selector(fetchListData:)]) {
        __weak typeof(self) weakSelf = self;
        [self fetchListData:^(NSArray *datas,NSError *error,int total) {
            weakSelf.isRequsting = NO;
            [self fetchListDataEnd:datas error:error];
            //停止动画
            [weakSelf.myTableView.mj_header endRefreshing];
            [weakSelf.myTableView.mj_footer endRefreshing];
            //请求失败或者请求接口数据数量为0，pageNumber减1
            if (error||datas.count==0) {
                if (weakSelf.pageNumber>weakSelf.beginPageNumber) {
                    weakSelf.pageNumber --;
                }
            }
            if (!error) {
                if (!isLoadMore) {
                    [weakSelf.cellDataList removeAllObjects];
                }
                if (datas.count>0) {
                    [weakSelf.cellDataList addObjectsFromArray:datas];
                }
                //pageSize 单页最大条数
                int tempPagesize = weakSelf.pageSize > 0 ? weakSelf.pageSize : kListPagesize;
                int tempPageNum = weakSelf.pageNumber - weakSelf.beginPageNumber + 1;
                if (datas.count < tempPagesize || (total > 0 && (total <= weakSelf.cellDataList.count || total <= tempPageNum * tempPagesize))) {
                    [weakSelf.myTableView.mj_footer endRefreshingWithNoMoreData];
                }
            } else {
                //请求出错
                if (weakSelf.cellDataList.count==0) {
                    [weakSelf.myTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.mj_footer.automaticallyChangeAlpha = (weakSelf.cellDataList.count==0);
        }];
    } else {
        [self simulateStopRefreshAnimation];
    }
}
    
//MARK: - 模拟延时关闭上拉下拉刷新的动画效果（仅用于子类未实现fetchListData:方法）
- (void)simulateStopRefreshAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isRequsting = NO;
        [self->_myTableView.mj_header endRefreshing];
        [self->_myTableView.mj_footer endRefreshing];
    });
}

    
#pragma mark - UITableView dataSource delegate
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_myTableView.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        return _cellDataList.count;
    }
    return 1;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_myTableView.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        if(_cellDataList.count>0) {
            NSArray *datas = _cellDataList[section];
            if ([datas isKindOfClass:NSArray.class]) {
                return datas.count;
            }
            return 1;
        }
    }
    return _cellDataList.count;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(_myTableView.style==UITableViewStyleGrouped) {
        return CGFLOAT_MIN;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(_myTableView.style==UITableViewStyleGrouped) {
        return 5.0;
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id feed = [self fetchFeedWithIndexPath:indexPath];
    CellHelper cellHelper = [self fetchCellHelperWithFeed:feed indexPath:indexPath];
    NSString *cellIdentifierStr = [NSString stringWithUTF8String:cellHelper.reuseId];
    if (cellHelper.isNib) {
        [tableView tc_registerNibForCell:cellHelper.cellClass reuseID:cellIdentifierStr];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierStr];
    if (!cell) {
        cell = [self createCellWithFeed:feed indexPath:indexPath];
    }
    [self setCell:cell feed:feed indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self respondsToSelector:@selector(setCellHeightWithFeed:indexPath:)]) {
        id feed = [self fetchFeedWithIndexPath:indexPath];
        return [self setCellHeightWithFeed:feed indexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self respondsToSelector:@selector(didSelectCellWithFeed:indexPath:)]) {
        id feed = [self fetchFeedWithIndexPath:indexPath];
         [self didSelectCellWithFeed:feed indexPath:indexPath];
    }
}


#pragma mark - TCBaseTableVCDelegate

- (NSObject *)fetchFeedWithIndexPath:(NSIndexPath *)indexPath {
    if(_myTableView.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        if (_cellDataList.count>0) {
            NSArray *datas = _cellDataList[indexPath.section];
            if ([datas isKindOfClass:NSArray.class]) {
                return datas[indexPath.row];
            } else {
                return datas;
            }
        }
    }
    return _cellDataList[indexPath.row];
}

- (CellHelper)fetchCellHelperWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    CellHelper cellHelper = CellHelperMake(nil,nil,NO,UITableViewCellStyleDefault);
    if ([self respondsToSelector:@selector(cellParamsFromFeed:indexPath:)]) {
        cellHelper = [self cellParamsFromFeed:feed indexPath:indexPath];
    }
    if (!cellHelper.cellClass) {
        cellHelper.cellClass = UITableViewCell.class;
    }
    if (!cellHelper.reuseId) {
        /// 获取class对应的字符串，兼容swift
        NSString *classNameRel = [NSStringFromClass(cellHelper.cellClass) componentsSeparatedByString:@"."].lastObject;
        cellHelper.reuseId = classNameRel.UTF8String;
    }
    return cellHelper;
}

- (UITableViewCell *)createCellWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    CellHelper cellHelper = [self fetchCellHelperWithFeed:feed indexPath:indexPath];
    NSString *reuseIDStr = [NSString stringWithUTF8String:cellHelper.reuseId];
    return [[cellHelper.cellClass alloc] initWithStyle:cellHelper.cellStyle reuseIdentifier:reuseIDStr];
}
    
- (void)setCell:(UITableViewCell *)cell feed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:TCBaseCell.class]) {
        TCBaseCell *baseCell = (id)cell;
        [baseCell configWithFeed:feed delegate:self];
    }
}


//MARK: - nodataview delegate
//子类中重写imageForEmptyDataSet方法，并返回image后，父类初始化时才会设置相关代理
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return nil;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return 0;
}

//修复多个tableView切换时或其他情况造成的占位图和文字移位的问题
- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    [self.myTableView setContentOffset:CGPointMake(0, -self.myTableView.contentInset.top)];
}



//MARK: class_method
+ (BOOL)forceChangeBaseSuperClass:(Class)superClass {
    if ([superClass isSubclassOfClass:[UIViewController class]]) {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            class_setSuperclass(TCBaseTableVC.class, superClass);
#if DEBUG
            NSLog(@"开发人员请注意，TCBaseTableVC的父类已强制更改为：%@",NSStringFromClass(superClass));
#endif
#pragma clang diagnostic pop
            return YES;
        } @catch (NSException *exception) {
#if DEBUG
            NSLog(@"change superClass failed");
#endif
        }
    }
    return NO;
}


@end
