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

@implementation PreViewController
@synthesize photos;
@synthesize photoScroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPhotos];
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
}

-(void)viewDidAppear:(BOOL)animated
{
    
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
}

-(void)pageViewClicked:(NSInteger)pageIndex
{
    
}
//Segue Delegate
//we need pass the photo to next view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id photoView=segue.destinationViewController;
    [photoView setValue:[self.photos objectAtIndex:[self.photoScroll getCurPageIndex]]forKey:@"photoImage"];
}

//handleOrientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

- (IBAction)pop:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
