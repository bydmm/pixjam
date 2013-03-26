//
//  CameraImageHelper.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "CameraImageHelper.h"
#import <ImageIO/ImageIO.h>

@implementation CameraImageHelper
@synthesize session,captureOutput,image,g_orientation;
@synthesize preview;

static CameraImageHelper *sharedInstance = nil;


- (void) initialize
{
    //1.创建会话层
    self.session = [[[AVCaptureSession alloc] init] autorelease];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    
    //2.创建、配置输入设备
    device = [self cameraWithPosition:AVCaptureDevicePositionBack];

	NSError *error;
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
	if (!captureInput)
	{
		NSLog(@"Error: %@", error);
		return;
	}
    [self.session addInput:captureInput];
    
    
    //3.创建、配置输出    
    captureOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [captureOutput setOutputSettings:outputSettings];

    [outputSettings release];
	[self.session addOutput:captureOutput];

}

- (id) init
{
    position = AVCaptureDevicePositionBack;
	if (self = [super init]) [self initialize];
	return self;
}

-(void) embedPreviewInView: (UIView *) aView {
    if (!session) return;
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession: session];
    preview.frame = aView.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill; 
    [aView.layer addSublayer: preview];
}

- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [CATransaction begin];
    //[CATransaction setDisableActions:YES];
    preview.frame = [preview superlayer].bounds;
    
    if ([preview respondsToSelector:@selector(connection)])
    {
        if ([preview.connection isVideoOrientationSupported])
        {
            [preview.connection setVideoOrientation:interfaceOrientation];
        }
    }
    else
    {
        // Deprecated in 6.0; here for backward compatibility
        if ([preview isOrientationSupported])
        {
            [preview setOrientation:interfaceOrientation];
        }
    }
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        g_orientation = UIImageOrientationUp;
        //preview.orientation = AVCaptureVideoOrientationLandscapeRight;
    }else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        g_orientation = UIImageOrientationDown;
        //preview.orientation = AVCaptureVideoOrientationLandscapeLeft;
    }else if(interfaceOrientation ==
             UIInterfaceOrientationPortrait){
        g_orientation = UIImageOrientationLeft;
        //preview.orientation = AVCaptureVideoOrientationPortrait;
    }else if(interfaceOrientation ==
             UIInterfaceOrientationPortraitUpsideDown){
        g_orientation = UIImageOrientationRight;
        //preview.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    [CATransaction commit];
}

- (void) focusAtPoint:(CGPoint)point
{
    //point = [self realpoint:point];
    NSLog(@"x:%f,y:%f",point.x,point.y);
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error;
        
        if ([device lockForConfiguration:&error]) {
            
            [device setFocusPointOfInterest:point];
            
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            [device unlockForConfiguration];
            
        } else {
            NSLog(@"%@",error);
            
        }        
        
    }
    
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         CFDictionaryRef exifAttachments =
         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *t_image = [[UIImage alloc] initWithData:imageData] ;   
#if 1 
         image = [[UIImage alloc]initWithCGImage:t_image.CGImage scale:1.0 orientation:g_orientation];
         [t_image release];
#else
         image = [t_image resizedImage:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationDefault];
#endif     
     }];
}

//flashlight
-(void)setFlash:(AVCaptureFlashMode)mode
{
    [device lockForConfiguration:nil];
    device.flashMode = mode;
    [device unlockForConfiguration];
}



//- (void)swapFrontAndBackCameras {
//    if (position == AVCaptureDevicePositionBack) {
//        position = AVCaptureDevicePositionFront;
//    }
//    else if (position == AVCaptureDevicePositionFront){
//        position = AVCaptureDevicePositionBack;
//    }
//    [self initialize];
//}


// Switching between front and back cameras

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)theposition
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *thedevice in devices )
        if ( thedevice.position == theposition )
            return thedevice;
    return nil;
}

- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *thedevice = input.device;
        if ( [thedevice hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition theposition = thedevice.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (theposition == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    } 
}

- (void) dealloc
{
	self.session = nil;
	self.image = nil;
	[super dealloc];
}

#pragma mark Class Interface

+ (id) sharedInstance // private
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

+ (void) startRunning
{
	[[[self sharedInstance] session] startRunning];	
}

+ (void) stopRunning
{
	[[[self sharedInstance] session] stopRunning];
}

+ (UIImage *) image
{
	return [[self sharedInstance] image];
}

+(void)CaptureStillImage
{
    [[self sharedInstance] Captureimage];
}

+ (void)embedPreviewInView: (UIView *) aView
{
    [[self sharedInstance] embedPreviewInView:aView];
}

+ (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[self sharedInstance] changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation];
}

+ (void)setFocus: (CGPoint)point
{
    [[self sharedInstance] focusAtPoint:point];
}

+ (void)setFlashLight:(AVCaptureFlashMode)mode
{
    [[self sharedInstance] setFlash:mode];
}

+ (void)swapFrontAndBackCameras
{
    [[self sharedInstance] swapFrontAndBackCameras];
}

@end
