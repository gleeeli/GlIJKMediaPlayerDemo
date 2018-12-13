//
//  GlPlayer.h
//  GlIJKMediaPlayerDemo
//
//  Created by 小柠檬 on 2018/12/12.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlControlView.h"
#import "GlCommHeader.h"

typedef enum : NSUInteger {
    GlCShowStatusShowAll = 0,
    GlCShowStatusHiddenAll,
    GlCShowStatusShowCenterPPBtn,//只显示中间的按钮
} GlCShowStatus;

#define kTransitionTime 0.2

//播放状态枚举值
typedef NS_ENUM(NSInteger,GlPlayerStatus){
    GlPlayerStatusFailed,
    GlPlayerStatusReadyToPlay,
    GlPlayerStatusUnknown,
    GlPlayerStatusBuffering,
    GlPlayerStatusPlaying,
    GlPlayerStatusStopped,
};

typedef enum : NSUInteger {
    GlPlayerEventUnknow,
    GlPlayerEventKeepUp,//可播放
    GlPlayerEventLoadRange,//监听播放器的下载进度
    GlPlayerEventBuffer,//监听播放器在缓冲数据的状态
    GlPlayerEventRate,//当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
} GlPlayerEvent;

@interface GlPlayer : UIView<GlControlViewDelegate>
@property (nonatomic, strong) UIView *backView;
//当前播放url
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isFullScreen;
//进入后台暂停
@property (nonatomic, assign) BOOL pauseWhenAppResignActive;
//暂停因某些事件 如视图消失
@property (nonatomic, assign) BOOL pauseByEvent;
//视图是否消失
@property (nonatomic, assign) BOOL viewControllerDisappear;

//MARK: *********public*********
- (instancetype)initWithUrl:(NSURL *)url;

- (void)play;

- (void)pause;

- (void)stop;

/**
 初始化一些基本信息
 */
- (void)initBaseInfo;

/**
 构建播放相关UI
 */
- (void)setupPlayerUI;

/**
 更新总时长相关信息
 
 @param duration 总时长
 */
- (void)updateControlViewInfoWithDuration:(CGFloat)duration;

/**
 事件改变
 */
- (void)changeEvent:(GlPlayerEvent)event value:(id)value;

/**
 跟踪播放进度
 
 @param currentTime 当前播放到的时间
 */
- (void)trackTime:(CGFloat)currentTime;

/**
 缓存改变
 */
- (void)updateBuffValue:(CGFloat)bufferValue;
@end
