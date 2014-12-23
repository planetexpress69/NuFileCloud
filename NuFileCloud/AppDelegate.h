//
//  AppDelegate.h
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow  *window;
// ---------------------------------------------------------------------------------------------------------------------
- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;
// ---------------------------------------------------------------------------------------------------------------------
@end

