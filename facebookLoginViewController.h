//
//  facebookLoginViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-2-21.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>

@interface facebookLoginViewController : UIViewController<FBLoginViewDelegate>
{
    BOOL canShareAnyhow;
}
@property (retain, nonatomic) FBLoginView *loginview;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@end
