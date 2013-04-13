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
@synthesize loggedInUser;
@synthesize profilePic;

- (void)viewDidLoad
{
    [super viewDidLoad];
    canShareAnyhow = [FBNativeDialogs canPresentShareDialogWithSession:nil];
	// Do any additional setup after loading the view.
    [self login];
    
    
}


-(void)login
{
    if (!FBSession.activeSession.isOpen) {
        loginview = [[FBLoginView alloc] init];
        loginview.frame = CGRectMake(80, 216, 160, 47);
        [self.view addSubview:loginview];
        loginview.delegate = self;
        [self.view addSubview:loginview];
        [loginview sizeToFit];
    }
}

- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self performSelector:@selector(popout) withObject:nil afterDelay:1.0];
    // first get the buttons set for login mode
}

-(void)popout{
    [self.navigationController popViewControllerAnimated:YES];
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
    [super viewDidUnload];
}
@end
