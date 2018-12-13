//
//  GlPlayer.m
//  GlIJKMediaPlayerDemo
//
//  Created by 小柠檬 on 2018/12/12.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import "GlPlayer.h"

@interface GlPlayer()<UIGestureRecognizerDelegate>
//底部控制视图
@property (nonatomic,strong) GlControlView *controlView;
//添加标题
@property (nonatomic,strong) UILabel *titleLabel;
//加载动画
@property (nonatomic,strong) UIActivityIndicatorView *activityIndeView;
//暂停和播放
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, assign) GlCShowStatus cShowStatus;
@property (nonatomic, assign) BOOL isAnimationing;
//当前子视图是否隐藏
@property (nonatomic, assign) BOOL curSubIsHidden;
//播放状态
@property (nonatomic,assign,readonly) GlPlayerStatus status;
//自动暂停的 需要自动播放
@property (nonatomic, assign) BOOL pNeedAutoPlay;
@end

//统计从上一次归零后经过5秒就隐藏其它控件
static NSInteger playingSecond = 0;

@implementation GlPlayer
//MARK:实例化
- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        [self initBaseInfo];
        [self setupPlayerUI];
    }
    return self;
}

- (void)initBaseInfo {
    [self addNotificationCenter];
}

//MARK:添加消息中心
-(void)addNotificationCenter{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

/**
 更新总时长相关信息

 @param duration 总时长
 */
- (void)updateControlViewInfoWithDuration:(CGFloat)duration {
    self.controlView.totalTime = [self convertTime:duration];
    self.controlView.minValue = 0;
    self.controlView.maxValue = duration;
}

/**
 跟踪播放进度

 @param currentTime 当前播放到的时间
 */
- (void)trackTime:(CGFloat)currentTime {
    self.controlView.value = currentTime;
    self.controlView.currentTime = [self convertTime:self.controlView.value];
    if (playingSecond >= 5) {
        self.cShowStatus = GlCShowStatusHiddenAll;
    }
    playingSecond += 1;
}

/**
 缓存改变
 */
- (void)updateBuffValue:(CGFloat)bufferValue {
    self.controlView.bufferValue = bufferValue;
}

//MARK: 设置界面 在此方法下面可以添加自定义视图，和删除视图
- (void)setupPlayerUI {
    //防止约束报错
    if (self.frame.size.width == 0) {
        CGRect rect = self.frame;
        rect.size.width = kScreenWidth;
        self.frame = rect;
    }
    
    [self.activityIndeView startAnimating];
    //增加一层视图 处理全屏问题
    [self addBackView];
    //添加标题
    [self addTitle];
    //添加点击事件
    [self addGestureEvent];
    //添加播放和暂停按钮
    [self addPauseAndPlayBtn];
    //添加控制视图
    [self addControlView];
    //添加加载视图
    [self addLoadingView];
    //初始化时间
    [self initTimeLabels];
    
    self.cShowStatus = GlCShowStatusHiddenAll;
}

- (void)addBackView {
    self.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
}

//初始化时间
-(void)initTimeLabels {
    self.controlView.currentTime = @"00:00";
    self.controlView.totalTime = @"00:00";
}

//添加加载视图
-(void)addLoadingView {
    [self.backView addSubview:self.activityIndeView];
    [self.activityIndeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@40);
        make.center.mas_equalTo(self.backView);
    }];
}

//添加标题
-(void)addTitle {
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(12);
        make.right.equalTo(self.backView).offset(-12);
        make.top.mas_equalTo(self.backView).offset(12);
    }];
}

//添加点击事件
-(void)addGestureEvent{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

#pragma mark 点击空白
-(void)handleTapAction:(UITapGestureRecognizer *)gesture{
    if (self.cShowStatus == GlCShowStatusShowAll) {
        if (self.isPlaying) {
            self.cShowStatus = GlCShowStatusHiddenAll;
            
        }else {
            self.cShowStatus = GlCShowStatusShowCenterPPBtn;
        }
    }else {
        self.cShowStatus = GlCShowStatusShowAll;
    }
    playingSecond = 0;
}

//添加播放和暂停按钮
-(void)addPauseAndPlayBtn{
    [self.backView addSubview:self.playOrPauseBtn];
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backView);
        make.width.height.mas_equalTo(50);
    }];
}

//添加控制视图
-(void)addControlView{
    
    [self.backView addSubview:self.controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.backView);
        make.height.mas_equalTo(@44);
    }];
    [self layoutIfNeeded];
}

- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
    }
    
    return _backView;
}

//懒加载ActivityIndicateView
-(UIActivityIndicatorView *)activityIndeView{
    if (!_activityIndeView) {
        _activityIndeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndeView.hidesWhenStopped = YES;
    }
    return _activityIndeView;
}

//懒加载标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor colorWithWhite:0 alpha:0.8];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

//懒加载控制视图
-(GlControlView *)controlView{
    if (!_controlView) {
        _controlView = [[GlControlView alloc]init];
        _controlView.delegate = self;
        _controlView.backgroundColor = [UIColor colorWithRed:2/255.0 green:0 blue:0 alpha:0.5];
        [_controlView.tapGesture requireGestureRecognizerToFail:self.playOrPauseBtn.gestureRecognizers.firstObject];
    }
    return _controlView;
}

- (UIButton *)playOrPauseBtn {
    if (_playOrPauseBtn == nil) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"gl_play_big"] forState:UIControlStateNormal];
        [_playOrPauseBtn setShowsTouchWhenHighlighted:YES];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"gl_pause_big"] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

#pragma mark 设置显示子控件
- (void)setCShowStatus:(GlCShowStatus)cShowStatus {
    if (_cShowStatus  == cShowStatus) {
        return;
    }
    _cShowStatus = cShowStatus;
    switch (cShowStatus) {
        case GlCShowStatusShowAll:
        {
            self.playOrPauseBtn.hidden = NO;
            [self setCommSubViewsIsHide:NO isAnimation:YES];
        }
            break;
        case GlCShowStatusHiddenAll:
        {
            self.playOrPauseBtn.hidden = YES;
            [self setCommSubViewsIsHide:YES isAnimation:YES];
        }
            break;
        case GlCShowStatusShowCenterPPBtn:
        {
            [self setCommSubViewsIsHide:YES isAnimation:YES];
            self.playOrPauseBtn.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)setCommSubViewsIsHide:(BOOL)isHide isAnimation:(BOOL)isAnimation{
    
    if (isAnimation) {
        if (self.isAnimationing && self.curSubIsHidden == isHide) {
            return;
        }
        self.curSubIsHidden = isHide;
        self.isAnimationing = YES;
        [UIView animateWithDuration:0.2 animations:^{
            if (isHide) {
                [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.backView).offset(12);
                    make.right.equalTo(self.backView).offset(-12);
                    make.bottom.mas_equalTo(self.backView);
                }];
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.top.mas_equalTo(self.backView);
                    make.height.mas_equalTo(@44);
                }];
            }else {//显示动画
                
                self.controlView.hidden = NO;
                self.titleLabel.hidden = NO;
                [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.backView).offset(12);
                    make.right.equalTo(self.backView).offset(-12);
                    make.top.mas_equalTo(self.backView).offset(12);
                }];
                
                [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.mas_equalTo(self.backView);
                    make.height.mas_equalTo(@44);
                }];
            }
            [self.titleLabel layoutIfNeeded];
            [self.controlView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isAnimationing = NO;
            
            self.controlView.hidden = isHide;
            self.titleLabel.hidden = isHide;
        }];
    }else {
        self.controlView.hidden = isHide;
        self.titleLabel.hidden = isHide;
    }
}

- (void)playOrPauseBtnClick:(UIButton *)btn {
    [self changeStatusWithSelected:!btn.selected];
}

- (void)changeStatusWithSelected:(BOOL)selected {
    self.playOrPauseBtn.selected = selected;
    self.controlView.playOrPauseBtn.selected = selected;
    
    playingSecond = 0;
    if (selected) {
        [self play];
    }else{
        [self pause];
    }
}

/**
 事件改变
 */
- (void)changeEvent:(GlPlayerEvent)event value:(id)value {
    switch (event) {
        case GlPlayerEventLoadRange:{
            CGFloat bufervalue = [value floatValue];
            //缓存值
            self.controlView.bufferValue = bufervalue;
        }
            break;
        case GlPlayerEventBuffer:{
            _status = GlPlayerStatusBuffering;
            if (!self.activityIndeView.isAnimating) {
                [self.activityIndeView startAnimating];
                self.cShowStatus = GlCShowStatusHiddenAll;
            }
        }
            break;
        case GlPlayerEventKeepUp:{
            NSLog(@"缓冲达到可播放");
            [self.activityIndeView stopAnimating];
            if (!_isPlaying) {//
                self.cShowStatus = GlCShowStatusShowCenterPPBtn;
            }
        }
            break;
        case GlPlayerEventRate:{
            if ([[value objectForKey:NSKeyValueChangeNewKey] integerValue] == 0) {
                _isPlaying = false;
                _status = GlPlayerStatusPlaying;
            }else{
                _isPlaying = true;
                _status = GlPlayerStatusStopped;
            }
        }
            break;
            
        default:
            break;
    }
}

//MARK: SBControlViewDelegate
-(void)controlView:(GlControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    playingSecond = 0;
}

-(void)controlView:(GlControlView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    playingSecond = 0;
}

-(void)controlView:(GlControlView *)controlView withLargeButton:(UIButton *)button{
    playingSecond = 0;
    if (kScreenWidth<kScreenHeight) {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)controlView:(GlControlView *)controlView withPlayOrPauseButton:(UIButton *)button {
    [self playOrPauseBtnClick:self.playOrPauseBtn];
}

//MARK: UIGestureRecognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[GlControlView class]]) {
        return NO;
    }
    return YES;
}

//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

//旋转方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight||orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown){
        //
    }
}

//MARK: *********public*********
- (void)play {

}

- (void)pause {
    
}

- (void)stop {
    
}

//MARK: 处理通知
-(void)willResignActive:(NSNotification *)notification{
    if (_isPlaying && self.pauseWhenAppResignActive) {
        self.pNeedAutoPlay = YES;
        self.cShowStatus = GlCShowStatusShowCenterPPBtn;
        playingSecond = 0;
        [self changeStatusWithSelected:NO];
    }
}

- (void)didBecomeActiveNotification {
    if (self.pNeedAutoPlay && !self.viewControllerDisappear) {
        self.pNeedAutoPlay = NO;
        [self changeStatusWithSelected:YES];
        self.cShowStatus = GlCShowStatusShowAll;
    }
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear {
    _viewControllerDisappear = viewControllerDisappear;
    if (viewControllerDisappear) {//视图消失
        if (self.pauseByEvent) {
            self.pNeedAutoPlay = YES;
            [self changeStatusWithSelected:NO];
        }
    }else {//视图出现
        if (self.pNeedAutoPlay) {
            [self changeStatusWithSelected:YES];
        }
        self.pNeedAutoPlay = NO;
    }
}
-(void)deviceOrientationDidChange:(NSNotification *)notification{
    UIInterfaceOrientation _interfaceOrientation=[[UIApplication sharedApplication]statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
           self.isFullScreen = YES;
            [self.controlView updateConstraintsIfNeeded];
            
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateWithDuration:kTransitionTime delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0. options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [[UIApplication sharedApplication].keyWindow addSubview:self.backView];
                [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow);
                }];
                [self.backView layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        {
            self.isFullScreen = NO;
            [self addSubview:self.backView];
            
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateKeyframesWithDuration:kTransitionTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.insets(UIEdgeInsetsZero);
                }];
                [self layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationUnknown");
            break;
    }
    [self layoutIfNeeded];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
