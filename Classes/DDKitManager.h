//
//  DDKitManager.h
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDKitManager : NSObject

#pragma mark - Internal vairible
@property (nonatomic, readonly) NSString *tencentId;
@property (nonatomic, readonly) NSString *wxAppId;
@property (nonatomic, readonly) NSString *wbAppId;
@property (nonatomic, readonly) NSString *alipayAppId;
@property (nonatomic, readonly) NSString *alipayPartnerId;

#pragma mark - Get & Set Properties
@property (nonatomic, copy) NSString *weiboRedirectUrl;
@property (nonatomic, copy) NSString *alipayRSAPublicKey;
@property (nonatomic, copy) NSString *alipayRSAPrivateKey;

+ (instancetype)sharedManager;

- (void)registerTencentId:(NSString *)tencentId;

- (void)registerWeixinAppId:(NSString *)wxAppId;

- (void)registerWeiboAppId:(NSString *)wbAppId;

- (void)registerAlipayAppId:(NSString *)appId
                  partnerId:(NSString *)parterId;

@end
