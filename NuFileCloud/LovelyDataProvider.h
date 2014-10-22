//
//  LovelyDataProvider.h
//  NuFileCloud
//
//  Created by Martin Kautz on 22.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LovelyDataProvider : NSObject
//----------------------------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSMutableDictionary *theCredentialsDict;
//----------------------------------------------------------------------------------------------------------------------
+ (LovelyDataProvider *)sharedInstance;
- (BOOL)hasCredentials;
- (void)setUserName:(NSString *)userName andPassword:(NSString *)password;
- (void)removeCredentials;
//----------------------------------------------------------------------------------------------------------------------

@end
