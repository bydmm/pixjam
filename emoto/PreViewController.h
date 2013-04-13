//
//  PreViewController.h
//  emoto
//
//  Created by Kyoma Houohin on 13-4-9.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CycleScrollView.h"
@interface PreViewController : UIViewController<UIScrollViewDelegate,CycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (retain) NSMutableArray *photos;
@property (retain, nonatomic) CycleScrollView  *photoScroll;
@end
