#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+BTVCHelper.h"
#import "TCBaseCell.h"
#import "TCBaseTableVC.h"
#import "UITableView+BTVCHelper.h"

FOUNDATION_EXPORT double TCBaseTableVCVersionNumber;
FOUNDATION_EXPORT const unsigned char TCBaseTableVCVersionString[];

