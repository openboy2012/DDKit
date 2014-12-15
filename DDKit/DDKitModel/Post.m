//
//  Post.m
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "Post.h"

@implementation Post

+ (NSString *)jsonNode{
    return @"data";
}

+ (NSDictionary *)jsonMappings{
    id userHandler = [User mappingWithKey:@"user" mapping:[User jsonMappings]];
    NSDictionary *jsonMappings = @{@"user":userHandler};
    return jsonMappings;
}

+ (void)getPostList:(id)params parentVC:(id)viewController showHUD:(BOOL)show success:(DDBasicSuccessBlock)success failure:(DDBasicFailureBlock)failure{
    [[self class] get:@"stream/0/posts/stream/global" params:params showHUD:show parentViewController:viewController success:success failure:failure];
}

@end

@implementation User

+ (NSDictionary *)jsonMappings{
    return @{@"avatar_image.url":@"avatarImageURLString"};
}

@end