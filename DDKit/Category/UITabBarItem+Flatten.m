//
//  UITabBarItem+Flatten.m
//  DDKit
//
//  Created by Diaoshu on 15-1-14.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import "UITabBarItem+Flatten.h"

@implementation UITabBarItem (Flatten)

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    UITabBarItem *tabBarItem = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.9) {
        tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    } else {
        tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:nil tag:0];
        [tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:image];
    }
    return tabBarItem;
}

@end
