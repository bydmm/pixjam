//
//  emotoStartViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-3-14.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "emotoStartViewController.h"

@implementation emotoStartViewController
@synthesize player;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self playMyVedio];
    [self performSelector:@selector(playMyVedio) withObject:nil afterDelay:2];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//handleOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation：%d",interfaceOrientation);
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
//

-(void)playMyVedio{
    //路径的设置，这里要注意，不要用[NSURL urlwithstring],还要去确保路径的正确
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath;
    if(iPhone5){
        moviePath = [bundle pathForResource:@"iphone5" ofType:@"mp4"];
    }else{
        moviePath = [bundle pathForResource:@"iphone4" ofType:@"mp4"];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    //很重要的一点是在头文件里已经把player变为属性了，@property（nonamaic,strong），如果不写为属性就会黑屏，目前不知道为什么
    player =[[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    player.controlStyle=MPMovieControlStyleNone;
    player.view.frame = self.view.frame;
    [self.view addSubview: player.view];
    [player setFullscreen:YES animated:NO];
    [player play];
    
    [self setNsnot];
}

-(void)setNsnot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    [player setFullscreen:NO animated:NO];
    [player.view removeFromSuperview];
    [self performSegueWithIdentifier:@"gotomain" sender:self];
}



@end
