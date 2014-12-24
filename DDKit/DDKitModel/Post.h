//
//  Post.h
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "DDBasicModel.h"

@interface User : DDBasicModel

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatarImageURLString;

@end

@interface Post : DDBasicModel

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) User *user;

+ (void)getPostList:(id)params
           parentVC:(id)viewController
            showHUD:(BOOL)show
            success:(DDBasicSuccessBlock)success
            failure:(DDBasicFailureBlock)failure;

@end

