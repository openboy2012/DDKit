//
//  UIImage+DDKit.m
//  DDKit
//
//  Created by Diaoshu on 14-12-21.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "UIImage+DDKit.h"

@implementation UIImage (DDKit)

+ (UIImage *)createImageWithCGSize:(CGSize)size andColor:(UIColor *)color{
    CGSize imageSize = size;
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
