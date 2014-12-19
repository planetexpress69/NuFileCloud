//
//  LovelyDataProvider.m
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "LovelyDataProvider.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "NSString+Additions.h"

@implementation LovelyDataProvider

NSString * const kCredentialsKey    = @"storedCredentialsDict";
NSString * const kFeedKey           = @"storedFeedDict";

// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Init
// ---------------------------------------------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    static LovelyDataProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LovelyDataProvider alloc] init];
    });
    return sharedInstance;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Init credentials dict
// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *)theCredentialsDict
{
    if (_theCredentialsDict == nil) {
        _theCredentialsDict = [self loadCredentials];
    }
    return _theCredentialsDict;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Init feed dict
// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *)theFeedDict
{
    if (_theFeedDict == nil) {
        _theFeedDict = [self loadFeed];
    }
    return _theFeedDict;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Try loading persisted datasource
// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *)loadCredentials
{
    NSLog(@"loadCredentials");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kCredentialsKey]) {
        NSLog(@"Got credentials from userDefaults!");
        return ((NSDictionary *)[userDefaults objectForKey:kCredentialsKey]);
    }
    return nil;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Try loading persisted feed
// ---------------------------------------------------------------------------------------------------------------------
- (NSDictionary *)loadFeed
{


    NSString *documentsDir      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *feedDir           = [NSString stringWithFormat:@"%@%@", documentsDir, @"/feed/"];
    NSString *feedFile          = [NSString stringWithFormat:@"%@%@", feedDir, @"localfeed.plist"];

    if ([[NSFileManager defaultManager]fileExistsAtPath:feedFile]) {
        NSDictionary *feed = [NSDictionary dictionaryWithContentsOfFile:feedFile];
        return feed;
    }
    NSLog(@"Feed is nil!");
    return nil;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Check for local credentials
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)hasCredentials
{
    return _theCredentialsDict && _theCredentialsDict.count == 2;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Check for local feed
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)hasLocalFeed
{
    return self.theFeedDict && self.theFeedDict.count > 0;
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Check for local feed
// ---------------------------------------------------------------------------------------------------------------------
- (void)setUserName:(NSString *)userName andPassword:(NSString *)password
{
    self.theCredentialsDict = @{ @"userName" : userName, @"password" : password };
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.theCredentialsDict forKey:kCredentialsKey];
    [userDefaults synchronize];
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Remove local credentials
// ---------------------------------------------------------------------------------------------------------------------
- (void)removeCredentials
{
    self.theCredentialsDict         = nil;
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kCredentialsKey];
    [userDefaults synchronize];
}


// ---------------------------------------------------------------------------------------------------------------------
#pragma mark - Remove local feed
// ---------------------------------------------------------------------------------------------------------------------
- (void)removeFeedWithFile:(BOOL)removeFile
{
    self.theFeedDict = nil;
    if (removeFile) {

        NSFileManager *fileManager  = [NSFileManager defaultManager];
        NSString *documentsDir      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *feedDir           = [NSString stringWithFormat:@"%@%@", documentsDir, @"/feed/"];
        NSString *feedFile          = [NSString stringWithFormat:@"%@%@", feedDir, @"localfeed.plist"];
        NSError *removeError        = nil;

        [fileManager removeItemAtPath:feedFile error:&removeError];
        if (removeError) {
            NSLog(@"Error: %@", removeError);
        }

    }
}

- (BOOL)storeFeed:(NSDictionary *)feed
{
    _theFeedDict                = feed;
    
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSString *documentsDir      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *feedDir           = [NSString stringWithFormat:@"%@%@", documentsDir, @"/feed/"];
    NSString *feedFile          = [NSString stringWithFormat:@"%@%@", feedDir, @"localfeed.plist"];
    BOOL isDir                  = NO;
    NSError *createError        = nil;


    if (![fileManager fileExistsAtPath:feedDir isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:feedDir withIntermediateDirectories:YES attributes:nil error:&createError];
        if (!createError) {
            BOOL success = [_theFeedDict writeToFile:feedFile atomically:YES];
            return success;
        } else {
            NSLog(@"createError: %@", createError);
        }
    } else {
        NSLog(@"*** Successfully wrote updated feed!");

        BOOL success = [_theFeedDict writeToFile:feedFile atomically:YES];
        return success;
    }
    return NO;
}

- (NSString *)SHA1
{
    NSString *sCredentials = [NSString stringWithFormat:@"%@%@",
                              [_theCredentialsDict[@"userName"]lowercaseString],
                              _theCredentialsDict[@"password"]];
    NSLog(@"sCredentials: %@", sCredentials);
    return [sCredentials SHA1];
}

@end
