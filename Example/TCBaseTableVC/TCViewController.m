//
//  TCViewController.m
//  TCBaseTableVC
//
//  Created by chencheng2046@126.com on 05/26/2020.
//  Copyright (c) 2020 chencheng2046@126.com. All rights reserved.
//

#import "TCViewController.h"
#import "TCTableVCDemo.h"

@interface TCViewController ()

@end

@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 180, 50);
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"BaseTVC Demo" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //更改TCBaseTableVC的父类
    [TCBaseTableVC forceChangeBaseSuperClass:TCViewController.class];
}

- (void)clickBtn:(UIButton *)sender {
    TCTableVCDemo *vc = [[TCTableVCDemo alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)testChangeSuperClass {
    NSLog(@"继承替换方案成功");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
