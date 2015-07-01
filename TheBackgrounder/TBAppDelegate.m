//
//  TBAppDelegate.m
//  TheBackgrounder
//
//  Created by Gustavo Ambrozio on 19/1/13.
//  Copyright (c) 2013 Gustavo Ambrozio. All rights reserved.
//

#import "TBAppDelegate.h"
#import "TBPictureViewController.h"
#import "TBSecondViewController.h"
#import "TBThirdViewController.h"


@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    UIViewController *viewController1 = [[TBPictureViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *viewController2 = [[TBSecondViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *viewController3 = [[TBThirdViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController* nav3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[nav1, nav2, nav3];
    
    //03A9F4
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:3./255 green:169./255 blue:242./255 alpha:1.0]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithWhite:242./255 alpha:1.0]];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
