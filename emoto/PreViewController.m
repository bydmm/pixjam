//
//  PreViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-4-9.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "PreViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SVProgressHUD.h"
@implementation PreViewController
@synthesize photos;
@synthesize photoScroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self performSelector:@selector(loadPhotos)];
    //[self loadPhotos];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    photos = nil;
    [self setPhoto:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self forcerotate];
    self.navigationController.navigationBarHidden=YES;
    if (showed) {
        [self.photoScroll removeFromSuperview];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (showed) {
        [SVProgressHUD showWithStatus:@"Loading Photos"];
        self.photoScroll=[[CycleScrollView alloc] initWithFrame:self.view.frame pictures:photos];
        self.photoScroll.delegate=self;
        self.photoScroll.alpha = 0;
        [self.view insertSubview:self.photoScroll atIndex:0];
        [UIView animateWithDuration:1 //持续时间
                              delay:0 //等待几秒开始动画
                            options:UIViewAnimationOptionCurveEaseIn //各种动画选项
                         animations:^{
                             self.photoScroll.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             //类似Jquery动画的回调函数，当动画播放完成后你想干啥写在这里，这是很重要的部分。
                             //动画播放往往有一步的问题，靠这里解决。OC的在这一块的处理还是很函数语言的。
                             [SVProgressHUD dismiss];
                         }];
    }else{
        [SVProgressHUD showWithStatus:@"Loading Photos"];
        [self loadPhotos];
    }
}

-(void)forcerotate
{
    NSLog(@"---forcerotate---");
    UIViewController *vc = [[UIViewController alloc]init];
    [self presentModalViewController:vc animated:NO];
    [self dismissModalViewControllerAnimated:NO];
}

- (IBAction)gotoshare:(id)sender {
    [self performSegueWithIdentifier:@"gotoshare" sender:self];
}

-(void)loadPhotos
{
    photos = [[NSMutableArray alloc] init];
    NSLog(@"---getLastPhoto---");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([@"pixjam" compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            if ([group numberOfAssets] >= 1) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                for (int i = 0; i< [group numberOfAssets]; i++) {
                    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                        // The end of the enumeration is signaled by asset == nil.
                        if (alAsset) {
                            ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                            UIImage *photo = [UIImage imageWithCGImage:[representation fullScreenImage]];
                            [photos addObject:photo];
                            // Do something interesting with the AV asset.
                        }
                    }];
                }
                [self photoScrollHandle];
            }
        }
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

-(void)photoScrollHandle
{
    int j = 0;
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (int i = ([photos count] -1); i > -1; i --) {
        [tmp insertObject:[photos objectAtIndex:i] atIndex:j];
        j++;
    }
    photos = [[NSMutableArray alloc]initWithArray:tmp];;
    self.photoScroll=[[CycleScrollView alloc] initWithFrame:self.view.frame pictures:photos];
    self.photoScroll.delegate=self;
    [self.view insertSubview:self.photoScroll atIndex:0];
    [SVProgressHUD dismiss];
}

-(void)pageViewClicked:(NSInteger)pageIndex
{
    
}
//Segue Delegate
//we need pass the photo to next view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    showed = YES;
    id photoView=segue.destinationViewController;
    [photoView setValue:[self.photos objectAtIndex:[self.photoScroll getCurPageIndex]]forKey:@"photoImage"];
}

//handleOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[self.photoScroll removeFromSuperview];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duratio
{
    [UIView animateWithDuration:1 //持续时间
                          delay:0 //等待几秒开始动画
                        options:UIViewAnimationOptionCurveEaseIn //各种动画选项
                     animations:^{
                         self.photoScroll.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         //类似Jquery动画的回调函数，当动画播放完成后你想干啥写在这里，这是很重要的部分。
                         //动画播放往往有一步的问题，靠这里解决。OC的在这一块的处理还是很函数语言的。
                     }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.photoScroll removeFromSuperview];
    self.photoScroll=[[CycleScrollView alloc] initWithFrame:self.view.frame pictures:photos];
    self.photoScroll.delegate=self;
    self.photoScroll.alpha = 0;
    [self.view insertSubview:self.photoScroll atIndex:0];
    [UIView animateWithDuration:1 //持续时间
                          delay:0 //等待几秒开始动画
                        options:UIViewAnimationOptionCurveEaseIn //各种动画选项
                     animations:^{
                         self.photoScroll.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         //类似Jquery动画的回调函数，当动画播放完成后你想干啥写在这里，这是很重要的部分。
                         //动画播放往往有一步的问题，靠这里解决。OC的在这一块的处理还是很函数语言的。
                     }];
}

- (IBAction)pop:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
