//
//  NSString+Additions.m
//  NuFileCloud
//
//  Created by Martin Kautz on 23.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "NSString+Additions.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (Common)
// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)isBlank
{
    if([[self stringByStrippingWhitespace] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)contains:(NSString *)string
{
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)stringByStrippingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSArray *)splitOnChar:(char)ch
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    int start = 0;
    for(int i=0; i<[self length]; i++) {

        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == [self length] - 1;

        if(isAtSplitChar || isAtEnd) {
            //take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;

            if(isAtSplitChar)
                range.length -= 1;

            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }

        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
        if(isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }

    return results;
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to
{
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}

// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)SHA1
{
    const char *ptr = [self UTF8String];
    int i =0;
    int len = (int)strlen(ptr);
    Byte byteArray[len];
    while (i!=len)
    {
        unsigned eachChar = *(ptr + i);
        unsigned low8Bits = eachChar & 0xFF;
        byteArray[i] = low8Bits;
        i++;
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(byteArray, len, digest);
    NSMutableString *hex = [NSMutableString string];
    for (int i=0; i<20; i++)
        [hex appendFormat:@"%02x", digest[i]];
    NSString *immutableHex = [NSString stringWithString:hex];
    return immutableHex;
}


@end