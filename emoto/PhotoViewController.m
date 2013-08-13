//
//  PhotoViewController.m
//  e-moto
//
//  Created by 程南 on 13-2-18.
//  Copyright (c) 2013年 e-moto. All rights reserved.
//

#import "PhotoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
#import "TMTumblrAppClient.h"
#import "TMAPIClient.h"
#import "TMTumblrAppClient.h"


@interface PhotoViewController()

@property (nonatomic, strong) UIDocumentInteractionController *interactionController;

@end

@implementation PhotoViewController
@synthesize photo;
@synthesize photoImage;

- (void)viewDidLoad
{
    twitter = NO;
    facebook = NO;
    email = NO;
    needmask = YES;
    [super viewDidLoad];
    [self clickToHideKeyboard];
    self.photo.image = self.photoImage;
    [self performSelector:@selector(doHighlight:) withObject:self.bubblebtn afterDelay:0];
    self.statusMessage.placeholder = @"Write a Caption...";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 320, 45)];
    [btn setTitle:@"Close" forState:UIControlStateNormal];
    self.statusMessage.inputAccessoryView = btn;
    [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self forcerotate];
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)forcerotate
{
    NSLog(@"---forcerotate---");
    UIViewController *vc = [[UIViewController alloc]init];
    [self presentModalViewController:vc animated:NO];
    [self dismissModalViewControllerAnimated:NO];
}

- (void)viewDidUnload {
    [self setPhoto:nil];
    [self setStatusMessage:nil];
    [self setFacebookbtn:nil];
    [self setTwitterbtn:nil];
    [self setEmailbtn:nil];
    [self setBubblebtn:nil];
    [self setStatusMessage:nil];
    [super viewDidUnload];
}

//textview
-(void)clickToHideKeyboard
{
    UITapGestureRecognizer *oneclick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneclick)];
    [[self view] addGestureRecognizer:oneclick];
}

-(void)oneclick
{
    [self.view endEditing:YES];
}

//checkbulle
- (IBAction)close:(id)sender {
    [self.view endEditing:YES];
}

//checkbulle
- (IBAction)bulle:(id)sender {
    if (needmask == YES) {
        needmask = NO;
        [self.bubblebtn setTitle:@"Bubble - NO" forState:UIControlStateNormal];
    }else{
        [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
        needmask = YES;
        [self.bubblebtn setTitle:@"Bubble - YES" forState:UIControlStateNormal];
    }
}


- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//sendmessage

- (IBAction)sendmessage:(id)sender {
    [self shareMessageInRightWay];
}

-(void)lightornot:(UIButton *)button
{
    if (button == self.twitterbtn) {
        if (twitter == YES) {
            twitter = NO;
            button.highlighted = NO;
        }else{
            twitter = YES;
            [self performSelector:@selector(doHighlight:) withObject:button afterDelay:0];
        }
    }
    if (button == self.facebookbtn) {
        if (facebook == YES) {
            facebook = NO;
            button.highlighted = NO;
        }else{
            facebook = YES;
            [self performSelector:@selector(doHighlight:) withObject:button afterDelay:0];
        }
    }
    if (button == self.emailbtn) {
        if (email == YES) {
            email = NO;
            button.highlighted = NO;
        }else{
            email = YES;
            [self performSelector:@selector(doHighlight:) withObject:button afterDelay:0];
        }
    }
    if (button == self.instagrambtn) {
        if (instagram == YES) {
            instagram = NO;
            button.highlighted = NO;
        }else{
            instagram = YES;
            [self performSelector:@selector(doHighlight:) withObject:button afterDelay:0];
        }
    }

}

-(void)shareMessageInRightWay
{
    if (self.facebookbtn.highlighted == YES) {
        [self sharetofacebook];
    }
    else if(self.twitterbtn.highlighted == YES) {
        [self sendToTwitter];
    }
    else if(self.emailbtn.highlighted == YES) {
        [self performSelector:@selector(sharetoemail) withObject:nil afterDelay:0.5];
    }
    else if(self.instagrambtn.highlighted == YES) {
        [self performSelector:@selector(sharetoinstagram) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - email
- (IBAction)clickemail:(UIButton *)sender {
    [self lightornot:sender];
}

-(void)sharetoemail
{
    email = NO;
    self.emailbtn.highlighted = NO;
    NSLog(@"email");
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Having a party with pixjam!"];
        [mailViewController setMessageBody:self.statusMessage.text isHTML:NO];
        NSData *data = UIImageJPEGRepresentation(self.photo.image, 1);
        [mailViewController addAttachmentData:data mimeType:@"image/jpeg" fileName:@"photo.jpg"];
        [self presentModalViewController:mailViewController animated:YES];
    }
    else {
        
        NSLog(@"----emailbug----");
        
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissModalViewControllerAnimated:YES];
    [self shareMessageInRightWay];
}

#pragma mark - Twitter

- (IBAction)clickTweet:(id)sender {
    if ([self canTweetStatus] == YES) {
        [self lightornot:sender];
    }
}

- (BOOL)canTweetStatus {
    if ([TWTweetComposeViewController canSendTweet]) {
        return YES;
    } else {
        NSString *message = @"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup";
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

-(void)GoToSetting
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
}

-(void)sendToTwitter
{
    self.twitterbtn.highlighted = NO;
    twitter = NO;
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:self.statusMessage.text];
    [message appendString:@" @pixjam #pixjam"];
    NSLog(@"message:%@",message);
    [tweetViewController setInitialText:message];
    [tweetViewController addImage:self.photo.image];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.
                
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                [SVProgressHUD dismissWithSuccess:@"Send"];
                break;
            default:
                break;
        }
        
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
        
        [self shareMessageInRightWay];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];
}


#pragma mark - facebook

- (IBAction)clickfacebook:(id)sender {
    NSLog(@"FBSession.activeSession.state : %d",FBSession.activeSession.state);
    if (FBSession.activeSession.state > 10)
    {
        [self lightornot:sender];
    }else{
        [self openSession];
    }
}

-(void)sharePhotoWithMessage
{
    [SVProgressHUD showWithStatus:@"Share to facebook"];
    NSMutableString *message = [[NSMutableString alloc] initWithString:self.statusMessage.text];
    [message appendString:@"@pixjam"];

    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:message forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(self.photo.image) forKey:@"picture"];
    //_shareToFbBtn.enabled = NO; //for not allowing multiple hits
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         if (error)
         {
             NSLog(@"error: %@",error);
             [SVProgressHUD dismissWithError:@"error"];
             //showing an alert for failure
             //[self alertWithTitle:@"Facebook" message:@"Unable to share the photo please try later."];
         }
         else
         {
             [SVProgressHUD dismissWithSuccess:@"Success"];
             //showing an alert for success
             //[UIUtils alertWithTitle:@"Facebook" message:@"Shared the photo successfully"];
         }
         //_shareToFbBtn.enabled = YES;
         [self shareMessageInRightWay];
     }];
}

-(void)sharetofacebook{
    facebook = NO;
    self.facebookbtn.highlighted = NO;
    [self.view endEditing:YES];
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream",nil];
        [[FBSession activeSession] reauthorizeWithPublishPermissions:permissions
                                                     defaultAudience:FBSessionDefaultAudienceEveryone
                                                   completionHandler:^(FBSession *session, NSError *error) {
                                                       [self sharePhotoWithMessage];
                                                   }];
    }
    else if (FBSession.activeSession.state > 512 )
    {
        [self sharePhotoWithMessage];
    }
    else{
        [self performSegueWithIdentifier:@"facebooklogin" sender:self];
    }
}


#pragma mark - instagram

- (IBAction)instagram:(id)sender {
    [self lightornot:sender];
}

-(void)sharetoinstagram
{
    self.instagrambtn.highlighted = NO;
    NSMutableString *message = [[NSMutableString alloc] initWithString:self.statusMessage.text];
    [message appendString:@"@pixjam #pixjam"];
    [self sharetoinstagram:self.photoImage withMessage:message];
}

-(void)sharetoinstagram:(UIImage *)image withMessage:(NSString *)message
{
    UIImage * screenshot = image;
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Screenshot.igo"];
    
    // Write image to PNG
    [UIImageJPEGRepresentation(screenshot, 1.0) writeToFile:savePath atomically:YES];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //imageToUpload is a file path with .ig file extension
        documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        documentInteractionController.UTI = @"com.instagram.exclusivegram";
        documentInteractionController.delegate = self;
        
        documentInteractionController.annotation = [NSDictionary dictionaryWithObject:message forKey:@"InstagramCaption"];
        if(IOS6_OR_LATER)
        {
            [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
        else
        {
            [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view.window animated:YES];
        }
    }
}


//handleOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream",nil];
            [[FBSession activeSession] reauthorizeWithPublishPermissions:permissions
                                                         defaultAudience:FBSessionDefaultAudienceEveryone
                                                       completionHandler:^(FBSession *session, NSError *error) {
                                                           [self lightornot:self.facebookbtn];
                                                       }];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}





@end
