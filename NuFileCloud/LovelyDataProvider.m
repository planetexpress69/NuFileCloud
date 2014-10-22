//
//  LovelyDataProvider.m
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "LovelyDataProvider.h"
#import <MKNetworkKit/MKNetworkKit.h>

@implementation LovelyDataProvider

static NSString *kCredentialsKey = @"storedCredentialsDict";

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - Init
//----------------------------------------------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    static LovelyDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LovelyDataProvider alloc] init];
    });
    return sharedInstance;
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - Init datasource
//----------------------------------------------------------------------------------------------------------------------
- (NSMutableDictionary *)theCredentialsDict
{
    if (_theCredentialsDict == nil) {
        _theCredentialsDict = [self loadCredentials];
        if (_theCredentialsDict == nil) {
            _theCredentialsDict = [[NSMutableDictionary alloc]initWithCapacity:10];
        }
    }
    return _theCredentialsDict;
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - Try loading persisted datasource
//----------------------------------------------------------------------------------------------------------------------
- (NSMutableDictionary *)loadCredentials
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kCredentialsKey]) {
        NSLog(@"Got credentials from userDefaults");
        return ((NSDictionary *)[userDefaults objectForKey:kCredentialsKey]).mutableCopy;
    }
    return nil;
}

- (BOOL)hasCredentials
{
    return self.theCredentialsDict.count > 0;
}

- (void)setUserName:(NSString *)userName andPassword:(NSString *)password
{
    self.theCredentialsDict = @{
                                @"userName" : userName,
                                @"password" : password
                                }.mutableCopy;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.theCredentialsDict forKey:kCredentialsKey];
    [userDefaults synchronize];


}

- (void)removeCredentials
{
    self.theCredentialsDict = [NSMutableDictionary new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kCredentialsKey];
    [userDefaults synchronize];

}





@end
