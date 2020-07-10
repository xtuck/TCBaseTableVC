//
//  UITableView+TCEasy.m
//  TCBaseTableVC
//
//  Created by xtuck on 2020/7/6.
//

#import "UITableView+TCEasy.h"
#import <Masonry/Masonry.h>

int const kListPagesize = 10;

@interface UITableView ()

@property (nonatomic,weak,readwrite) id<TCEasyTableViewDelegate> easyDelegate;
@property (nonatomic,assign,readwrite) BOOL isRequsting;
@property (nonatomic,assign,readwrite) int pageNumber;//加载更多时候的请求分页页数

@end

@implementation UITableView (TCEasy)

#pragma mark- isRequsting
- (void)setIsRequsting:(BOOL)isRequsting {
    objc_setAssociatedObject(self, @selector(isRequsting), @(isRequsting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isRequsting {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return num.boolValue;
}

#pragma mark- isForcePlainGroup
- (void)setEasyDelegate:(id<TCEasyTableViewDelegate>)easyDelegate {
    objc_setAssociatedObject(self, @selector(easyDelegate), easyDelegate, OBJC_ASSOCIATION_ASSIGN);
}
- (id<TCEasyTableViewDelegate>)easyDelegate {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark- isShowEmptyData
- (void)setIsShowEmptyData:(BOOL)isShowEmptyData {
    objc_setAssociatedObject(self, @selector(isShowEmptyData), @(isShowEmptyData), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isShowEmptyData {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return num.boolValue;
}


#pragma mark- isForcePlainGroup
- (void)setIsForcePlainGroup:(BOOL)isForcePlainGroup {
    objc_setAssociatedObject(self, @selector(isForcePlainGroup), @(isForcePlainGroup), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isForcePlainGroup {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return num.boolValue;
}

#pragma mark- isShowRefreshView
- (void)setIsShowRefreshView:(BOOL)isShowRefreshView {
    objc_setAssociatedObject(self, @selector(isShowRefreshView), @(isShowRefreshView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (isShowRefreshView) {
        SEL refreshSel = @selector(tableViewRefresh);
        if ([self.easyDelegate respondsToSelector:@selector(customRefreshHeader:refreshSEL:)]) {
            [self.easyDelegate customRefreshHeader:self refreshSEL:refreshSel];
        } else {
            self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:refreshSel];
            MJRefreshStateHeader *header = (id)self.mj_header;
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
        self.mj_header = nil;
    }
}
- (BOOL)isShowRefreshView {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return num.boolValue;
}

#pragma mark- isShowLoadMoreView
- (void)setIsShowLoadMoreView:(BOOL)isShowLoadMoreView {
    objc_setAssociatedObject(self, @selector(isShowLoadMoreView), @(isShowLoadMoreView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (isShowLoadMoreView) {
        SEL loadMoreSel = @selector(tableViewLoadMore);
        if ([self.easyDelegate respondsToSelector:@selector(customLoadMoreFooter:loadMoreSEL:)]) {
            [self.easyDelegate customLoadMoreFooter:self loadMoreSEL:loadMoreSel];
        } else {
            self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:loadMoreSel];
            [self.mj_footer endRefreshingWithNoMoreData];
            self.mj_footer.automaticallyChangeAlpha = YES;//初始化时隐藏
            if ([self.mj_footer respondsToSelector:@selector(setTitle:forState:)]) {
                MJRefreshAutoStateFooter *footer = (id)self.mj_footer;
                if (@available(iOS 8.2, *)) {
                    footer.stateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
                } else {
                    footer.stateLabel.font = [UIFont systemFontOfSize:13];
                }
            }
        }
    } else {
        self.mj_footer = nil;
    }
}

- (BOOL)isShowLoadMoreView {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    return num.boolValue;
}

#pragma mark- cellDataList
- (void)setCellDataList:(NSMutableArray *)cellDataList {
    objc_setAssociatedObject(self, @selector(cellDataList), cellDataList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)cellDataList {
    NSMutableArray *list = objc_getAssociatedObject(self, _cmd);
    if (!list) {
        list = [NSMutableArray array];
        self.cellDataList = list;
    }
    return list;
}

#pragma mark- pageNumber
- (void)setPageNumber:(int)pageNumber {
    objc_setAssociatedObject(self, @selector(pageNumber), @(pageNumber), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)pageNumber {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    if (!num) {
        return 1;
    }
    return num.intValue;
}

#pragma mark- pageSize
- (void)setPageSize:(int)pageSize {
    objc_setAssociatedObject(self, @selector(pageSize), @(pageSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)pageSize {
    NSNumber *num = objc_getAssociatedObject(self, _cmd);
    if (!num) {
        return kListPagesize;
    }
    return num.intValue;
}


- (void)refreshWithDrag {
    [self.mj_header beginRefreshing];
}

- (void)refreshWithoutDrag {
    [self tableViewRefresh];
}

- (void)tableViewRefresh {
    if (self.isRequsting) {
        return;
    }
    if (self.mj_footer.state==MJRefreshStateRefreshing) {
        [self.mj_header endRefreshing];
        return;
    }
    self.pageNumber = 1;
    [self fetchListDataIsLoadMore:NO];
}

- (void)tableViewLoadMore {
    if (self.isRequsting) {
        return;
    }
    if (self.mj_header.state==MJRefreshStateRefreshing) {
        [self.mj_footer endRefreshing];
        return;
    }
    self.pageNumber ++;
    [self fetchListDataIsLoadMore:YES];
}

- (void)fetchListDataIsLoadMore:(BOOL)isLoadMore {
    self.isRequsting = YES;
    //NSLog(@"easyDelegate class: %@",NSStringFromClass(self.easyDelegate.class));
    if ([self.easyDelegate respondsToSelector:@selector(fetchListData:)]) {
        __weak typeof(self) weakSelf = self;
        [self.easyDelegate fetchListData:^(NSArray *datas,NSError *error,int total) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.isRequsting = NO;
            if ([weakSelf.easyDelegate respondsToSelector:@selector(fetchListDataEnd:error:)]) {
                [weakSelf.easyDelegate performSelector:@selector(fetchListDataEnd:error:) withObject:datas withObject:error];
            }
            //停止动画
            [weakSelf.mj_header endRefreshing];
            [weakSelf.mj_footer endRefreshing];
            //请求失败或者请求接口数据数量为0，pageNumber减1
            if (error||datas.count==0) {
                if (weakSelf.pageNumber>1) {
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
                if (datas.count < tempPagesize || (total > 0 && (total <= weakSelf.cellDataList.count || total <= weakSelf.pageNumber*tempPagesize))) {
                    [weakSelf.mj_footer endRefreshingWithNoMoreData];
                }
            } else {
                //请求出错
                if (weakSelf.cellDataList.count==0) {
                    [weakSelf.mj_footer endRefreshingWithNoMoreData];
                }
            }
            [weakSelf reloadData];
            weakSelf.mj_footer.automaticallyChangeAlpha = (weakSelf.cellDataList.count==0);
        }];
    } else {
        [self simulateStopRefreshAnimation];
    }
}
    
//MARK: - 模拟延时关闭上拉下拉刷新的动画效果（仅用于子类未实现fetchListData:方法）
- (void)simulateStopRefreshAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isRequsting = NO;
        [self.mj_header endRefreshing];
        [self.mj_footer endRefreshing];
    });
}


- (NSObject *)fetchFeedWithIndexPath:(NSIndexPath *)indexPath {
    if(self.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        if (self.cellDataList.count>0) {
            NSArray *datas = self.cellDataList[indexPath.section];
            if ([datas isKindOfClass:NSArray.class]) {
                return datas[indexPath.row];
            } else {
                return datas;
            }
        }
    }
    return self.cellDataList[indexPath.row];
}

- (CellHelper)fetchCellHelperWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    CellHelper cellHelper = CellHelperMake(nil,nil,NO,UITableViewCellStyleDefault);
    if ([self.easyDelegate respondsToSelector:@selector(cellParamsFromFeed:indexPath:)]) {
        cellHelper = [self.easyDelegate cellParamsFromFeed:feed indexPath:indexPath];
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
        [baseCell configWithFeed:feed delegate:self.easyDelegate];
    }
}

- (void (^)(id<TCEasyTableViewDelegate>delegate,UIView *addOnView))easyConfig {
    return ^(id<TCEasyTableViewDelegate>delegate,UIView *addOnView) {
        //检查代理是否实现，运行时添加方法，需要方法设置tableView.delegate之前调用
        [UITableView checkProtocol:delegate.class];
        [addOnView addSubview:self];

        if (CGRectIsEmpty(self.frame) && self.superview) {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.equalTo(self.superview.mas_safeAreaLayoutGuideTop);
                    make.bottom.equalTo(self.superview.mas_safeAreaLayoutGuideBottom);
                    make.left.equalTo(self.superview.mas_safeAreaLayoutGuideLeft);
                    make.right.equalTo(self.superview.mas_safeAreaLayoutGuideRight);
                } else {
                    make.edges.equalTo(self.superview);
                }
            }];
        }
        
        if (@available(ios 11.0,*)) {
            self.estimatedSectionHeaderHeight = 0;
            self.estimatedSectionFooterHeight = 0;
        }
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.tableFooterView = [[UIView alloc] init];
    
        self.easyDelegate = delegate;
        self.delegate = delegate;
        //注意：已将dataSource设置为传入delegate，所以在delegate中可以去自由实现dataSource协议
        self.dataSource = (id)delegate;
        self.emptyDataSetSource = (id)delegate;
        self.emptyDataSetDelegate = (id)delegate;
        
        if ([delegate respondsToSelector:@selector(tableViewCreated:)]) {
            [delegate tableViewCreated:self];
        }
    };
}

+ (UITableView *(^)(id<TCEasyTableViewDelegate>,UIView *))easyCreate {
    return ^(id<TCEasyTableViewDelegate>delegate,UIView *addOnView) {
        //检查代理是否实现，运行时添加方法，需要方法设置tableView.delegate之前调用
        UITableView *tableView;
        if ([delegate respondsToSelector:@selector(useOtherTableView)]) {
            tableView = [delegate useOtherTableView];
        } else if ([delegate respondsToSelector:@selector(tableViewCreateParams)]) {
            TableViewHelper helper = [delegate tableViewCreateParams];
            Class tvClass = helper.tvClass?:UITableView.class;
            tableView = [[tvClass alloc] initWithFrame:helper.tvFrame style:helper.tvStyle];
        } else {
            tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        }
        tableView.easyConfig(delegate,addOnView);
        return tableView;
    };
}

- (CGFloat)easy_heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.easyDelegate respondsToSelector:@selector(setCellHeightWithFeed:indexPath:)]) {
        id feed = [self fetchFeedWithIndexPath:indexPath];
        return [self.easyDelegate setCellHeightWithFeed:feed indexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (void)easy_didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.easyDelegate respondsToSelector:@selector(didSelectCellWithFeed:indexPath:)]) {
        id feed = [self fetchFeedWithIndexPath:indexPath];
         [self.easyDelegate didSelectCellWithFeed:feed indexPath:indexPath];
    }
}

- (UITableViewCell *)easy_cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self easy_tableView:self cellForRowAtIndexPath:indexPath];
}

- (NSInteger)easy_numberOfRowsInSection:(NSInteger)section {
    return [self easy_tableView:self numberOfRowsInSection:section];
}

- (NSInteger)easy_numberOfSections {
    return [self easy_numberOfSectionsInTableView:self];
}

#pragma mark- dalagete逻辑转换

- (UITableViewCell *)easy_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id feed = [self fetchFeedWithIndexPath:indexPath];
    CellHelper cellHelper = [self fetchCellHelperWithFeed:feed indexPath:indexPath];
    NSString *cellIdentifierStr = [NSString stringWithUTF8String:cellHelper.reuseId];
    if (cellHelper.isNib) {
        [self tc_registerNibForCell:cellHelper.cellClass reuseID:cellIdentifierStr];
    }
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellIdentifierStr];
    if (!cell) {
        if ([self.easyDelegate respondsToSelector:@selector(createCellWithFeed:indexPath:)]) {
            cell = [self.easyDelegate createCellWithFeed:feed indexPath:indexPath];
        } else {
            cell = [self createCellWithFeed:feed indexPath:indexPath];
        }
    }
    if ([self.easyDelegate respondsToSelector:@selector(setCell:feed:indexPath:)]) {
        [self.easyDelegate setCell:cell feed:feed indexPath:indexPath];
    } else {
        [self setCell:cell feed:feed indexPath:indexPath];
    }
    return cell;
}


- (NSInteger)easy_numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        return self.cellDataList.count;
    }
    return 1;
}
    
- (NSInteger)easy_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.style==UITableViewStyleGrouped||self.isForcePlainGroup) {
        if(self.cellDataList.count>0) {
            NSArray *datas = self.cellDataList[section];
            if ([datas isKindOfClass:NSArray.class]) {
                return datas.count;
            }
            return 1;
        }
    }
    return self.cellDataList.count;
}

#pragma mark- 运行时添加协议方法
void didSelectRow(id obj, SEL selector, UITableView *tb, NSIndexPath *indexPath) {
    [tb easy_didSelectRowAtIndexPath:indexPath];
}

NSInteger numberOfSections(id obj, SEL selector, UITableView *tb) {
    return [tb easy_numberOfSections];
}

NSInteger numberOfRows(id obj, SEL selector, UITableView *tb, NSInteger section) {
    return [tb easy_numberOfRowsInSection:section];
}

UITableViewCell *cellForRow(id obj, SEL selector, UITableView *tb, NSIndexPath *indexPath) {
    return [tb easy_cellForRowAtIndexPath:indexPath];
}

CGFloat heightForRow(id obj, SEL selector, UITableView *tb, NSIndexPath *indexPath) {
    return [tb easy_heightForRowAtIndexPath:indexPath];
}


bool emptyDataShouldScroll(id obj, SEL selector, UIScrollView *sc) {
    return YES;
}

bool emptyDataShouldDisplay(id obj, SEL selector, UIScrollView *sc) {
    //设置第一次不显示，避免加载数据之前显示空态页
    NSString *isFristExe = @"emptyDataShouldDisplayIsFristExe";
    NSNumber *isHadExe = objc_getAssociatedObject(sc, isFristExe.UTF8String);
    if (!isHadExe) {
        objc_setAssociatedObject(sc, isFristExe.UTF8String, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return NO;
    }
    return [(UITableView *)sc isShowEmptyData];
}

+ (void)checkProtocol:(Class)clazz {
    if (!clazz) return;
    
    if ([self.class respondsToSelector:@selector(checkEasyProtocolWithClass:)]) {
        //self.class是UITableView.class或其子类
        [self.class checkEasyProtocolWithClass:clazz];
    }
    [clazz addUnrealizedProtocol:@selector(numberOfSectionsInTableView:) imp:(IMP)numberOfSections types:"l@:@"];
    [clazz addUnrealizedProtocol:@selector(tableView:numberOfRowsInSection:) imp:(IMP)numberOfRows types:"l@:@@"];
    [clazz addUnrealizedProtocol:@selector(tableView:cellForRowAtIndexPath:) imp:(IMP)cellForRow types:"@@:@@"];
    [clazz addUnrealizedProtocol:@selector(tableView:heightForRowAtIndexPath:) imp:(IMP)heightForRow types:"f@:@@"];
    [clazz addUnrealizedProtocol:@selector(tableView:didSelectRowAtIndexPath:) imp:(IMP)didSelectRow types:"v@:@@"];

    //emptyData相关检查
    [clazz addUnrealizedProtocol:@selector(emptyDataSetShouldAllowScroll:) imp:(IMP)emptyDataShouldScroll types:"B@:@"];
    [clazz addUnrealizedProtocol:@selector(emptyDataSetShouldDisplay:) imp:(IMP)emptyDataShouldDisplay types:"B@:@"];
}

@end

@implementation NSObject (AddUnrealizedProtocol)

- (BOOL)addUnrealizedProtocol:(SEL)sel imp:(IMP)imp types:(const char *)types {
    if (![self.class instancesRespondToSelector:sel]) {
        class_addMethod(self.class, sel, imp, types);
        return YES;
    }
    return NO;
}

@end
