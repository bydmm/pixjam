//
//  PhotoViewController.h
//  e-moto
//
//  Created by 程南 on 13-2-18.
//  Copyright (c) 2013年 e-moto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
@interface PhotoViewController : UIViewController<MFMailComposeViewControllerDelegate,FBLoginViewDelegate,UITextViewDelegate>
{
    BOOL canShareAnyhow;
    NSString *shareWay;
    BOOL needmask;
}
@property (weak, nonatomic) IBOutlet UITextView *statusMessage;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (retain, nonatomic) UIImage *photoImage;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@property (weak, nonatomic) IBOutlet UIButton *twitterbtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookbtn;
@property (weak, nonatomic) IBOutlet UIButton *emailbtn;
@property (weak, nonatomic) IBOutlet UIButton *tumlrbtn;


@end
