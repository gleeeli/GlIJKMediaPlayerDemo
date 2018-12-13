//
//  GlIJKPlayer.m
//  GlIJKMediaPlayerDemo
//
//  Created by gleeeli on 2018/12/12.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import "GlIJKPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface GlIJKPlayer()
@property (atomic, retain) id <IJKMediaPlayback> player;
@property (nonatomic, assign) BOOL isTrackIng;
@end

@implementation GlIJKPlayer

- (void)initBaseInfo {
    [super initBaseInfo];
    
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#else
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = NO;
    
//    self.view.autoresizesSubviews = YES;
    [self.backView addSubview:self.player.view];
    
    [self installMovieNotificationObservers];
    
    [self.player prepareToPlay];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.player.view.frame = self.backView.bounds;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stop];
    //[self.player shutdown];
}

- (void)refreTrackTime {
    NSLog(@"play time:%f",self.player.currentPlaybackTime);
    [self trackTime:self.player.currentPlaybackTime];
    
    if (self.isPlaying) {
        self.isTrackIng = YES;
        [self performSelector:@selector(refreTrackTime) withObject:nil afterDelay:1.0];
    }else {
        self.isTrackIng = NO;
    }
}

- (void)refreshBuffProgress {
    NSLog(@"buff:%ld",(long)self.player.bufferingProgress);
    [self updateBuffValue:self.player.bufferingProgress];
    
    if (self.player.isSeekBuffering) {
        [self performSelector:@selector(refreshBuffProgress) withObject:nil afterDelay:1.0];
    }
}

#pragma mark 监听通知
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    [self refreshBuffProgress];
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
        [self changeEvent:GlPlayerEventKeepUp value:nil];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
        [self changeEvent:GlPlayerEventKeepUp value:nil];
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }

    [self updateControlViewInfoWithDuration:self.player.duration];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:{
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
        }
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:{
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
        }
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            if (!self.isTrackIng) {
                [self refreTrackTime];
            }
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            [self changeEvent:GlPlayerEventBuffer value:nil];
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

//MARK: SBControlViewDelegate
-(void)controlView:(GlControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    [super controlView:controlView pointSliderLocationWithCurrentValue:value];
    NSLog(@"curent:%f",value);
    CGFloat seekTime = value;//self.player.duration *
    self.player.currentPlaybackTime = seekTime;
    NSLog(@"seektoTime:%f",seekTime);
}

-(void)controlView:(GlControlView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    [super controlView:controlView draggedPositionWithSlider:slider];
    
    self.player.currentPlaybackTime = slider.value;
}

- (void)dealloc {
    [self removeMovieNotificationObservers];
}
@end
