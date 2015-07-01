//
//  TBPictureViewController.m
//  TheBackgrounder
//
//  Created by lizhijie on 7/1/15.
//  Copyright (c) 2015 Gustavo Ambrozio. All rights reserved.
//

#import "TBPictureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define textIP @"121.199.30.240"
#define textPORT @"10000"

@interface TBPictureViewController ()

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableString *communicationLog;
@property (nonatomic) BOOL sentPing;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;


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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self didTapConnect:nil];
    [self startBackgroundTimer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
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

-(void)getImage
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
@end
