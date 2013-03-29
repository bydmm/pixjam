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

@implementation PhotoViewController
@synthesize photo;
@synthesize photoImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self clickToHideKeyboard];
    self.photo.image = self.photoImage;
    canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIViewController *c = [[UIViewController alloc]init];
    [self.navigationController pushViewController:c animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
    self.navigationController.navigationBarHidden=NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check to make sure our UI is set up appropriately, depending on if we can tweet or not.
    //[self canTweetStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPhoto:nil];
    [self setStatusMessage:nil];
    [self setFacebookbtn:nil];
    [self setTwitterbtn:nil];
    [self setEmailbtn:nil];
    [self setTumlrbtn:nil];
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

//sendmessage

- (IBAction)sendmessage:(id)sender {
    [self shareMessageInRightWay];
}

-(void)shareMessageInRightWay
{
    if ([shareWay isEqual: @"twitter"]) {
        [self sendToTwitter];
    }
    if ([shareWay isEqual: @"facebook"]) {
        [self sharetofacebook];
    }
    if ([shareWay isEqual: @"email"]) {
        
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
        [self.twitterbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    if ([way isEqual: @"facebook"]) {
        [self.facebookbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    if ([way isEqual: @"email"]) {
        [self.emailbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    if ([way isEqual: @"tumblr"]) {
        [self.emailbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
}

-(void)letBtnsNormel
{
    [self.twitterbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.facebookbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.emailbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.emailbtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

#pragma mark - Twitter

- (IBAction)clickTweet:(id)sender {
    [self choserightshareway:@"twitter"];
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
    [tweetViewController addImage:[self resizePhoto]];
    
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


#pragma mark - facebook

- (IBAction)clickfacebook:(id)sender {
    [self choserightshareway:@"facebook"];
    if (canShareAnyhow) {
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
    [params setObject:UIImagePNGRepresentation([self resizePhoto]) forKey:@"picture"];
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
    if (canShareAnyhow) {
        NSLog(@"here1");
        [self sharePhotoWithMessage];
    }else{
        NSLog(@"here2");
        [self performSegueWithIdentifier:@"facebooklogin" sender:self];
    }
}


- (UIImage *)resizePhoto
{
    float max = 1000;
    float newwidth;
    float newheight;
    
    
    CGSize size = self.photo.image.size;
    if (size.height > size.width) {
        newheight = max;
        newwidth = (size.width/size.height)*newheight;
    }else{
        newwidth = max;
        newheight = (size.height/size.width)*newwidth;
    }
    CGSize resize = CGSizeMake(newwidth, newheight);
    
    UIImage *img =[self imageWithImage:self.photo.image scaledToSize:resize];
    
    NSData *imagedata = UIImageJPEGRepresentation(img, 0.5);
    NSLog(@"%d",imagedata.length);
    img = [UIImage imageWithData:imagedata];
    
    return img;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    return UIInterfaceOrientationMaskPortrait;
}




@end
