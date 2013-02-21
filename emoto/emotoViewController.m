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

@implementation emotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayPhotoAlbum];
    [self performSelector:@selector(cameraHandle) withObject:nil afterDelay:1];
    [self cameraHandle];
    [self focusHandle];
    [self initFLashLight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    count = 3; //Set Countdown from 3.
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
    [self countDownStart];
    [self displayHint];
}

//display hint
-(void)displayHint
{
    self.hint.hidden = NO;
    self.hint.text = @"给爷笑一个";
}

//count down timer start
-(void)countDownStart
{
    //timeInterval = 1;
    NSTimer *countDowntimer;
    timeInterval = [self.timeHideInput.text intValue];
    countDowntimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(countdownTimerHandle:) userInfo:nil repeats:YES];
    self.countdown.hidden = NO;
}

- (void)countdownTimerHandle:(NSTimer *)theTimer
{
    if (count > -1) {
        [self whenTimePassAway];
    }else{
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
    count = 3;
    [theTimer invalidate];
    self.countdown.hidden = YES;
    self.hint.hidden = YES;
    //prepare camera
    [CameraImageHelper CaptureStillImage];
    [self performSelector:@selector(getPhoto) withObject:nil afterDelay:1.5];
}

-(void)getPhoto
{
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

-(void)changeflashlight
{
    switch (flashMode) {
        case AVCaptureFlashModeAuto:
            flashMode = AVCaptureFlashModeOn;
            [self.flashBTN setTitle:@"ON" forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOn:
            flashMode = AVCaptureFlashModeOff;
            [self.flashBTN setTitle:@"OFF" forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOff:
            flashMode = AVCaptureFlashModeAuto;
            [self.flashBTN setTitle:@"AUTO" forState:UIControlStateNormal];
            break;
        
        default:
            break;
    }
    NSLog(@"flashMode: %d",flashMode);
    [CameraImageHelper setFlashLight:flashMode];
}

- (IBAction)setCountDownSetter:(id)sender {
    self.timeHideInput.delegate = self;
    [self.timeHideInput becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"string: %@",string);
    self.timeHideInput.text = string;
    [self.timeHideInput resignFirstResponder];
    return YES;
}



- (void)viewDidUnload {
    [self setFlashBTN:nil];
    [self setCountdownTimeSetterBTN:nil];
    [self setTimeHideInput:nil];
    [super viewDidUnload];
}
@end
