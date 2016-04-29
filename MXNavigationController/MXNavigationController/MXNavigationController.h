//
//  MXNavigationController.h
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  设定导航栏背景颜色
 *  可根据实际需要修改
 */
#define MX_NAV_BARTINT_COLOR [UIColor colorWithRed:84/255.0 green:205/255.0 blue:198/255.0 alpha:1.0]

/**
 *  设定导航栏标题文字颜色
 *  可根据实际需要修改
 */
#define MX_NAV_TITLE_COLOR [UIColor whiteColor]

/**
 *  设定导航栏标题文字字体
 *  可根据实际需要修改字体样式和字体大小
 */
#define MX_NAV_TITLE_FONT [UIFont systemFontOfSize:17.0]

@interface MXNavigationController : UINavigationController

/**
 *  控制全屏Pop手势是否可用（为YES时可用）
 */
@property (assign, nonatomic) BOOL interactivePopGestureRecognizerEnabled;

@end
