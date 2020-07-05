//
//  TCBaseTableVC.h
//
//  Created by tc on 2020/5/26.
//  Copyright © 2020年 xtuck. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

//DZNEmptyDataSet相关用法，可以参考github源码：https://github.com/dzenbot/DZNEmptyDataSet
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

UIKIT_EXTERN int const kListPagesize;//没有设置翻页请求数据的每页最大条数时，则使用此参数，默认20

typedef struct {
    Class cellClass;                    //cell对应的Class,如果传nil，则使用TableViewCell.Class
    const char *reuseId;                //cell重用的id,如果传入nil，则使用cellClass对应的字符串
    BOOL isNib;                         //cell是否是xib创建
    UITableViewCellStyle cellStyle;     //cell的样式
} CellHelper;

CG_INLINE CellHelper
CellHelperMake(Class clazz, NSString *reuseId, BOOL isNib, UITableViewCellStyle cellStyle) {
    CellHelper helper;
    helper.cellClass = clazz;
    helper.reuseId = [reuseId UTF8String];
    helper.isNib = isNib;
    helper.cellStyle = cellStyle;
    return helper;
}

typedef struct {
    Class tvClass;                      //TableView对应的Class,传入nil时则使用UITableView.Class
    UITableViewStyle tvStyle;           //TableView创建时的样式
    CGRect tvFrame;                     //TableView的frame,如果传入CGRectZero,则使用自动布局，与self.view同大小
} TableViewHelper;

CG_INLINE TableViewHelper
TableViewHelperMake(Class tvClass, UITableViewStyle tvStyle, CGRect tvFrame) {
    TableViewHelper helper;
    helper.tvClass = tvClass;
    helper.tvStyle = tvStyle;
    helper.tvFrame = tvFrame;
    return helper;
}

/**
 翻页请求完毕后，数据通过block返回进行处理

 @param datas 返回的数据model数组
 @param error 返回的错误信息
 @param total 服务器数据总条数：非必要，没有就传0
 */
typedef void (^RequestListDataFinishBlock) (NSArray *datas,NSError *error,int total);


@protocol TCBaseTableVCDelegate  <NSObject>

@optional

/**
 使用其他的tableView,例如xib上的tableView，或者自己创建的tableView
 优先级1
 @return TableView
 */
- (UITableView *)useOtherTableView;

/**
 创建tableView所需要的参数
 优先级2
 @return 参数结构体
 */
- (TableViewHelper)tableViewCreateParams;

/**
 设置cell相关参数
 
 @param feed cell对应的数据model
 @param indexPath cell对应的indexPath
 @return 返回cell的cellClass，reuseId，是否是nib，cell样式所组成的结构体
 */
- (CellHelper)cellParamsFromFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath;


/// tableView创建完毕，子类可继续进行定制化设置，也可以在子类的[super viewDidLoad]之后对tableView进行设置
/// @param tableView 创建好的tableView = self.myTableView
- (void)tableViewCreated:(UITableView *)tableView;


/// 子类中自定义头部刷新的样式
/// @param tableView tableView = self.myTableView
/// @param refreshSEL 父类中刷新时调用的方法，子类中定义样式时需传入此方法
- (void)customRefreshHeader:(UITableView *)tableView refreshSEL:(SEL)refreshSEL;

/// 子类中自定义头部刷新的样式
/// @param tableView tableView = self.myTableView
/// @param loadMoreSEL 父类中加载更多时调用的方法，子类中定义样式时需传入此方法
- (void)customLoadMoreFooter:(UITableView *)tableView loadMoreSEL:(SEL)loadMoreSEL;

/**
 设置cell的高度，如果子类不实现，则使用自动布局
 
 @param feed cell对应的数据model
 @param indexPath cell对应的indexPath
 @return 返回cell的高度
 */
- (CGFloat)setCellHeightWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath;

/**
 *  创建cell,子类可重写
 *
 *  @return 返回创建好的cell
 */
- (UITableViewCell *)createCellWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath;

/**
 *  传入数据对象，设置cell的数据显示，可子类重写
 *
 *  @param feed      需要显示在cell上面的数据对象
 *  @param indexPath 当前cell的indexPath
 */
- (void)setCell:(UITableViewCell *)cell feed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath;

/**
 点击cell事件,子类实现

 @param feed 当前cell对应的数据
 @param indexPath cell对应的indexPath
 */
- (void)didSelectCellWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath;

//获取列表数据，子类实现
- (void)fetchListData:(RequestListDataFinishBlock)finishBlock;

//请求结束后的回调，便于统一处理error逻辑，子类实现
- (void)fetchListDataEnd:(NSArray *)result error:(NSError *)error;

@end


@interface TCBaseTableVC : UIViewController<UITableViewDelegate,UITableViewDataSource,
                                            DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
                                            TCBaseTableVCDelegate>

@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *cellDataList;

@property (nonatomic, assign) BOOL isShowRefreshView;                   // 是否显示下拉刷新视图控件； default is NO;
@property (nonatomic, assign) BOOL isShowLoadMoreView;                  // 是否显示上拉加载视图控件； default is NO;

@property (nonatomic, assign) int pageNumber;                           //加载更多时候的请求分页页数
@property (nonatomic, assign) int pageSize;                             //每一页多少行数据；当pageSize不设置，或者pageSize<=0时，使用kListPagesize

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
