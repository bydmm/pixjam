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
    needmask = YES;
    [super viewDidLoad];
    [self clickToHideKeyboard];
    self.photo.image = self.photoImage;
    [self performSelector:@selector(doHighlight:) withObject:self.bubblebtn afterDelay:0];
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
    [self setTumlrbtn:nil];
    [self setBubblebtn:nil];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//sendmessage

- (IBAction)sendmessage:(id)sender {
    [self shareMessageInRightWay];
}

-(void)shareMessageInRightWay
{
    NSLog(@"%@",shareWay);
    if ([shareWay isEqual: @"twitter"]) {
        [self sendToTwitter];
    }
    if ([shareWay isEqual: @"facebook"]) {
        [self sharetofacebook];
    }
    if ([shareWay isEqual: @"email"]) {
        [self sharetoemail];
    }
    if ([shareWay isEqual: @"tumblr"]) {
        
    }
}

//choserightshareway

-(void)choserightshareway:(NSString *)way
{
    [self letBtnsNormel];
    shareWay = way;
    if ([way isEqual: @"twitter"]) {
        [self performSelector:@selector(doHighlight:) withObject:self.twitterbtn afterDelay:0];
    }
    if ([way isEqual: @"facebook"]) {
        [self performSelector:@selector(doHighlight:) withObject:self.facebookbtn afterDelay:0];
    }
    if ([way isEqual: @"email"]) {
        [self performSelector:@selector(doHighlight:) withObject:self.emailbtn afterDelay:0];
    }
    if ([way isEqual: @"tumblr"]) {
        [self performSelector:@selector(doHighlight:) withObject:self.tumlrbtn afterDelay:0];
    }
}


-(void)letBtnsNormel
{
    [self.twitterbtn setHighlighted:NO];
    [self.facebookbtn setHighlighted:NO];
    [self.emailbtn setHighlighted:NO];
    [self.tumlrbtn setHighlighted:NO];
}

#pragma mark - email
- (IBAction)emailclick:(id)sender {
    [self choserightshareway:@"email"];
    [self shareMessageInRightWay];
}


-(void)sharetoemail
{
    NSLog(@"email");
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Hi"];
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
}

#pragma mark - Twitter

- (IBAction)clickTweet:(id)sender {
    [self choserightshareway:@"twitter"];
    [self shareMessageInRightWay];
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
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:self.statusMessage.text];
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
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];
}

#pragma mark - tumblr

- (IBAction)clicktumblr:(id)sender {
    
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"ADISJdadsoj2dj38dj29dj38jd9238jdk92djasdjASDaoijsd";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"MGI39kdasdoka3240989ASFjoiajsfomdasd39129ASDAPDOJa";
    
    [[TMAPIClient sharedInstance] authenticate:@"tumblremoto" callback:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void) uploadFiles {
    NSData *data1 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"goback" ofType:@"png"]];
    NSArray *array = [NSArray arrayWithObjects:data1, nil];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TumblrUploadr *tu = [[TumblrUploadr alloc] initWithNSDataForPhotos:array andBlogName:@"supergreatblog.tumblr.com" andDelegate:self andCaption:@"Great Photos!"];
        dispatch_async( dispatch_get_main_queue(), ^{
            [tu signAndSendWithTokenKey:@"ADISJdadsoj2dj38dj29dj38jd9238jdk92djasdjASDaoijsd" andSecret:@"MGI39kdasdoka3240989ASFjoiajsfomdasd39129ASDAPDOJa"];
        });
    });
}

- (void) tumblrUploadr:(TumblrUploadr *)tu didFailWithError:(NSError *)error {
    NSLog(@"connection failed with error %@",[error localizedDescription]);
}
- (void) tumblrUploadrDidSucceed:(TumblrUploadr *)tu withResponse:(NSString *)response {
    NSLog(@"connection succeeded with response: %@", response);
}


#pragma mark - facebook

- (IBAction)clickfacebook:(id)sender {
    [self choserightshareway:@"facebook"];
    if (FBSession.activeSession.state == 513)
    {
        [self shareMessageInRightWay];
    }else{
        [self performSegueWithIdentifier:@"facebooklogin" sender:self];
    }
}

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                     //For this example, ignore errors (such as if user cancels).
                                                 }];
    } else {
        action();
    }
    
}

-(void)sharePhotoWithMessage
{
    [SVProgressHUD showWithStatus:@"Share to facebook"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:self.statusMessage.text forKey:@"message"];
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
     }];
}

-(void)sharetofacebook{
    [self.view endEditing:YES];
    [self sharePhotoWithMessage];
    if (FBSession.activeSession.state == 513)
    {
        [self sharePhotoWithMessage];
    }else{
        [self performSegueWithIdentifier:@"facebooklogin" sender:self];
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




@end
