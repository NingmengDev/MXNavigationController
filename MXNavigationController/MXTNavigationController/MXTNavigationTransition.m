//
//  MXTNavigationTransition.m
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import "MXTNavigationTransition.h"

@interface MXTNavigationTransition () <UINavigationControllerDelegate>

@property (weak, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation MXTNavigationTransition

/**
 *  初始化
 *
 *  @param navigationController 对应导航栏控制器
 *
 *  @return 实例
 */
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        self.navigationController = navigationController;
        self.navigationController.delegate = self;
    }
    return self;
}

/**
 *  Pop手势响应方法
 *
 *  @param recognizer Pop手势
 */
- (void)handleNavigationControllerInteractivePop:(UIPanGestureRecognizer *)recognizer
{
    /**
     *  手指在视图中的位置与视图宽度比例作为Pop的进度
     */
    CGFloat progress = [recognizer translationInView:recognizer.view].x / recognizer.view.bounds.size.width;
    
    /**
     *  稳定进度区间，让它在0.0（未完成）～ 1.0（已完成）之间
     */
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        /**
         *  手势开始，新建一个监控对象
         */
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        /**
         *  告诉控制器开始执行Pop的动画
         */
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        /**
         *  更新手势的完成进度
         */
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        /**
         *  手势结束时如果进度大于一半，那么就完成Pop操作，否则重新来过
         */
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}

#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    /**
     *  如果是自定义的Pop动画对象，那么就返回interactivePopTransition来监控动画完成度
     */
    if ([animationController isKindOfClass:[MXTNavigationTransitionPopAnimation class]]) {
        return self.interactivePopTransition;
    }
    
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    /**
     *  如果当前执行的是Pop操作，就返回自定义的Pop动画对象
     */
    if (operation == UINavigationControllerOperationPop) {
        return [MXTNavigationTransitionPopAnimation new];
    }
    
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mxt_navigationController:willShowViewController:animated:)]) {
        [self.delegate mxt_navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    /**
     *  解决回到导航栏根控制器时，触发Pop手势后，再执行Push时会出现卡死的情况
     */
    if ([navigationController respondsToSelector:NSSelectorFromString(@"popGestureRecognizer")]) {
        UIGestureRecognizer *popGestureRecognizer = [navigationController valueForKey:@"popGestureRecognizer"];
        if (popGestureRecognizer) {
            BOOL interactivePopGestureRecognizerEnabled = YES;
            if ([navigationController respondsToSelector:NSSelectorFromString(@"interactivePopGestureRecognizerEnabled")]) {
                interactivePopGestureRecognizerEnabled = [[navigationController valueForKey:@"interactivePopGestureRecognizerEnabled"] boolValue];
            }
            BOOL isRootViewController = (viewController == navigationController.viewControllers.firstObject);
            popGestureRecognizer.enabled = (!isRootViewController && interactivePopGestureRecognizerEnabled);
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mxt_navigationController:didShowViewController:animated:)]) {
        [self.delegate mxt_navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

@end

#pragma mark - MXTNavigationTransitionPopAnimation

@implementation MXTNavigationTransitionPopAnimation

#define kPopAnimation_FromVC_ShadowOffset_Width (-0.4f)
#define kPopAnimation_FromVC_ShadowRadius 3.0f
#define kPopAnimation_FromVC_ShadowOpacity 0.3f
#define kPopAnimation_ToVC_Move_Ratio_Of_Width 0.3f

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    /**
     *  获取动画来自的那个控制器
     */
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    fromViewController.view.layer.shadowOffset = CGSizeMake(kPopAnimation_FromVC_ShadowOffset_Width, 0.0);
    fromViewController.view.layer.shadowRadius = kPopAnimation_FromVC_ShadowRadius;
    fromViewController.view.layer.shadowOpacity = kPopAnimation_FromVC_ShadowOpacity;
    
    /**
     *  获取转场到的那个控制器
     */
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.transform = CGAffineTransformMakeTranslation(-toViewController.view.frame.size.width * kPopAnimation_ToVC_Move_Ratio_Of_Width, 0.0);
    
    /**
     *  转场动画是两个控制器视图时间的动画，需要一个containerView来作为一个“舞台”，让动画执行
     */
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    /**
     *  动画执行时间
     */
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    /**
     *  执行动画，我们让fromVC的视图移动到屏幕最右侧
     */
    [UIView animateWithDuration:duration animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0.0);
        toViewController.view.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        /**
         *  当你的动画执行完成，这个方法必须要调用，否则系统会认为你的其余任何操作都在动画执行过程中。
         */
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
