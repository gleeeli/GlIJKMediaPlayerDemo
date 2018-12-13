//
//  ViewController.m
//  GlIJKMediaPlayerDemo
//
//  Created by gleeeli on 2018/12/4.
//  Copyright © 2018年 gleeeli. All rights reserved.
//

#import "ViewController.h"
#import "GlIJKPlayer/GlIJKPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) GlIJKPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *httpurl = @"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4";
    NSString *urlStr = [httpurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    self.player = [[GlIJKPlayer alloc] initWithUrl:url];
    [self.view addSubview:self.player];
    
    CGFloat widht = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = widht / 16.0 * 9;
    self.player.frame = CGRectMake(0, 0, widht, height);
    
//    [self refreTrackTime];
}

- (void)refreTrackTime {
    NSLog(@"play time:");
    
    [self performSelector:@selector(refreTrackTime) withObject:nil afterDelay:1.0];
}


@end
