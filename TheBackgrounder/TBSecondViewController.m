//
//  TBSecondViewController.m
//  TheBackgrounder
//
//  Created by lizhijie on 7/1/15.
//  Copyright (c) 2015 Gustavo Ambrozio. All rights reserved.
//

#import "TBSecondViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import "MWPhotoBrowser.h"


#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)



@interface TBSecondViewController ()<GMGridViewDataSource , GMGridViewActionDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate>
{
    __gm_weak GMGridView *_gmGridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
    
    NSMutableArray* _photoArray;
    NSMutableArray* _thumbnailArray;
    
    MWPhotoBrowser* _browser;
}


@end


@implementation TBSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"存档";
        self.tabBarItem.image = [UIImage imageNamed:@"ic_general_bottom_document"];
        
        _thumbnailArray = [[NSMutableArray alloc] init];
        _photoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _gmGridView.mainSuperView = self.navigationController.view; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scanAllScreenShotImages];
    
}
- (void) installPhotoBrowser
{
    
    // Create browser
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    //    [browser setCurrentPhotoIndex:0];
    browser.view.backgroundColor =[UIColor whiteColor];
    _browser = browser;

    
}
-(void)scanAllScreenShotImages
{
    //    [_dataArray removeAllObjects];
    [_thumbnailArray removeAllObjects];
    [_photoArray removeAllObjects];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                //UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                
                // Do something interesting with the AV asset.
                //                NSLog(@"image metadata: %@",representation.metadata);
                
                int height = [[representation.metadata objectForKey:@"PixelHeight"] intValue];
                int width = [[representation.metadata objectForKey:@"PixelWidth"] intValue];
                if ( (height == 1136 && width == 640) ||
                    (height == 960 && width == 640) ||
                    (height == 480 && width == 320) ||
                    (height == 1334 && width == 750) ||
                    (height == 2208 && width == 1242)) {
                    UIImage *photo = [UIImage imageWithCGImage:[representation fullScreenImage]];

                    [_photoArray addObject:[MWPhoto photoWithImage:photo]];
                    [_thumbnailArray addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:alAsset.aspectRatioThumbnail]]];

                    
                    [_gmGridView reloadData];
                    
                    
                }
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}
//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.dataSource = self;
    
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    _gmGridView = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}

//////////////////////////////////////////////////////////////
#pragma mark orientation management
//////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_thumbnailArray count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(150, 220);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
//        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
//        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , size.width, size.height)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:image];

    MWPhoto *photo = [_thumbnailArray objectAtIndex:index];
    [image setImage:photo.image];

    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    
    [self installPhotoBrowser];
    [_browser setCurrentPhotoIndex:position];
    [self.navigationController pushViewController:_browser animated:YES];

}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photoArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photoArray.count)
        return [_photoArray objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbnailArray.count)
        return [_thumbnailArray objectAtIndex:index];
    return nil;
    
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

//- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
//    return [[_selections objectAtIndex:index] boolValue];
//}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
//    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
//    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
//}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end