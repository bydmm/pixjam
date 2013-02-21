//
//  PhotoViewController.h
//  e-moto
//
//  Created by 程南 on 13-2-18.
//  Copyright (c) 2013年 e-moto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PhotoViewController : UIViewController<FBLoginViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (retain, nonatomic) UIImage *photoImage;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@end
