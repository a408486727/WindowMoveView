//
//  MoveView.m
//  UISnapBehaviorTest
//
//  Created by xuchuanqi on 16/1/8.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import "WindowMoveView.h"
#import "Aspects.h"

#define ViewWidth self.superview.frame.size.width
#define ViewHeight self.superview.frame.size.height

#define Margin 8
#define FrontViewControllerChanged @"FrontViewControllerChanged"

@interface UIViewController (Front)

- (UIViewController *)frontViewController;

@end

@implementation UIViewController (Front)

- (UIViewController *)frontViewController
{
    if ([self isKindOfClass:[UINavigationController class]])
    {
        return [((UINavigationController *)self).topViewController frontViewController];
    }
    else if ([self isKindOfClass:[UITabBarController class]])
    {
        return [((UITabBarController *)self).selectedViewController frontViewController];
    }
    else if (self.navigationController && self != self.navigationController.visibleViewController)
    {
        return [self.navigationController.visibleViewController frontViewController];
    }
    else if (self.presentedViewController)
    {
        return [self.presentedViewController frontViewController];
    }
    else
    {
        return self;
    }
}
@end

@interface WindowMoveView()<UIDynamicItem>

@property(nonatomic)UIDynamicAnimator *animator;
@property(nonatomic)UIPanGestureRecognizer *panGR;
@end

@implementation WindowMoveView

+ (void)load
{
    Class transitionView = NSClassFromString(@"UITransitionView");
    Class wrapperView = NSClassFromString(@"UIViewControllerWrapperView");
    SEL selector = NSSelectorFromString(@"addSubview:");
    [transitionView aspect_hookSelector:selector
                   withOptions:AspectPositionAfter
                    usingBlock:^(id<AspectInfo> info){
                        [[NSNotificationCenter defaultCenter] postNotificationName:FrontViewControllerChanged object:nil];
                    }error:nil];
    [wrapperView aspect_hookSelector:selector
                         withOptions:AspectPositionAfter
                          usingBlock:^(id<AspectInfo> info){
                              [[NSNotificationCenter defaultCenter] postNotificationName:FrontViewControllerChanged object:nil];
                          }error:nil];
}

- (instancetype)initWithContainerView:(UIView *)containerView WithSize:(CGSize)size;
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        
        _containerView = containerView;
        [self addSubview:containerView];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:0 metrics:nil views:@{@"containerView":containerView}]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|" options:0 metrics:nil views:@{@"containerView":containerView}]];
        
        _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
        [self addGestureRecognizer:_panGR];
        
        [self addNotificationObserver];
        
        self.isCanMove = YES;
        self.isDynamic = NO;
    }
    return self;
}

- (void)setCorner:(Corner)corner
{
    _corner = corner;
    [self movetoCorner:corner];
}

- (void)setIsCanMove:(BOOL)isCanMove
{
    _isCanMove = isCanMove;
    _panGR.enabled = isCanMove;
}

- (void)showAtDefaultCorner:(Corner)corner;
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];

    self.center = [self pointAtCorner:corner];
    self.corner = corner;
    
    if (self.isDynamic) {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    }
}

- (void)dismissInWindow
{
    [self.animator removeAllBehaviors];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frontViewControllerChanged) name:FrontViewControllerChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frontViewControllerChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frontViewControllerChanged) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)moveView:(UIPanGestureRecognizer *)pan
{
    CGPoint toPoint = [pan locationInView:self.superview];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self.animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateChanged:
            self.center = toPoint;
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.corner = [self cornerWithPoint:self.center];
            break;
        default:
            break;
    }
}

- (void)frontViewControllerChanged
{
    static BOOL isrunning = NO;
    if (isrunning) return;
    isrunning = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self movetoCorner:self.corner];
        isrunning = NO;
    });
}

- (void)movetoCorner:(Corner)moveCorner
{
    CGPoint cornerPoint = [self pointAtCorner:moveCorner];
    
    if (self.isDynamic)
    {
        [self.animator removeAllBehaviors];
        UISnapBehavior *behavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:cornerPoint];
        behavior.damping = 1;
        [self.animator addBehavior:behavior];
    }else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.center = cornerPoint;
        }];
    }
}

- (Corner)cornerWithPoint:(CGPoint)point
{
    if (point.x < ViewWidth/2)
    {
        if (point.y < ViewHeight/2)
        {
            return CornerLeftTop;
        }else
        {
            return CornerLeftBottom;
        }
    }else
    {
        if (point.y < ViewHeight/2)
        {
            return CornerRightTop;
        }else
        {
            return CornerRightBottom;
        }
    }
}

- (CGPoint)pointAtCorner:(Corner)corner
{
    CGPoint cornerPoint;
    switch (corner) {
        case CornerLeftTop:
            cornerPoint.x = [self leftLayoutX];
            cornerPoint.y = [self topLayoutY];
            break;
        case CornerRightTop:
            cornerPoint.x = [self rightLayoutX];
            cornerPoint.y = [self topLayoutY];
            break;
        case CornerLeftBottom:
            cornerPoint.x = [self leftLayoutX];
            cornerPoint.y = [self bottomLayoutY];
            break;
        case CornerRightBottom:
            cornerPoint.x = [self rightLayoutX];
            cornerPoint.y = [self bottomLayoutY];
            break;
        default:
            break;
    }
    return cornerPoint;
}

- (CGFloat)leftLayoutX
{
    return (Margin + self.frame.size.width/2);
}

- (CGFloat)rightLayoutX
{
    return (ViewWidth - Margin - self.frame.size.width/2);
}

- (CGFloat)topLayoutY
{
    UIViewController *frontViewController = [[[[UIApplication sharedApplication] keyWindow] rootViewController] frontViewController];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow convertRect:frontViewController.view.frame fromWindow:keyWindow];
    CGFloat top = rect.origin.y + frontViewController.topLayoutGuide.length;
    return (top + Margin + self.frame.size.height/2);
}

- (CGFloat)bottomLayoutY
{
    UIViewController *frontViewController = [[[[UIApplication sharedApplication] keyWindow] rootViewController] frontViewController];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow convertRect:frontViewController.view.frame fromWindow:keyWindow];
    CGFloat buttom = (ViewHeight - rect.origin.y - rect.size.height) + frontViewController.bottomLayoutGuide.length;

    return (ViewHeight - buttom - Margin - self.frame.size.height/2);
}

@end



