//
//  PhotoViewController.m
//  e-moto
//
//  Created by 程南 on 13-2-18.
//  Copyright (c) 2013年 e-moto. All rights reserved.
//

#import "PhotoViewController.h"
#import <CoreLocation/CoreLocation.h>

@implementation PhotoViewController
@synthesize photo;
@synthesize photoImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self facebooklogin];
    self.photo.image = self.photoImage;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPhoto:nil];
    [super viewDidUnload];
}

-(void)facebooklogin
{
    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] init];
    
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    // self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    // self.profilePic.profileID = user.id;
    // self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
//    BOOL canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
//    self.buttonPostPhoto.enabled = canShareAnyhow;
//    self.buttonPostStatus.enabled = canShareAnyhow;
//    self.buttonPickFriends.enabled = NO;
//    self.buttonPickPlace.enabled = NO;
//    
//    self.profilePic.profileID = nil;
//    self.labelFirstName.text = nil;
//    self.loggedInUser = nil;
}

#pragma mark -

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

- (IBAction)sharetofacebook:(id)sender {
    // Just use the icon image from the application itself.  A real app would have a more
    // useful way to get an image.
    
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
    
    
    // if it is available to us, we will post using the native dialog
    BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
                                                                    initialText:nil
                                                                          image:img
                                                                            url:nil
                                                                        handler:nil];
    if (!displayedNativeDialog) {
        [self performPublishAction:^{
            
            [FBRequestConnection startForUploadPhoto:img
                                   completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                       [self showAlert:@"Photo Post" result:result error:error];
                                       //self.buttonPostPhoto.enabled = YES;
                                   }];
            
            //self.buttonPostPhoto.enabled = NO;
        }];
    }
}

// Post Status Update button handler; will attempt to invoke the native
// share dialog and, if that's unavailable, will post directly
- (IBAction)postStatusUpdateClick:(UIButton *)sender {
    // Post a status update to the user's feed via the Graph API, and display an alert view
    // with the results or an error.
    NSString *name = self.loggedInUser.first_name;
    NSString *message = [NSString stringWithFormat:@"Updating status for %@ at %@",
                         name != nil ? name : @"me" , [NSDate date]];
    
    // if it is available to us, we will post using the native dialog
    BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
                                                                    initialText:nil
                                                                          image:nil
                                                                            url:nil
                                                                        handler:nil];
    if (!displayedNativeDialog) {
        
        [self performPublishAction:^{
            // otherwise fall back on a request for permissions and a direct post
            [FBRequestConnection startForPostStatusUpdate:message
                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                            
                                            [self showAlert:message result:result error:error];
                                            //self.buttonPostStatus.enabled = YES;
                                        }];
            
            //self.buttonPostStatus.enabled = NO;
        }];
    }
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.\nPost ID: %@",
                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

//
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
