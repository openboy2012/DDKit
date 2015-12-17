//
//  DDShareItem.h
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
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