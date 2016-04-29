//
//  MainViewController.m
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import "MainViewController.h"

#import "PushViewController.h"

#import <Masonry/Masonry.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)loadView {
    [super loadView];
    
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushButton setBackgroundColor:[UIColor colorWithRed:84/255.0 green:205/255.0 blue:198/255.0 alpha:1.0]];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pushButton setTitle:@"Push" forState:UIControlStateNormal];
    [pushButton addTarget:self action:@selector(pushButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    
    [pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20.0);
        make.right.equalTo(self.view).offset(-20.0);
        make.height.mas_equalTo(60.0);
        make.centerY.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Nav Class = %@", NSStringFromClass([self.navigationController class]));
    
    UIImage *menuImage = [UIImage imageNamed:@"nav_menu_image.png"];
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonItemEvent:)];
    self.navigationItem.rightBarButtonItem = menuBarButtonItem;
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

- (void)menuBarButtonItemEvent:(UIBarButtonItem *)button
{
    NSLog(@"点击了导航栏菜单按钮。");
}

- (void)pushButtonEvent:(UIButton *)button
{
    PushViewController *pushViewController = [[PushViewController alloc] init];
    [self.navigationController pushViewController:pushViewController animated:YES];
}

@end
