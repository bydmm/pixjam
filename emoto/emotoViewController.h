//
//  emotoViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-2-19.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraImageHelper.h"

@interface emotoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    int count;
    NSTimeInterval timeInterval;
    UIImage *photo;
    UIImagePickerController *imagepicker;
    AVCaptureFlashMode flashMode;
}
@property (weak, nonatomic) IBOutlet UIView *avView;
@property (weak, nonatomic) IBOutlet UILabel *countdown;
@property (weak, nonatomic) IBOutlet UILabel *hint;
@property (weak, nonatomic) IBOutlet UIButton *photoBTN;
@property (weak, nonatomic) IBOutlet UIButton *flashBTN;
@property (weak, nonatomic) IBOutlet UIButton *countdownTimeSetterBTN;
@property (weak, nonatomic) IBOutlet UITextField *timeHideInput;

@end
