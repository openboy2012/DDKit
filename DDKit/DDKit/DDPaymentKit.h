//
//  MBBPaymentKit.h
//  MBaoBao
//
//  Created by Diaoshu on 14-6-4.
//  Copyright (c) 2014年 Jia Xing My Bag Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DDPaymentByWeixinNotification;
extern NSString *const DDPaymentByAlipayNotification;

typedef void(^ PaymentResult)(BOOL result);

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

+ (void)registerWeixinPay:(NSString *)appId;

- (void)b2cPayment:(NSDictionary *)params callBack:(PaymentResult)callback;

- (void)c2cPayment:(NSDictionary *)params callBack:(PaymentResult)callback;

+ (BOOL)handleOpenURL:(NSURL *)url;

@end
