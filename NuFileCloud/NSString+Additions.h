//
//  NSString+Additions.h
//  NuFileCloud
//
//  Created by Martin Kautz on 23.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL)isBlank;
- (BOOL)contains:(NSString *)string;
- (NSArray *)splitOnChar:(char)ch;
- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
- (NSString *)stringByStrippingWhitespace;
- (NSString *)SHA1;

@end
