//
//  emotoViewController.m
//  emoto
//
//  Created by Kyoma Houohin on 13-2-19.
//  Copyright (c) 2013年 emoto. All rights reserved.
//

#import "emotoViewController.h"
#import "PhotoViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AssetsLibrary/AssetsLibrary.h>
#include <stdlib.h>

@implementation emotoViewController
@synthesize flashBTN;
@synthesize flashsettingview;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayPhotoAlbum];
    [self performSelector:@selector(cameraHandle) withObject:nil afterDelay:1];
    [self cameraHandle];
    [self focusHandle];
    [self initFLashLight];
    //[self displayHint];
    timerstatus = YES;
    [self resetshoot];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(resetshoot)
                                          name:UIApplicationWillResignActiveNotification
                                          object:nil];
    [self loadhintlist];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self resetshoot];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetshoot
{
    NSLog(@"resetshoot");
    self.countdown.hidden = YES;
    self.hintview.hidden =YES;
    [countDowntimer invalidate];
    count = 3;
}

//hint data
-(void)loadhintlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"action" ofType:@"plist"];
    hintlist = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

-(NSString *)randhint
{
    int index = arc4random() % ([hintlist count] -1);
    NSString *hint = [[hintlist objectAtIndex:index] objectForKey:@"name"];
    return hint;
}

//focus handle
-(void)focusHandle
{
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerOneTap:)];
    singleTap.delegate = self;
    [self.avView addGestureRecognizer:singleTap];
}

- (void)oneFingerOneTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    
    CGPoint point = [sender locationInView:self.view];
    CGSize size = self.avView.frame.size;
    CGPoint focus = CGPointMake(point.x/size.width, point.y/size.height);
    [CameraImageHelper setFocus:focus];
}

//init camera display
-(void)cameraHandle
{
    timeInterval = 1 ;
    self.avView.backgroundColor = [UIColor blackColor];
    [CameraImageHelper startRunning];
    [CameraImageHelper embedPreviewInView:self.avView];
    [self fullscreen];
}

//handleOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation：%d",interfaceOrientation);
    [CameraImageHelper changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation];
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [CameraImageHelper changePreviewOrientation:(UIInterfaceOrientation)self.interfaceOrientation];
}

//camera preview full fullscreen
-(void)fullscreen
{
    [CameraImageHelper changePreviewOrientation:(UIInterfaceOrientation)self.interfaceOrientation];
}

//shoot BTN clicked
- (IBAction)shoot:(id)sender {
    [self displayHint];
    [self countDownStart];
}

//display hint
-(void)displayHint
{
    self.hintview.hidden = NO;
    self.hint.text = @"Laugh";
}

//count down timer start
-(void)countDownStart
{
    self.hint.text = [self randhint];
    timeInterval = (int)self.timerslider.value;
    countDowntimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(countdownTimerHandle:) userInfo:nil repeats:YES];
    self.countdown.hidden = NO;
}

- (void)countdownTimerHandle:(NSTimer *)theTimer
{
    [self whenTimePassAway];
    if(count == 0){
        [self RunOutOfTime:theTimer];
    }
}

-(void)whenTimePassAway
{
    self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
    count--;
}

-(void)RunOutOfTime:(NSTimer *)theTimer
{
    [theTimer invalidate];
    //prepare camera
    [CameraImageHelper CaptureStillImage];
    [self performSelector:@selector(getPhoto) withObject:nil afterDelay:timeInterval];
}

-(void)getPhoto
{
    [self whenTimePassAway];
    [self resetshoot];
    photo = [CameraImageHelper image];
    [self savetoAlbum];
    [self performSegueWithIdentifier:@"showphoto" sender:self];
}

//save photo to Album
-(void)savetoAlbum
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:photo toAlbum:@"emoto"
       completionBlock:^(NSURL *assetURL, NSError *error) {
           NSLog(@"success");
       } failureBlock:^(NSError *error) {
           NSLog(@"%@",error);
       }];
}

//Segue Delegate
//we need pass the photo to next view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id photoView=segue.destinationViewController;
    [photoView setValue:photo forKey:@"photoImage"];
}

//display photoAlbum btn with the last photo
-(void)displayPhotoAlbum
{
    [self getLastPhoto];
}

-(void)getLastPhoto
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if ([group numberOfAssets] >= 1) {
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // Chooses the photo at the last index
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                    
                    // Do something interesting with the AV asset.
                    [self showLastPhotoAtBTN:latestPhoto];
                }
            }];
        }
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

-(void)showLastPhotoAtBTN:(UIImage *)lastPhoto
{
    [self.photoBTN setImage:lastPhoto forState:UIControlStateNormal];
    self.photoBTN.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

//when photoBTN click
- (IBAction)gophotolib:(id)sender {
    imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagepicker.delegate = self;
    imagepicker.allowsEditing = NO;
    [self presentModalViewController:imagepicker animated:YES];
}

//imagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
    
    photo = originalImage;
    [self performSelector:@selector(goshowphoto) withObject:nil afterDelay:1];
}

-(void)goshowphoto
{
    [self performSegueWithIdentifier:@"showphoto" sender:self];
}

-(void)initFLashLight
{
    flashMode = AVCaptureFlashModeAuto;
    [self.flashBTN setTitle:@"AUTO" forState:UIControlStateNormal];
}

- (IBAction)flashBTNclick:(id)sender {
    [self changeflashlight];
}

-(void)changeflashMode:(AVCaptureFlashMode)mode WithImage:(NSString *)image
{
    flashMode = mode;
    UIImage *flashtype = [UIImage imageNamed:image];
    [self.flashBTN setImage:flashtype forState:UIControlStateNormal];
    NSLog(@"flashMode: %d",flashMode);
    [CameraImageHelper setFlashLight:flashMode];
    self.flashBTN.hidden = NO;
    self.flashsettingview.hidden = YES;
}

- (IBAction)autoflash:(id)sender {
    [self changeflashMode:AVCaptureFlashModeAuto WithImage:@"auto"];
}

- (IBAction)flashon:(id)sender {
    [self changeflashMode:AVCaptureFlashModeOn WithImage:@"on"];
}

- (IBAction)flashoff:(id)sender {
    [self changeflashMode:AVCaptureFlashModeOff WithImage:@"off"];
}


-(void)changeflashlight
{
    self.flashBTN.hidden = YES;
    self.flashsettingview.hidden = NO;
}

- (IBAction)swapFrontAndBackCameras:(id)sender {
    [CameraImageHelper swapFrontAndBackCameras];
}

//slider
- (IBAction)timersetting:(id)sender {
    
    if (self.timeroffbtn.hidden == NO || self.timeronview.hidden == NO) {
        NSLog(@"234234");
        self.timeronview.hidden = YES;
        self.timeroffbtn.hidden = YES;
    }else{
        if (timerstatus) {
            [self displaySlier];
        }else{
            [self displayTimeroffBtn];
        }
    }
}

-(void)displayTimeroffBtn
{
    self.timeronview.hidden = YES;
    self.timeroffbtn.hidden = NO;
}

-(void)displaySlier
{
    self.timeronview.hidden = NO;
    self.timeroffbtn.hidden = YES;
    UIImage *point = [UIImage imageNamed:@"timerpoint"];
    UIImage *tm = [UIImage imageNamed:@"tm"];
    [self.timerslider setThumbImage:point forState:UIControlStateNormal];
    [self.timerslider setThumbImage:point forState:UIControlStateSelected];
    [self.timerslider setThumbImage:point forState:UIControlStateHighlighted];
    [self.timerslider setMaximumTrackImage:tm forState:UIControlStateNormal];
    [self.timerslider setMinimumTrackImage:tm forState:UIControlStateNormal];
    
}

- (IBAction)timeroff:(id)sender {
    timerstatus = NO;
    [self displayTimeroffBtn];
}
- (IBAction)timeron:(id)sender {
    timerstatus = YES;
    [self displaySlier];
}


- (void)viewDidUnload {
    [self setFlashBTN:nil];
    [self setFlashsettingview:nil];
    [self setTimerslider:nil];
    [self setTimeronview:nil];
    [self setTimeroffbtn:nil];
    [self setHintview:nil];
    [super viewDidUnload];
}
@end
