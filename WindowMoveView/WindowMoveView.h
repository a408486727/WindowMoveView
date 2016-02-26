//
//  MoveView.h
//  UISnapBehaviorTest
//
//  Created by xuchuanqi on 16/1/8.
//  Copyright © 2016年 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WindowMoveViewDelegate;

typedef NS_ENUM(NSUInteger, Corner)
{
    CornerRightTop = 1,
    CornerLeftTop,
    CornerRightBottom,
    CornerLeftBottom,
};

@interface WindowMoveView : UIView

@property(nonatomic, readonly)UIView *containerView;

@property (nonatomic, weak) id <WindowMoveViewDelegate> delegate;
/**
 *  default YES
 */
@property(nonatomic)BOOL isCanMove;
/**
 *  default NO
 */
@property(nonatomic)BOOL isDynamic;

@property(nonatomic)Corner corner;

- (instancetype)initWithContainerView:(UIView *)containerView WithSize:(CGSize)size;

- (void)showAtDefaultCorner:(Corner)corner;

- (void)dismissInWindow;

@end


@protocol WindowMoveViewDelegate <NSObject>
@optional
- (void)windowMoveViewWillStartPictureInPicture:(WindowMoveView *)windowMoveView;

- (void)windowMoveViewDidStartPictureInPicture:(WindowMoveView *)windowMoveView;

- (void)windowMoveViewWillStopPictureInPicture:(WindowMoveView *)windowMoveView;

- (void)windowMoveViewDidStopPictureInPicture:(WindowMoveView *)windowMoveView;

@end