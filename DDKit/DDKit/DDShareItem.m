//
//  DDShareItem.m
//  DDShareKit
//
//  Created by Diaoshu on 15-3-19.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "DDShareItem.h"

@implementation DDShareItem

- (NSDictionary *)callbackParams {
    NSDictionary *params = @{@"type":self.type?:@"",
                             @"content":self.link?:@""};
    return params;
}

@end
