//
//  Post.h
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import <DDModel.h>

@interface User : DDModel

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatarImageURLString;

@end

@interface Post : DDModel

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) User *user;


+ (void)getPostList:(id)params
           parentVC:(id)viewController
            showHUD:(BOOL)show
            success:(DDResponseSuccessBlock)success
            failure:(DDResponseFailureBlock)failure;

@end

