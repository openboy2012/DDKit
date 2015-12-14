//
//  DDKitManager.m
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDKitManager.h"
#import "WXApi.h"
#import "WeiboSDK.h"

@interface DDKitManager () {
    NSString *_tencentId;
    NSString *_wxAppId;
    NSString *_wbAppId;
    NSString *_alipayAppId;
    NSString *_alipayPartnerId;
}

@end

@implementation DDKitManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static DDKitManager *kit = nil;
    dispatch_once(&onceToken, ^{
        kit = [[[self class] alloc] init];
    });
    return kit;
}

- (void)registerAlipayAppId:(NSString *)appId partnerId:(NSString *)parterId {
    _alipayAppId = appId?:@"";
    _alipayPartnerId = parterId?:@"";
}

- (void)registerTencentId:(NSString *)tencentId {
    _tencentId = tencentId?:@"";
}

- (void)registerWeiboAppId:(NSString *)wbAppId {
    _wbAppId = wbAppId?:@"";
    [WeiboSDK registerApp:_wbAppId];
}

- (void)registerWeixinAppId:(NSString *)wxAppId {
    _wxAppId = wxAppId?:@"";
    [WXApi registerApp:_wxAppId];
}

@end
