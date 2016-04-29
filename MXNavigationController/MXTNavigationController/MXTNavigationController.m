//
//  MXTNavigationController.m
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import "MXTNavigationController.h"

#import "MXTNavigationTransition.h"

@interface MXTNavigationController () <UIGestureRecognizerDelegate, MXTNavigationTransitionDelegate>

/**
 *  全屏Pop手势
 */
@property (strong, nonatomic) UIPanGestureRecognizer *popGestureRecognizer;

/**
 *  全屏Pop动画控制对象
 */
@property (strong, nonatomic) MXTNavigationTransition *navigationTransition;

@end

@implementation MXTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureCommonAttributes];
    [self replaceInteractivePopGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  配置导航栏上各控件的默认属性
 */
- (void)configureCommonAttributes
{
    /**
     *  导航栏颜色
     */
    [[UINavigationBar appearance] setBarTintColor:MXT_NAV_BARTINT_COLOR];
    
    /**
     *  导航栏标题字体和字体颜色
     */
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    [titleTextAttributes setValue:MXT_NAV_TITLE_FONT forKey:NSFontAttributeName];
    [titleTextAttributes setValue:MXT_NAV_TITLE_COLOR forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    
    /**
     *  UIBarButtonItem默认主题颜色
     */
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
}

/**
 *  替换掉系统的右滑返回手势
 */
- (void)replaceInteractivePopGestureRecognizer
{
    UIView *targetView = self.interactivePopGestureRecognizer.view;
    UIPanGestureRecognizer *popGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    popGestureRecognizer.delegate = self;
    popGestureRecognizer.maximumNumberOfTouches = 1;
    [targetView addGestureRecognizer:popGestureRecognizer];
    
    _navigationTransition = [[MXTNavigationTransition alloc] initWithNavigationController:self];
    _navigationTransition.delegate = self;
    [popGestureRecognizer addTarget:_navigationTransition action:@selector(handleNavigationControllerInteractivePop:)];
    [self setPopGestureRecognizer:popGestureRecognizer];
    
    /**
     *  全屏Pop手势默认启用
     */
    self.interactivePopGestureRecognizerEnabled = YES;
    
    /**
     *  将系统自带的导航栏返回手势禁用掉
     */
    [self.interactivePopGestureRecognizer setEnabled:NO];
}

- (void)setInteractivePopGestureRecognizerEnabled:(BOOL)interactivePopGestureRecognizerEnabled
{
    BOOL isRootViewController = (self.viewControllers.count == 1);
    self.popGestureRecognizer.enabled = (!isRootViewController && interactivePopGestureRecognizerEnabled);
    
    _interactivePopGestureRecognizerEnabled = interactivePopGestureRecognizerEnabled;
}

#pragma mark - UIStatusBar Common

/**
 *  状态栏样式
 */
- (nullable UIViewController *)childViewControllerForStatusBarStyle
{
    return self.visibleViewController;
}

/**
 *  状态栏是否隐藏
 */
- (nullable UIViewController *)childViewControllerForStatusBarHidden
{
    return self.visibleViewController;
}

#pragma mark - Override Method

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count) {
        if (!viewController.navigationItem.hidesBackButton) {
            UIImage *image = [UIImage imageNamed:@"mxt_nav_back_image.png"];
            UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemEvent:)];
            viewController.navigationItem.leftBarButtonItem = leftBarButtonItem;
        }
        
        /**
         *  push的时候控制是否隐藏TabBar
         */
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)leftBarButtonItemEvent:(UIBarButtonItem *)item
{
    [self popViewControllerAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

/**
 *  此代理方法为处理全屏Pop手势是否可用的首调方法
 *  在此方法中可以根据touch中的view类型来设置手势是否可用
 *  比如：界面中触摸到了按钮，则禁止使用手势
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    UIView *touchView = [touch view];
    if ([touchView isMemberOfClass:[UIButton class]] ||
        [touchView isKindOfClass:[UINavigationBar class]])
    {
        return NO;
    }
    
    return self.interactivePopGestureRecognizerEnabled;
}

/**
 *  当方法gestureRecognizer:shouldReceiveTouch:返回的值为NO，此方法将不再被调用
 *  当此方法被调用时，全屏Pop手势是否可用要根据四个情况来确定
 *
 *  第一种情况：当前控制器为根控制器了，全屏Pop手势手势不可用
 *  第二种情况：如果导航栏Push、Pop动画正在执行（私有属性）时，全屏pop手势不可用
 *  第三种情况：手势是上下移动方向，全屏Pop手势不可用
 *  第四种情况：手势是右往左移动方向，全屏Pop手势不可用
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint vTranslationPoint = [recognizer translationInView:recognizer.view];
    if (fabs(vTranslationPoint.x) > fabs(vTranslationPoint.y)) { //左右滑动
        BOOL isRootViewController = (self.viewControllers.count == 1);
        BOOL isTransitioning = [[self valueForKey:@"_isTransitioning"] boolValue];
        BOOL isPanPortraitToLeft = (vTranslationPoint.x < 0);
        return !isRootViewController && !isTransitioning && !isPanPortraitToLeft;
    }
    
    return NO;
}

#pragma mark - MXTNavigationTransitionDelegate

/**
 *  导航栏将要显示某个viewController时调用
 *
 *  @param navigationController 导航栏
 *  @param viewController       将要显示的viewController
 *  @param animated             是否启用动画
 */
- (void)mxt_navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    /* 在这里可以加上自己的处理代码 */
    // ......
}

/**
 *  导航栏完成显示某个viewController时调用
 *
 *  @param navigationController 导航栏
 *  @param viewController       将要显示的viewController
 *  @param animated             是否启用动画
 */
- (void)mxt_navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    /* 在这里可以加上自己的处理代码 */
    // ......
}

@end
