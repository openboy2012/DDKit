//
//  DDOAuthKit.h
//  DDKit
//
//  Created by Diaoshu on 15-3-24.
//  Copyright (c) 2015年 DDKit inc. All rights reserved.
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

+ (instancetype)manager;

- (void)registerTencentAppId:(NSString *)appId;

- (void)registerWeixinAppKey:(NSString *)appKey
             weixinAppSecret:(NSString *)secret;

/**
 *  OAtuth Login By QQ
 *
 *  @param result oauth result
 */
- (void)doOAuthByQQ:(OAuthResult)result;

/**
 *  OAtuth Login By Weixin
 *
 *  @param result oauth result
 */
- (void)doOAuthByWeixin:(OAuthResult)result;

/**
 *  OAtuth Login By Weibo
 *
 *  @param result oauth result
 */
- (void)doOAuthByWeibo:(OAuthResult)result;

/**
 *  OAtuth Login By Alipay
 *
 *  @param result oauth result
 */
- (void)doOAuthByAlipay:(OAuthResult)result;

/**
 *  Handle the OpenURL
 *
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

@end
