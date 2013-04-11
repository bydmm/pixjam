//
//  PreViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-4-9.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (retain, nonatomic) UIImage *photoImage;
@property (retain, nonatomic) NSString *hint;
@end
