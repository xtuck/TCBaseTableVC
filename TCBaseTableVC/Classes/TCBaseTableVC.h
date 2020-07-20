//
//  TCBaseTableVC.h
//
//  Created by tc on 2020/5/26.
//  Copyright © 2020年 xtuck. All rights reserved.
//

#import "UITableView+TCEasy.h"


@interface TCBaseTableVC : UIViewController<TCEasyTableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *cellDataList;

@property (nonatomic, assign) BOOL isShowRefreshView;                   // 是否显示下拉刷新视图控件； default is NO;
@property (nonatomic, assign) BOOL isShowLoadMoreView;                  // 是否显示上拉加载视图控件； default is NO;

@property (nonatomic, assign) int pageNumber;                           //加载更多时候的请求分页页数
@property (nonatomic, assign) int pageSize;                             //每一页多少行数据；当pageSize<=0时，使用kListPagesize
@property (nonatomic,assign) int beginPageNumber;                       //pageNumber第一页的页数，默认是1。

@property (nonatomic, assign) BOOL isForcePlainGroup;                   //在UITableViewStylePlain样式下是否进行分组

@property (nonatomic,assign,readonly) BOOL isRequsting;                 //是否正在执行请求中

////没有下拉动画的刷新。通常用于首次进入界面时的自动刷新，配合toast菊花使用。
- (void)refreshWithoutDrag;
/**
 获取cell对应的数据model

 @param indexPath cell对应的indexPath
 @return 数据对象
 */
- (NSObject *)fetchFeedWithIndexPath:(NSIndexPath *)indexPath;



/// 强制改变TCBaseTableVC的父类，方便子类统一调用你自定义的vc基类的方法,子类中通过强转类型，来调用vc基类的方法
//需要在使用TCBaseTableVC之前调用，建议在程序初始化的时候调用，谨慎使用！！！
+ (BOOL)forceChangeBaseSuperClass:(Class)superClass;


@end
