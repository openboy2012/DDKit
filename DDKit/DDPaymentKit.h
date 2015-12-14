//
//  DDPaymentKit.h
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DDPaymentByWeixinNotification;
extern NSString *const DDPaymentByAlipayNotification;

typedef void(^ DDPaymentResult)(BOOL result);

@interface DDPaymentKit : NSObject

@property (nonatomic, copy) NSString *partner;
@property (nonatomic, copy) NSString *seller;
@property (nonatomic, copy) NSString *outTradeNo;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *totalFee;
@property (nonatomic, copy) NSString *notifyURL;

@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *paymentType;
@property (nonatomic, copy) NSString *inputCharset;
@property (nonatomic, copy) NSString *itBPay;
@property (nonatomic, copy) NSString *showUrl;

+ (instancetype)sharedPaymentKit;

- (void)b2cPayment:(NSDictionary *)params callBack:(DDPaymentResult)callback;

- (void)c2cPayment:(NSDictionary *)params callBack:(DDPaymentResult)callback;

+ (BOOL)handleOpenURL:(NSURL *)url;

@end
