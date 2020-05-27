//
//  NSObject+BTVCHelper.m
//  TCBaseTableVC
//
//  Created by xtuck on 2020/5/26.
//

#import "NSObject+BTVCHelper.h"

@implementation NSObject (BTVCHelper)

- (NSString *)classStr {
    NSString *className = NSStringFromClass(self.class);
    NSString *classNameRel = [className componentsSeparatedByString:@"."].lastObject;
    return classNameRel;
}

@end
