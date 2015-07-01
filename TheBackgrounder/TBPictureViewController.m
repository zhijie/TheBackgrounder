//
//  TBPictureViewController.m
//  TheBackgrounder
//
//  Created by lizhijie on 7/1/15.
//  Copyright (c) 2015 Gustavo Ambrozio. All rights reserved.
//

#import "TBPictureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

// screen size
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define isIOS6 (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_7_0)
#define isIOS7 (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0)

#define WIDTH_CONTENT_VIEW ([[UIScreen mainScreen] bounds].size.width)
//#define HEIGHT_CONTENT_VIEW ((IS_IPHONE_5?568:480) - 64)
#define HEIGHT_CONTENT_VIEW (([[UIScreen mainScreen] bounds].size.height) -  64)


#define textIP @"121.199.30.240"
#define textPORT @"10000"

@interface TBPictureViewController () {
    NSMutableArray* _dataArray;
}

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableString *communicationLog;
@property (nonatomic) BOOL sentPing;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic,strong) UITableView* tableview;
@property (nonatomic,strong) MWPhotoBrowser* browser;



@end

const uint8_t pingString[] = "ping\n";
const uint8_t pongString[] = "pong\n";

@implementation TBPictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"有序";
        self.tabBarItem.image = [UIImage imageNamed:@"ic_general_bottombar_youxu"];
        
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self didTapConnect:nil];
//    [self startBackgroundTimer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_CONTENT_VIEW, HEIGHT_CONTENT_VIEW)];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    [self.view addSubview:_tableview];
    
    [self installPhotoBrowser];
    
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
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
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
    
    [self.view addSubview:browser.view];
}


- (void)startBackgroundTimer
{
    // Avoid a retain cycle
    __weak UIViewController * weakSelf = self;
    
    // Declare the start of a background task
    // If you do not do this then the mainRunLoop will stop
    // firing when the application enters the background
    self.backgroundTaskIdentifier =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    }];
    
    // Make sure you end the background task when you no longer need background execution:
    // [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    
        // Since we are not on the main run loop this will NOT work:
        [NSTimer scheduledTimerWithTimeInterval:1
                                         target:self
                                       selector:@selector(timerDidFire:)
                                       userInfo:nil
                                        repeats:YES];
        
        // This is because the |scheduledTimerWithTimeInterval| uses
        // [NSRunLoop currentRunLoop] which will return a new background run loop
        // which will not be currently running.
        // Instead do this:
        NSTimer * timer =
        [NSTimer timerWithTimeInterval:1
                                target:weakSelf
                              selector:@selector(timerDidFire:)
                              userInfo:nil
                               repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer
                                  forMode:NSDefaultRunLoopMode];
        // or use |NSRunLoopCommonModes| if you want the timer to fire while scrolling
    });
}

- (void) timerDidFire:(NSTimer *)timer
{
    
    NSLog(@"Timer did fire at %@",[[NSDate date] description]);
}

-(void)userDidTakeScreenshot:(id)sender
{
    NSLog(@"Screenshot at %@",[[NSDate date] description]);
}

- (void)addEvent:(NSString *)event
{
    [self.communicationLog appendFormat:@"%@\n", event];
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
//        self.txtReceivedData.text = self.communicationLog;
    }
    else
    {
        NSLog(@"App is backgrounded. New event: %@", event);
    }
}

- (IBAction)didTapConnect:(id)sender
{
    if (!self.inputStream)
    {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)textIP, [textPORT intValue], &readStream, &writeStream);
        
        self.sentPing = NO;
        self.communicationLog = [[NSMutableString alloc] init];
        self.inputStream = (__bridge_transfer NSInputStream *)readStream;
        self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        [self.inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        [self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream open];
        [self.outputStream open];
        
        [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
            if (self.outputStream)
            {
                [self.outputStream write:pingString maxLength:strlen((char*)pingString)];
                [self addEvent:@"Ping sent"];
            }
        }];
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            // do nothing.
            break;
            
        case NSStreamEventEndEncountered:
            [self addEvent:@"Connection Closed"];
            break;
            
        case NSStreamEventErrorOccurred:
            [self addEvent:[NSString stringWithFormat:@"Had error: %@", aStream.streamError]];
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == self.inputStream)
            {
                uint8_t buffer[1024];
                NSInteger bytesRead = [self.inputStream read:buffer maxLength:1024];
                NSString *stringRead = [[NSString alloc] initWithBytes:buffer length:bytesRead encoding:NSUTF8StringEncoding];
                stringRead = [stringRead stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                
                [self addEvent:[NSString stringWithFormat:@"Received: %@", stringRead]];
                
                if ([stringRead isEqualToString:@"notify"])
                {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.alertBody = @"New VOIP call";
                    notification.alertAction = @"Answer";
                    [self addEvent:@"Notification sent"];
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
                else if ([stringRead isEqualToString:@"ping"])
                {
                    [self.outputStream write:pongString maxLength:strlen((char*)pongString)];
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            if (aStream == self.outputStream && !self.sentPing)
            {
                self.sentPing = YES;
                if (aStream == self.outputStream)
                {
                    [self.outputStream write:pingString maxLength:strlen((char*)pingString)];
                    [self addEvent:@"Ping sent"];
                }
            }
            break;
            
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream)
            {
                [self addEvent:@"Connection Opened"];
            }
            break;
            
        default:
            break;
    }
}

-(void)getLastestImageFromPhotos
{
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
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                // Do something interesting with the AV asset.
                NSLog(@"image size ");
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

-(void)scanAllScreenShotImages
{
    [_dataArray removeAllObjects];
    
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
                    [_dataArray addObject:[MWPhoto photoWithImage:photo]];
                    [_browser reloadData];
//                    [_tableview reloadData];
                    
                }
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}
#pragma mark - tableview
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ViewControllerCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView* image;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , WIDTH_CONTENT_VIEW, 80)];
        image.tag = 14;
        [cell addSubview:image];
        
    }else {
        image = (UIImageView*)[cell viewWithTag:14];
    }
    
    UIImage *photo = [_dataArray objectAtIndex:indexPath.row];
    [image setImage:photo];
    
    return cell;
}


#pragma mark - tableview delegate and datasource
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _dataArray.count;
    return 0;
}

#define TABLE_CELL_INSETS UIEdgeInsetsMake(0, 30, 0, 0)

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:TABLE_CELL_INSETS];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:TABLE_CELL_INSETS];
    }
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([_tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableview setSeparatorInset:TABLE_CELL_INSETS];
    }
    
    if ([_tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableview setLayoutMargins:TABLE_CELL_INSETS];
    }
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _dataArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _dataArray.count)
        return [_dataArray objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _dataArray.count)
        return [_dataArray objectAtIndex:index];
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
