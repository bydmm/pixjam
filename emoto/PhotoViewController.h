//
//  PhotoViewController.h
//  e-moto
//
//  Created by 程南 on 13-2-18.
//  Copyright (c) 2013年 e-moto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TumblrUploadr.h"
#import "UIPlaceHolderTextView.h"
#define IOS6_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending )  
@interface PhotoViewController : UIViewController<MFMailComposeViewControllerDelegate,FBLoginViewDelegate,UITextViewDelegate,UIDocumentInteractionControllerDelegate>
{
    BOOL canShareAnyhow;
    NSString *shareWay;
    BOOL needmask;
    BOOL twitter;
    BOOL facebook;
    BOOL email;
    BOOL instagram;
    UIDocumentInteractionController *documentInteractionController;
}
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *statusMessage;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (retain, nonatomic) UIImage *photoImage;
@property (retain, nonatomic) NSString *hint;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@property (weak, nonatomic) IBOutlet UIButton *bubblebtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterbtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookbtn;
@property (weak, nonatomic) IBOutlet UIButton *emailbtn;
@property (weak, nonatomic) IBOutlet UIButton *instagrambtn;


@end
