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
@synthesize playerView;

- (void)viewDidLoad
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path]), &soundID);
    
    [self playMovieAtURL];
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.albumbg.hidden = YES;
    self.photoBTN.hidden = YES;
}

-(void)playMovieAtURL
{
    //路径的设置，这里要注意，不要用[NSURL urlwithstring],还要去确保路径的正确
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath;
    if(iPhone5){
        moviePath = [bundle pathForResource:@"iphone5" ofType:@"mp4"];
    }else{
        moviePath = [bundle pathForResource:@"iphone4" ofType:@"mp4"];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    playerView = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    playerView.view.frame = self.view.frame;//全屏播放（全屏播放不可缺）
    playerView.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;//全屏播放（全屏播放不可缺）
    playerView.moviePlayer.controlStyle=MPMovieControlStyleNone;
    //[self presentMoviePlayerViewControllerAnimated:playerView];
    [self presentModalViewController:playerView animated:YES];
    [playerView.moviePlayer play];
    [self setNsnot];
}

-(void)setNsnot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerView.moviePlayer];
}

- (void) playVideoFinished:(NSNotification *)theNotification//当点击Done按键或者播放完毕时调用此函数
{
    [self displayPhotoAlbum];
    [self performSelector:@selector(cameraHandle) withObject:nil afterDelay:0.1];
    [self focusHandle];
    [self initFLashLight];
    [self displayHint];
    timerstatus = YES;
    [self resetshoot];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetshoot)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"---viewDidAppear---");
}

//navigationController
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self) {
        if (hasopened == YES) {
            [self forcerotate];
            [self cameraHandle];
            [self displayPhotoAlbum];
            [self displayHint];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"usedMemory: %f",[self usedMemory]);
    self.navigationController.navigationBarHidden=YES;
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


-(void)forcerotate
{
    NSLog(@"---forcerotate---");
    UIViewController *vc = [[UIViewController alloc]init];
    [self presentModalViewController:vc animated:NO];
    [self dismissModalViewControllerAnimated:NO];
}

- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

-(void)resetshoot
{
    NSLog(@"resetshoot");
    self.countdown.hidden = YES;
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
    [CameraImageHelper changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation];
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
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
    if (self.countdown.hidden == YES) {
        [self countDownStart];
        self.timeronview.hidden = YES;
    }
}

//display hint
-(void)displayHint
{
    UITapGestureRecognizer *oneclick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayHint)];
    
    [[self hintview] addGestureRecognizer:oneclick];
    
    [self loadhintlist];
    self.hint.font = [UIFont fontWithName:@"That's not what I meant..." size:20];
    self.hint.text = [self randhint];
    [self.hint sizeToFit];
    
    CGRect frame =  self.hint.frame;
    frame = CGRectMake(15, -9, frame.size.width, 50);
    self.hint.frame = frame;
    
    frame = self.hintbg.frame;
    frame.size = CGSizeMake(self.hint.frame.size.width + 25 , 50);
    self.hintbg.frame = frame;
    
    frame = self.hintview.frame;
    frame.size = self.hintbg.frame.size;
    frame.origin.x = (self.avView.frame.size.width - self.hintbg.frame.size.width)/2;
    self.hintview.frame = frame;
    
    NSLog(@"hint: %@",self.hint.text);
}

//count down timer start
-(void)countDownStart
{
    self.countdown.text = @"Count Down";
    count = (int)self.timerslider.value;
    self.countdown.hidden = NO;
    countDowntimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownTimerHandle:) userInfo:nil repeats:YES];
}

- (void)countdownTimerHandle:(NSTimer *)theTimer
{
    if (count == 6) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if (count == 5) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if (count == 4) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if (count == 3) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if (count == 2) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if (count == 1) {
        self.countdown.text = [[NSString alloc]initWithFormat:@"%d",count];
        count--;
    }
    else if(count == 0){
        self.countdown.text = @"Shoot";
        [self RunOutOfTime:theTimer];
    }
    
}


-(void)RunOutOfTime:(NSTimer *)theTimer
{
    [theTimer invalidate];
    //prepare camera
    [CameraImageHelper CaptureStillImage];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPhoto)
                                                 name:@"imageget"
                                               object:nil];
}

-(void)getPhoto
{
    [CameraImageHelper stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageget" object:nil];
    [self resetshoot];
    photo = [CameraImageHelper image];
    [CameraImageHelper releaseimage];
    photo = [self resizePhoto:photo];
    [CameraImageHelper startRunning];
    [self savetoAlbum];
}


//Segue Delegate
//we need pass the photo to next view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    hasopened = YES;
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
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([@"pixjam" compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
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
        }
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

-(void)showLastPhotoAtBTN:(UIImage *)lastPhoto
{
    self.albumbg.hidden = NO;
    self.photoBTN.hidden = NO;
    [self viewAnimation:self.albumbg];
    [self viewAnimation:self.photoBTN];
    thelastPhoto = lastPhoto;
    self.photoBTN.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)viewAnimation:(UIView *)view
{
    CGRect frame = view.frame;
    [self animateout:view setFrame:frame];
}

-(void)animateout:(UIView *)view setFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.2
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         view.frame = [self holdcenter:view.frame setZoom:1.3];
                         view.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         [self animatein:view setFrame:frame];
                     }];
}

-(void)animatein:(UIView *)view setFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = [self holdcenter:frame setZoom:0.2];
                         view.alpha = 0.8;
                     }
                     completion:^(BOOL finished){
                        [self.photoBTN setImage:thelastPhoto forState:UIControlStateNormal];
                        [self animateback:view setFrame:frame];
                     }];
}

-(void)animateback:(UIView *)view setFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         view.frame = frame;
                         view.alpha = 1;
                     }
                     completion:^(BOOL finished){

                     }];
}

-(CGRect)holdcenter:(CGRect)frame setZoom:(float)zoom
{

    float cx = frame.origin.x + frame.size.width/2.0;
    float cy = frame.origin.y + frame.size.height/2.0;
    
    frame.size.height = frame.size.height * zoom;
    frame.size.width = frame.size.width * zoom;
    
    frame.origin.x = cx - frame.size.width/2.0;
    frame.origin.y = cy - frame.size.height/2.0;
    
    return frame;
}

//when photoBTN click
- (IBAction)gophotolib:(id)sender {
    [self goshowphoto];
}

-(void)goshowphoto
{
    [CameraImageHelper stopRunning];
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
    
    if (self.timeronview.hidden == NO) {
        self.timeronview.hidden = YES;
    }else{
        [self displaySlier];
    }
}

-(void)displaySlier
{
    self.timeronview.hidden = NO;
    UIImage *point = [UIImage imageNamed:@"timerpoint"];
    UIImage *tm = [UIImage imageNamed:@"tm"];
    [self.timerslider setThumbImage:point forState:UIControlStateNormal];
    [self.timerslider setThumbImage:point forState:UIControlStateSelected];
    [self.timerslider setThumbImage:point forState:UIControlStateHighlighted];
    [self.timerslider setMaximumTrackImage:tm forState:UIControlStateNormal];
    [self.timerslider setMinimumTrackImage:tm forState:UIControlStateNormal];
    
}

//save photo to Album
-(void)savetoAlbum
{
    NSLog(@"savetoAlbum");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:photo toAlbum:@"pixjam"
       completionBlock:^(NSURL *assetURL, NSError *error) {
           NSString *errormsg = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
           if ([@"User denied access" isEqualToString:errormsg]) {
               [self requestRight];
           }else{
               [self performSelector:@selector(getLastPhoto) withObject:nil afterDelay:0.5];
           }
       } failureBlock:^(NSError *error) {
           NSLog(@"failureBlock error: %@",error);
           [self requestRight];
       }];
}

-(void)requestRight
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"opps!" message:@"We need you permit to access album!\n Please set it at Setting -> Privacy -> Photos" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}



- (UIImage *)resizePhoto:(UIImage *)image
{
    float max = 1136;
    float newwidth;
    float newheight;
    
    NSData *imagedata = UIImageJPEGRepresentation(image, 0.5);
    NSLog(@"%d",imagedata.length);
    image = [UIImage imageWithData:imagedata];
    
    CGSize size = image.size;
    if (size.height > size.width) {
        newheight = max;
        newwidth = (size.width/size.height)*newheight;
    }else{
        newwidth = max;
        newheight = (size.height/size.width)*newwidth;
    }
    CGSize resize = CGSizeMake(newwidth, newheight);
    
    UIImage *img =[self imageWithImage:image scaledToSize:resize];
    
    UIImage *mask = [UIImage imageNamed:@"hint@2x.png"];
    
    UIFont *font = [UIFont fontWithName:@"That's not what I meant..." size:50];
    
    CGSize hintsize = [self.hint.text sizeWithFont:font];
    
    CGSize masksize = mask.size;
    masksize.width = hintsize.width + 100;
    mask =[self imageWithImage:mask scaledToSize:masksize];
    
    
    CGPoint maskpoint = CGPointMake((newwidth/2 - (masksize.width/2)), newheight*0.8);
    NSLog(@"maskpoint x,y : %f,%f",maskpoint.x,maskpoint.y);
    NSLog(@"resize width,height : %f,%f",img.size.width,img.size.height);
    
    img = [self addImage:img toImage:mask at:maskpoint];
    CGPoint messagepoint = CGPointMake(maskpoint.x + 30, maskpoint.y+ 10);
    // note: replace "ImageUtils" with the class where you pasted the method above
    img = [self drawText:self.hint.text
                 inImage:img
                 atPoint:messagepoint];
    
    return img;
}


- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 at:(CGPoint)point {
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(point.x, point.y, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

-(UIImage*)CopyImageAndAddAlphaChannel:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"resize width,height : %f,%f",newImage.size.width,newImage.size.height);
    return newImage;
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont fontWithName:@"That's not what I meant..." size:50];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(0, point.y, image.size.width, image.size.height);
    
    [[UIColor blackColor] set];
    
    [text drawInRect:CGRectIntegral(rect) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//shake

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"shake");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake )
	{
		// User was shaking the device. Post a notification named "shake".
        AudioServicesPlaySystemSound (soundID);
        [self displayHint];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
}

- (void)viewDidUnload {
    self.avView = nil;
    photo = nil;
    playerView = nil;
    imagepicker = nil;
    [self setFlashBTN:nil];
    [self setFlashsettingview:nil];
    [self setTimerslider:nil];
    [self setTimeronview:nil];
    [self setTimeroffbtn:nil];
    [self setHintview:nil];
    [self setAlbumbg:nil];
    [self setHintbg:nil];
    [super viewDidUnload];
}

@end
