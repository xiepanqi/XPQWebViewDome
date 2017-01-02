//
//  UIColor+XPQAdd.m
//  XPQWebViewDome
//
//  Created by apple on 2017/1/2.
//  Copyright © 2017年 XPQ. All rights reserved.
//

#import "UIColor+XPQAdd.h"

@implementation UIColor (XPQAdd)

+ (UIColor *)colorWithDictionary:(NSDictionary *)dict {
    CGFloat red = [dict[@"red"] floatValue];
    CGFloat green = [dict[@"green"] floatValue];
    CGFloat blue = [dict[@"blue"] floatValue];
    CGFloat alpha = dict[@"alpha"] ? [dict[@"alpha"] floatValue] : 1.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithRGBValue:(NSUInteger)value {
    CGFloat red = ((value >> 16) & 0xFF) / 255.0;
    CGFloat green = ((value >> 8) & 0xFF) / 255.0;
    CGFloat blue = (value & 0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
