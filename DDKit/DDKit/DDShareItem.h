//
//  DDShareItem.h
//  DDShareKit
//
//  Created by Diaoshu on 15-3-19.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDShareItem : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) UIImage *image;

- (NSDictionary *)callbackParams;

@end