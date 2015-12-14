//
//  DDShareItem.m
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import "DDShareItem.h"

@implementation DDShareItem

- (NSDictionary *)callbackParams {
    NSDictionary *params = @{@"type":self.type?:@"",
                             @"content":self.link?:@""};
    return params;
}

@end
