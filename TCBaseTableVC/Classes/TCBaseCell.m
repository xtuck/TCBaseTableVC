//
//  TCBaseCell.m
//
//  Created by xtuck on 2018/1/13.
//  Copyright © 2018年 xtuck. All rights reserved.
//

#import "TCBaseCell.h"

@implementation TCBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell { }

- (void)configWithFeed:(NSObject *)feed {
    self.feed = feed;
}

- (void)configWithFeed:(NSObject *)feed delegate:(id)delegate {
    self.delegate = delegate;
    [self configWithFeed:feed];
}

- (void)configWithFeed:(NSObject *)feed delegate:(id)delegate viewModel:(id)viewModel {
    self.viewModel = viewModel;
    [self configWithFeed:feed delegate:delegate];
}

@end
