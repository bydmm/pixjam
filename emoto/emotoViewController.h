//
//  emotoViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-2-19.
//  Copyright (c) 2013年 emoto. All rights reserved.
//
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define flashtime 1.0f
#import <UIKit/UIKit.h>
#import "DirectionMPMoviePlayerViewController.h"
#import "CameraImageHelper.h"

#include <sys/sysctl.h>
#include <mach/mach.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface emotoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    SystemSoundID                 soundID;
    int count;
    NSTimeInterval timeInterval;
    UIImage *photo;
    UIImagePickerController *imagepicker;
    AVCaptureFlashMode flashMode;
    BOOL timerstatus;
    NSTimer *countDowntimer;
    NSArray *hintlist;
    BOOL hasopened;
    UIImage *thelastPhoto;
}
@property (retain, nonatomic)  DirectionMPMoviePlayerViewController *playerView;
@property (retain, nonatomic)  AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIView *flashsettingview;
@property (weak, nonatomic) IBOutlet UIView *avView;
@property (weak, nonatomic) IBOutlet UILabel *countdown;
@property (weak, nonatomic) IBOutlet UILabel *hint;
@property (weak, nonatomic) IBOutlet UIButton *photoBTN;
@property (weak, nonatomic) IBOutlet UIButton *flashBTN;
@property (weak, nonatomic) IBOutlet UISlider *timerslider;
@property (weak, nonatomic) IBOutlet UIView *timeronview;
@property (weak, nonatomic) IBOutlet UIButton *timeroffbtn;
@property (weak, nonatomic) IBOutlet UIView *hintview;
@property (weak, nonatomic) IBOutlet UIImageView *albumbg;
@property (weak, nonatomic) IBOutlet UIImageView *hintbg;
@property (weak, nonatomic) IBOutlet UIImageView *rightbg;
@property (weak, nonatomic) IBOutlet UIButton *camerabtn;

@end
