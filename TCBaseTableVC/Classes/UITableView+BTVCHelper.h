//
//  UITableView+BTVCHelper.h
//
//  Created by xtuck on 2018/5/14.
//

#import <UIKit/UIKit.h>
#import "NSObject+BTVCHelper.h"

@interface UITableView (BTVCHelper)

- (void)tc_registerNibForCell:(Class)clazz;

- (void)tc_registerNibForCell:(Class)clazz reuseID:(NSString *)reuseID;

/**
 清除cell重用的缓存，特殊情况下可用，一般用不到
 @param reuseID cell的reuseID
 */
- (void)tc_clearCellReuseId:(NSString *)reuseID;


@end
