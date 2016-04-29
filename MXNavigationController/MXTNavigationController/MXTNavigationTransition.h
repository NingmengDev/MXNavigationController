//
//  MXTNavigationTransition.h
//  MXNavigationController
//
//  Created by 韦纯航 on 16/4/30.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@protocol MXTNavigationTransitionDelegate <NSObject>

@optional
- (void)mxt_navigationController:(UINavigationController *)navigationController
          willShowViewController:(UIViewController *)viewController
                        animated:(BOOL)animated;

- (void)mxt_navigationController:(UINavigationController *)navigationController
           didShowViewController:(UIViewController *)viewController
                        animated:(BOOL)animated;

@end

@interface MXTNavigationTransition : NSObject

@property (assign, nonatomic) id <MXTNavigationTransitionDelegate> delegate;

/**
 *  初始化
 *
 *  @param navigationController 对应导航栏控制器
 *
 *  @return 实例
 */
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

/**
 *  Pop手势响应方法
 *
 *  @param recognizer Pop手势
 */
- (void)handleNavigationControllerInteractivePop:(UIPanGestureRecognizer *)recognizer;

@end


/**
 *  Pop动画类
 */
@interface MXTNavigationTransitionPopAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@end
