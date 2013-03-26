//
//  fbdifferentViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-2-21.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "fbdifferentViewController.h"

@implementation fbdifferentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

-(void)same
{
    FBLoginView *theLoginView;
    if (!FBSession.activeSession.isOpen) {
        theLoginView = [[FBLoginView alloc] init];
        theLoginView.frame = CGRectOffset(theLoginView.frame,
                                          ([[UIScreen mainScreen] bounds].size.width-theLoginView.frame.size.width)/2,
                                          ([[UIScreen mainScreen] bounds].size.height-theLoginView.frame.size.height)/2 -50);
        theLoginView.delegate = self;
        [self.view addSubview:theLoginView];
        [theLoginView sizeToFit];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
