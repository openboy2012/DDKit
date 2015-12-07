//
//  UIImage+DDKit.h
//  DDKit
//
//  Created by DeJohn Dong on 14-12-21.
//  Copyright (c) 2014年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DDKit)

/**
 *  Create a pure color image only use the code
 *
 *  @param size  Size of the image
 *  @param color Pure color of the image
 *
 *  @return created image 
 */
+ (UIImage *)dd_createImageWithCGSize:(CGSize)size color:(UIColor *)color;
+ (UIImage *)dd_createImageWithCGSize:(CGSize)size andColor:(UIColor *)color __deprecated_msg("Use `dd_createImageWithCGSize:color:`");

/**
 *  Create a arrow image use CoreGraphics methods.
 *
 *  @param color The arrow color.
 *
 *  @return The arrow image.
 */
+ (UIImage *)dd_navigtionBarBackButtonImage:(UIColor *)color;

@end
