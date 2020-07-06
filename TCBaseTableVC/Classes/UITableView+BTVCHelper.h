//
//  UITableView+BTVCHelper.h
//
//  Created by xtuck on 2018/5/14.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//两个类的实例方法交换
static inline void btvc_swizzle2InstanceSelector(Class originalClass, Class swizzledClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(originalClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

//单个类中的实例方法交换
static inline void btvc_swizzleSelector(Class clazz, SEL originalSelector, SEL swizzledSelector) {
    btvc_swizzle2InstanceSelector(clazz, clazz, originalSelector, swizzledSelector);
}

@interface UITableView (BTVCHelper)

- (void)tc_registerNibForCell:(Class)clazz;

- (void)tc_registerNibForCell:(Class)clazz reuseID:(NSString *)reuseID;

/**
 清除cell重用的缓存，特殊情况下可用，一般用不到
 @param reuseID cell的reuseID
 */
- (void)tc_clearCellReuseId:(NSString *)reuseID;


@end
