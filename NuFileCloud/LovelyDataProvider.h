//
//  LovelyDataProvider.h
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LovelyDataProvider : NSObject

//extern NSString* const kCredentialsKey;
//extern NSString* const kFeedKey;

//----------------------------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSDictionary  *theCredentialsDict;
@property (nonatomic, strong) NSDictionary  *theFeedDict;
//----------------------------------------------------------------------------------------------------------------------
+ (LovelyDataProvider *)sharedInstance;
- (BOOL)hasCredentials;
- (void)setUserName:(NSString *)userName andPassword:(NSString *)password;
- (void)removeCredentials;
- (BOOL)hasLocalFeed;
- (BOOL)storeFeed:(NSDictionary *)feed;
- (void)removeFeedWithFile:(BOOL)removeFile;
- (NSString *)SHA1;
//----------------------------------------------------------------------------------------------------------------------

@end
