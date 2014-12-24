//
//  NSNumber+Screen.m
//  DDKit
//
//  Created by Diaoshu on 14-12-24.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "NSNumber+Screen.h"

@implementation NSNumber (Screen)

+ (CGFloat)propertyWidth:(CGFloat)originPoint{
    CGFloat width = 0.0f;
    if(!VERSION_GREATER(7.9)){
        width = 320.0 - originPoint;
    }else{
        width = [UIScreen mainScreen].bounds.size.width - originPoint;
    }
    return width;
}

@end
