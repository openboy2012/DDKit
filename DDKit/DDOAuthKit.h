//
//  DDOAuthKit.h
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DDUnionLoginType) {
    DDUnionLoginTypeWeixin       =    1 << 0,
    DDUnionLoginTypeQQ           =    1 << 1,
    DDUnionLoginTypeAlipay       =    1 << 2,
    DDUnionLoginTypeWeibo        =    1 << 3
};

typedef void(^ OAuthResult)(id result);

@interface DDOAuthKit : NSObject

+ (instancetype)sharedOAuthKit;

/**
 *  OAtuth Login By QQ
 *
 *  @param result oauth result
 */
- (void)dd_doOAuthByQQ:(OAuthResult)result;

/**
 *  OAtuth Login By Weixin
 *
 *  @param result oauth result
 */
- (void)dd_doOAuthByWeixin:(NSString *)appSecrect
                completion:(OAuthResult)result;

/**
 *  OAtuth Login By Weibo
 *
 *  @param result oauth result
 */
- (void)dd_doOAuthByWeibo:(NSString *)rediectUrl
               completion:(OAuthResult)result;

/**
 *  OAtuth Login By Alipay
 *
 *  @param result oauth result
 */
- (void)dd_doOAuthByAlipay:(OAuthResult)result;

/**
 *  Handle the OpenURL
 *
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

@end
