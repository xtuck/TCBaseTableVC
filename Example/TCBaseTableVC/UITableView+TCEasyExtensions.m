//
//  UITableView+TCEasyExtensions.m
//  Client
//
//  Created by fengunion on 2020/7/7.
//  Copyright © 2020 fleeming. All rights reserved.
//

#import "UITableView+TCEasyExtensions.h"

@implementation UITableView (TCEasyExtensions)

#pragma mark - 添加通用方法示例

UIImage *imageForEmpty(id obj, SEL selector, UIScrollView *sc) {
    UIImage *img  = [UIImage imageNamed:@"emptyData"];
    return img;
}

NSAttributedString *descriptionForEmpty(id obj, SEL selector, UIScrollView *sc) {
    return [[NSAttributedString alloc] initWithString:@"暂无数据"];
}

+ (void)checkEasyProtocolWithClass:(Class)clazz {
    //emptyData相关检查
    [clazz addUnrealizedProtocol:@selector(imageForEmptyDataSet:) imp:(IMP)imageForEmpty types:"@@:@"];
    [clazz addUnrealizedProtocol:@selector(descriptionForEmptyDataSet:) imp:(IMP)descriptionForEmpty types:"@@:@"];
}


@end
