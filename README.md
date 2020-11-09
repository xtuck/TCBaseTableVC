# TCBaseTableVC

[![CI Status](https://img.shields.io/travis/xtuck/TCBaseTableVC.svg?style=flat)](https://travis-ci.org/xtuck/TCBaseTableVC)
[![Version](https://img.shields.io/cocoapods/v/TCBaseTableVC.svg?style=flat)](https://cocoapods.org/pods/TCBaseTableVC)
[![License](https://img.shields.io/cocoapods/l/TCBaseTableVC.svg?style=flat)](https://cocoapods.org/pods/TCBaseTableVC)
[![Platform](https://img.shields.io/cocoapods/p/TCBaseTableVC.svg?style=flat)](https://cocoapods.org/pods/TCBaseTableVC)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TCBaseTableVC is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TCBaseTableVC'
```

## Author

xtuck:104166631@qq.com

## License

TCBaseTableVC is available under the MIT license. See the LICENSE file for more info.

## 用法：使用“UITableView+TCEasy”分类即可，不需要使用TCBaseTableVC基类了

```
//引入头文件
#import "UITableView+TCEasy.h"

```

```

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView refreshWithDrag];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = UITableView.easyCreate(self,self.view);
        _tableView.isShowRefreshView = YES;
        _tableView.isShowLoadMoreView = YES;
    }
    return _tableView;
}

- (CellHelper)cellParamsFromFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    return CellHelperMake(MBAssetsTableCell.class, nil, YES, 0);
}

- (CGFloat)setCellHeightWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    return 88;//UITableViewAutomaticDimension
}

- (void)didSelectCellWithFeed:(NSObject *)feed indexPath:(NSIndexPath *)indexPath {
    //点击cell
}

//请求网络数据
- (void)fetchListData:(RequestListDataFinishBlock)finishBlock {
    [TCContractApi fetchContractNoticeListWithPageNum:self.pageNumber pageSize:self.pageSize]
    .l_parseModelClass_parseKey(FMNewsModel.class,@"#.list()") //解析dataKey中的list数组
    .apiCall(^(TCContractApi *api){
        finishBlock(api.resultParseObject,api.error,0);
    });
}


```
