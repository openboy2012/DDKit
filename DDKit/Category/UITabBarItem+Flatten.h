//
//  UITabBarItem+Flatten.h
//  DDKit
//
//  Created by Diaoshu on 15-1-14.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (Flatten)

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

@end
