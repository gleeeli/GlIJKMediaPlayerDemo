//
//  GlControlView.h
//  GlVideoPlayer
//
//  Created by gleeeli on 2018/12/11.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GlControlView;
@protocol GlControlViewDelegate <NSObject>
@required
/**
 点击UISlider获取点击点
 
 @param controlView 控制视图
 @param value 当前点击点
 */
-(void)controlView:(GlControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的knob的时间响应代理方法
 */
-(void)controlView:(GlControlView *)controlView draggedPositionWithSlider:(UISlider *)slider;


/**
 拖拽开始
 */
-(void)controlView:(GlControlView *)controlView draggedStartWithSlider:(UISlider *)slider;

/**
 点击放大按钮的响应事件
 */
-(void)controlView:(GlControlView *)controlView withLargeButton:(UIButton *)button;

-(void)controlView:(GlControlView *)controlView withPlayOrPauseButton:(UIButton *)button;
@end

NS_ASSUME_NONNULL_BEGIN

@interface GlControlView : UIView
@property (nonatomic, strong) UIButton *playOrPauseBtn;
//全屏按钮
@property (nonatomic,strong) UIButton *largeButton;
//进度条当前值
@property (nonatomic,assign) CGFloat value;
//最小值
@property (nonatomic,assign) CGFloat minValue;
//最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前时间
@property (nonatomic,copy) NSString *currentTime;
//总时间
@property (nonatomic,copy) NSString *totalTime;
//缓存条当前值
@property (nonatomic,assign) CGFloat bufferValue;
//UISlider手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
//代理方法
@property (nonatomic,weak) id<GlControlViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
