//
//  emotoStartViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-3-14.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "emotoStartViewController.h"
#import "DirectionMPMoviePlayerViewController.h"
@implementation emotoStartViewController
@synthesize playerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(playMovieAtURL) withObject:nil afterDelay:0.5];
    [self playMovieAtURL];
}

-(void)playMovieAtURL
{
    //路径的设置，这里要注意，不要用[NSURL urlwithstring],还要去确保路径的正确
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath;
    if(iPhone5){
        moviePath = [bundle pathForResource:@"iphone5" ofType:@"mp4"];
    }else{
        moviePath = [bundle pathForResource:@"iphone4" ofType:@"mp4"];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    playerView = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    playerView.view.frame = self.view.frame;//全屏播放（全屏播放不可缺）
    playerView.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;//全屏播放（全屏播放不可缺）
    playerView.moviePlayer.controlStyle=MPMovieControlStyleNone;
    //[self presentMoviePlayerViewControllerAnimated:playerView];
    [self presentModalViewController:playerView animated:NO];
    [playerView.moviePlayer play];
    [self setNsnot];
}

-(void)setNsnot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    [self performSelector:@selector(gotomain) withObject:nil afterDelay:0.5];
}

-(void)gotomain
{
    [self performSegueWithIdentifier:@"gotomain" sender:self];
}


@end
