//
//  UIImage+Additions.m
//  NuFileCloud
//
//  Created by Martin Kautz on 28.10.14.
//  Copyright (c) 2014 JAKOTA Design Group. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)
+ (UIImage *)squareImageWithColor:(UIColor *)color dimension:(int)dimension {
    CGRect rect = CGRectMake(0, 0, dimension, dimension);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end
