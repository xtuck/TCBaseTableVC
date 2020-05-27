//
//  UITableView+BTVCHelper.m
//
//  Created by xtuck on 2018/5/14.
//

#import "UITableView+BTVCHelper.h"
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


@implementation UITableView (BTVCHelper)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL reusableCellSel = @selector(dequeueReusableCellWithIdentifier:);
        btvc_swizzleSelector(self.class, reusableCellSel, @selector(rtc_dequeueReusableCellWithIdentifier:));
    });
}

- (UITableViewCell *)rtc_dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (![self.rtc_reuseIDs containsObject:identifier]) {
        [self.rtc_reuseIDs addObject:identifier];
    }
    UITableViewCell *cell = [self rtc_dequeueReusableCellWithIdentifier:identifier];
    if (self.rtc_clearReuseIDs.count && [self.rtc_clearReuseIDs containsObject:identifier]) {
        [self.rtc_clearReuseIDs removeObject:identifier];
        NSString *classNameRel = self.rtc_allNibReuseIDsAndClass[identifier];
        if (classNameRel) {
            cell =  [[NSBundle mainBundle] loadNibNamed:classNameRel owner:nil options:nil].firstObject;
            return cell;
        }
        return nil;
    }
    return cell;
}

- (void)tc_clearCellReuseId:(NSString *)reuseID {
    if (reuseID) {
        [self.rtc_clearReuseIDs addObject:reuseID];
    } else {
        [self.rtc_clearReuseIDs removeAllObjects];
        [self.rtc_clearReuseIDs addObjectsFromArray:self.rtc_reuseIDs];
    }
}

- (NSMutableArray *)rtc_clearReuseIDs {
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}


- (NSMutableArray *)rtc_reuseIDs {
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (NSMutableDictionary *)rtc_allNibReuseIDsAndClass {
    NSMutableDictionary *mutDic = objc_getAssociatedObject(self, _cmd);
    if (!mutDic) {
        mutDic = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, _cmd, mutDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return mutDic;
}


- (void)tc_registerNibForCell:(Class)clazz {
    [self tc_registerNibForCell:clazz reuseID:nil];
}

- (void)tc_registerNibForCell:(Class)clazz reuseID:(NSString *)reuseID {
    BOOL isNeedRegister = YES;
    reuseID = reuseID?:clazz.classStr;
    if (reuseID) {
        if ([self.rtc_reuseIDs containsObject:reuseID]) {
            isNeedRegister = NO;
        } else {
            [self.rtc_reuseIDs addObject:reuseID];
        }
    }
    if (isNeedRegister) {
        NSString *classNameRel = clazz.classStr;
        if ([self isNibExistInBundle:[NSBundle mainBundle] nibName:classNameRel]) {
            [self registerNib:[UINib nibWithNibName:classNameRel bundle:nil] forCellReuseIdentifier:reuseID];
            [self.rtc_allNibReuseIDsAndClass setObject:classNameRel forKey:reuseID];
        }
    }
}

//先查询bundle目录中的nib文件，如果没有就查询bundle下的Base.lproj下的nib文件
- (BOOL)isNibExistInBundle:(nonnull NSBundle *)bundle nibName:(nonnull NSString *)nibName {
    BOOL isNibExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.nib",[bundle resourcePath],nibName]];
    if (!isNibExist) {
        isNibExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Base.lproj/%@.nib",[bundle resourcePath],nibName]];
    }
    return isNibExist;
}

@end
