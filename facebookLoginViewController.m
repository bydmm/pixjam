//
//  facebookLoginViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-2-21.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "facebookLoginViewController.h"

@implementation facebookLoginViewController
@synthesize loginview;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self facebooklogin];
    canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
	// Do any additional setup after loading the view.
}

-(void)facebooklogin
{
    // Create Login View so that the app will be granted "status_update" permission.
    
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"LOGINED");
    // first get the buttons set for login mode
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePic.profileID = nil;
    self.labelFirstName.text = nil;
    self.loggedInUser = nil;
    [FBSession.activeSession closeAndClearTokenInformation];
}



- (void)viewDidUnload {
    self.loginview.delegate = nil;
    [self setLoginview:nil];
    [super viewDidUnload];
}
@end
