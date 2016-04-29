//
//  PushViewController.m
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import "PushViewController.h"

#import <Masonry/Masonry.h>

@interface PushViewController ()

@property (retain, nonatomic) UILabel *mainLabel;

@end

@implementation PushViewController

- (void)loadView {
    [super loadView];
    
    UILabel *mainLabel = [[UILabel alloc] init];
    [mainLabel setFont:[UIFont boldSystemFontOfSize:21.0]];
    [mainLabel setTextColor:[UIColor colorWithRed:84/255.0 green:205/255.0 blue:198/255.0 alpha:1.0]];
    [mainLabel setTextAlignment:NSTextAlignmentCenter];
    [mainLabel setNumberOfLines:0];
    [self.view addSubview:mainLabel];
    
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self setMainLabel:mainLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemEvent:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    BOOL enabled = [[self.navigationController valueForKey:@"interactivePopGestureRecognizerEnabled"] boolValue];
    [self adjustNavInteractivePopGestureRecognizerEnabled:enabled];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)adjustNavInteractivePopGestureRecognizerEnabled:(BOOL)enabled
{
    NSString *text = enabled ? @"禁用手势" : @"启用手势";
    [self.navigationItem.rightBarButtonItem setTitle:text];
    
    text = enabled ? @"在屏幕中任何位置向右滑动\n即可返回" : @"全屏Pop手势已禁用";
    [self.mainLabel setText:text];
}

- (void)rightBarButtonItemEvent:(UIBarButtonItem *)item
{
    BOOL enabled = ![[self.navigationController valueForKey:@"interactivePopGestureRecognizerEnabled"] boolValue];
    
    /**
     *  启用/禁用全屏Pop手势
     */
    [self.navigationController setValue:@(enabled) forKey:@"interactivePopGestureRecognizerEnabled"];
    [self adjustNavInteractivePopGestureRecognizerEnabled:enabled];
}

@end
