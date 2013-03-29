//
//  emotoStartViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-3-14.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#import <UIKit/UIKit.h>
#import "DirectionMPMoviePlayerViewController.h"
@interface emotoStartViewController : UIViewController{
    
}
@property (retain, nonatomic)  DirectionMPMoviePlayerViewController *playerView;
@end
