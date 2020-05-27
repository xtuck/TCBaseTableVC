//
//  TCBaseCell.h
//
//  Created by xtuck on 2018/1/13.
//  Copyright © 2018年 xtuck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCBaseCell : UITableViewCell

@property (nonatomic,weak) NSObject *feed;
@property (nonatomic,weak) id delegate;
@property (nonatomic,weak) id viewModel;

- (void)setupCell;
- (void)configWithFeed:(NSObject *)feed;
- (void)configWithFeed:(NSObject *)feed delegate:(id)delegate;
- (void)configWithFeed:(NSObject *)feed delegate:(id)delegate viewModel:(id)viewModel;

@end
