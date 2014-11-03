//
//  AppDelegate.m
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "Constants.h"
#import "LovelyDataProvider.h"
#import "NSString+Additions.h"
#import <MKNetworkKit/MKNetworkKit.h>

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;

    //self.window.tintColor = [UIColor blackColor];
    [[UIBarButtonItem appearance]setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]setBarTintColor:[UIColor redColor]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]setTranslucent:NO];
    [[UIToolbar appearance]setBarTintColor:[UIColor redColor]];
    [[UIToolbar appearance]setTranslucent:NO];

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSForegroundColorAttributeName,
      /*[UIFont fontWithName:@"Arial-Bold" size:0.0],
       NSFontAttributeName, */
      nil]];

    NSNumber *updateInterval = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateInterval"];
    if (updateInterval == nil) {
        updateInterval = @60;
        [[NSUserDefaults standardUserDefaults]setObject:updateInterval forKey:@"updateInterval"];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([self appShouldUpdate]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"AppDidNoticeOldFeed" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;

    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");

    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

- (BOOL)appShouldUpdate
{
    int updateInterval = ((NSNumber *)[[NSUserDefaults standardUserDefaults]objectForKey:@"updateInterval"]).intValue;
    NSDate *now =                   [NSDate date];
    NSDate *lastSuccessfulUpdate =  [[NSUserDefaults standardUserDefaults]objectForKey:@"lastSuccessfulUpdate"];
    if (lastSuccessfulUpdate == nil) {
        lastSuccessfulUpdate = [NSDate date];
        [[NSUserDefaults standardUserDefaults]setObject:lastSuccessfulUpdate forKey:@"lastSuccessfulUpdate"];
    }
    NSTimeInterval diff = [now timeIntervalSinceDate:lastSuccessfulUpdate];
    NSLog(@"Last update happened %d seconds ago. Interval is: %d.", (int)diff, updateInterval);
    return diff > updateInterval;
}

@end
