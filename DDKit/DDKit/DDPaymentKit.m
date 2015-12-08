//
//  MBBPaymentKit.m
//  MBaoBao
//
//  Created by Diaoshu on 14-6-4.
//  Copyright (c) 2014年 Jia Xing My Bag Co., Ltd. All rights reserved.
//

#import "DDPaymentKit.h"
#import <AlipaySDK/AlipaySDK.h>
#import <CommonCrypto/CommonCrypto.h>
#import "DataSigner.h"
#import "DataVerifier.h"
#import "WXApi.h"
#import <NSString+DDKit.h>
#import <UIView+DDKit.h>

#define ALIPAY_NOTIFY_URL @"http://mapi.bstapp.cn/v1/pay/alipay/notify"

//alipay b2c keys
#define AlipayPartner @""
#define AlipaySeller @""
#define AlipayRSAPublicKey @""
#define AlipayRSAPrivateKey @""

//weixinPay b2c keys
#define weixinPartnerId @""
#define weixinAppKey @""
#define weixinPayNotifyURL @""
#define weixinTraceId @""

NSString *const PaymentByWeixinNotification = @"PaymentByWeixinNotification";
NSString *const PaymentByAlipayNotification = @"PaymentByAlipayNotification";


@interface DDPaymentKit()<WXApiDelegate>{
    NSString *rsaPrivateKey;
    NSString *rsaPublicKey;
    NSString *weixinAppId;
}

@property (nonatomic, strong) PaymentResult callBack;

@end

@implementation DDPaymentKit

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentResultByWeixin:) name:PaymentByWeixinNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentResultByAlipay:) name:PaymentByAlipayNotification object:nil];
    }
    return self;
}

+ (instancetype)sharedPaymentKit{
    static dispatch_once_t onceToken;
    static DDPaymentKit *kit = nil;
    dispatch_once(&onceToken, ^{
        kit = [[[self class] alloc] init];
    });
    return kit;
}


- (NSString *)description {
	NSMutableString * discription = [NSMutableString string];
    if (self.partner) {
        [discription appendFormat:@"partner=\"%@\"", self.partner];
    }
    if (self.seller) {
        [discription appendFormat:@"&seller_id=\"%@\"", self.seller];
    }
	if (self.outTradeNo) {
        [discription appendFormat:@"&out_trade_no=\"%@\"", self.outTradeNo];
    }
	if (self.subject) {
        [discription appendFormat:@"&subject=\"%@\"", self.subject];
    }
	if (self.body) {
        [discription appendFormat:@"&body=\"%@\"", self.body];
    }
	if (self.totalFee) {
        [discription appendFormat:@"&rmb_fee=\"%@\"", self.totalFee];//rmb_fee表示支付人民币
    }
    if (self.notifyURL) {
        [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL];
    }
    if (self.service) {
        [discription appendFormat:@"&service=\"%@\"",self.service];//mobile.securitypay.pay
    }
    if (self.paymentType) {
        [discription appendFormat:@"&payment_type=\"%@\"",self.paymentType];//1
    }
    if (self.inputCharset) {
        [discription appendFormat:@"&_input_charset=\"%@\"",self.inputCharset];//utf-8
    }
    if (self.itBPay) {
        [discription appendFormat:@"&it_b_pay=\"%@\"",self.itBPay];//30m
    }
    if (self.showUrl) {
        [discription appendFormat:@"&show_url=\"%@\"",self.showUrl];//m.alipay.com
    }
    [discription appendFormat:@"&forex_biz=\"%@\"",@"FP"];
    [discription appendFormat:@"&currency=\"%@\"",@"HKD"];
	return discription;
}

#pragma mark - Public Methods

+ (void)registerWeixinPay:(NSString *)appId{
    [DDPaymentKit sharedPaymentKit] -> weixinAppId = appId;
}

- (void)b2cPayment:(NSDictionary *)params callBack:(PaymentResult)callback{
    self.callBack = callback;
    self.partner = AlipayPartner;
    self.seller = AlipaySeller;
    rsaPrivateKey = AlipayRSAPrivateKey;
    rsaPublicKey = AlipayRSAPublicKey;
    self.notifyURL = ALIPAY_NOTIFY_URL;
    [self handleAlipayInfo:params];
}

- (void)c2cPayment:(NSDictionary *)params callBack:(PaymentResult)callback{

}

#pragma mark - Payment by alipay methods

- (void)handleAlipayInfo:(NSDictionary *)param{

    self.outTradeNo = [param objectForKey:@"payId"];
    self.subject = [param objectForKey:@"title"];
    self.body = [param objectForKey:@"body"];
    self.totalFee = [NSString stringWithFormat:@"%.2f", [[param objectForKey:@"price"] floatValue]];
    
    self.service = @"mobile.securitypay.pay";
    self.paymentType = @"1";
    self.inputCharset = @"utf-8";
    self.itBPay = @"30m";
    
    //应用注册scheme用于安全支付成功后重新唤起商户应用
    NSString *appScheme = @"best";
    NSString *orderSpec = [self description];
    
    id <DataSigner> signer = CreateRSADataSigner(rsaPrivateKey);
    
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            if(self.callBack){
                self.callBack([self isPayResult:resultDic]);
            }
        }];
    }
}

- (void)paymentResultByAlipay:(NSNotification *)notification{
    if(self.callBack){
        self.callBack ([self isPayResult:[notification object]]);
    }
}

- (void)doC2cPaymentProgress:(NSDictionary *)result{

    self.body = @"暂无商品描述";
    self.outTradeNo = result[@"payId"];
    self.subject = result[@"itemsInfoName"];
    self.totalFee = [NSString stringWithFormat:@"%.2f", [result[@"orderAmount"] floatValue]];
    self.service = @"mobile.securitypay.pay";
    self.paymentType = @"1";
    self.inputCharset = @"utf-8";
    self.itBPay = @"30m";
    
    
    NSString *appScheme = @"mbb"; //应用注册scheme用于安全支付成功后重新唤起商户应用
    NSString *orderSpec = [self description];
    
    
    id <DataSigner> signer = CreateRSADataSigner(rsaPrivateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            if(self.callBack){
                self.callBack([self isPayResult:resultDic]);
            }
        }];
    }
}

- (BOOL)isPayResult:(NSDictionary *)resultDict{
    if([resultDict[@"resultStatus"] isEqualToString:@"9000"]){
        NSString *result = resultDict[@"result"];
        if ([result rangeOfString:@"&success=\"true\""].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Payment by Weixin methods

- (void)paymentByWeiXin:(NSString *)orderId{
//    [MBBWeixinPaymentInfo getWeixinPaymentInfo:@{@"orderId":orderId}
//                                       showHUD:YES
//                          parentViewController:self
//                                       success:^(id data) {
//                                           [self handleWeixinPay:data];
//                                       }
//                                       failure:^(NSError *error, NSString *message) {
//                                       }];
}

- (NSString *)createSHA1Sign:(NSMutableDictionary *)signParams
{
    NSMutableString *signString=[NSMutableString string];
    //按字母顺序排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if ( [signString length] > 0) {
            [signString appendString:@"&"];
        }
        [signString appendFormat:@"%@=%@", categoryId, [signParams objectForKey:categoryId]];
        
    }
    //得到sha1 sign签名
    NSString *sign = [self sha1:signString];
    
    return sign;
}


- (NSString *)sha1:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

//- (void)handleWeixinPay:(MBBWeixinPaymentInfo *)info{
//    
//    NSString *package = info.package;
//    NSString *time_stamp,*nonce_str,*sign;
//    time_t now = 0 ;
//    time_stamp  = [NSString stringWithFormat:@"%d", (int)now];
//    nonce_str	= [time_stamp dd_md5];
//    
//    //创建预支付单请求参数
//    NSMutableDictionary *prePayParams = [NSMutableDictionary dictionary];
//    [prePayParams setObject:weixinAppId?:@""          forKey:@"appid"];
//    [prePayParams setObject:weixinAppKey              forKey:@"appkey"];
//    [prePayParams setObject:nonce_str                 forKey:@"noncestr"];
//    [prePayParams setObject:package                   forKey:@"package"];
//    [prePayParams setObject:time_stamp                forKey:@"timestamp"];
//    [prePayParams setObject:weixinTraceId             forKey:@"traceid"];
//    
//    
//    //生成支付签名
//    sign = [self createSHA1Sign:prePayParams];
//    //增加非参与签名的额外参数
//    [prePayParams setObject:@"sha1"  forKey:@"sign_method"];
//    [prePayParams setObject:sign     forKey:@"app_signature"];
//    
//    NSError *error = nil;
//    //ios5.0 自带的NSJSONSerialization序列化
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:prePayParams options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *data = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    NSString *getPaymentBillURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/pay/genprepay?access_token=%@",info.accessToken];
//    NSMutableURLRequest *getPaymentBillRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getPaymentBillURL]];
//    [getPaymentBillRequest setHTTPMethod:@"POST"];
//    [getPaymentBillRequest addValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
//    //设置编码
//    [getPaymentBillRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
//    [getPaymentBillRequest setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
//    NSData *billData = [NSURLConnection sendSynchronousRequest:getPaymentBillRequest returningResponse:nil error:nil];
//    NSDictionary *billDict = [NSJSONSerialization JSONObjectWithData:billData options:NSJSONReadingMutableContainers error:&error];
//
//    [self sendPay:billDict];
//
//}
//
//- (void)sendPay:(NSDictionary *)billDict{
//    NSString *prePayid = [billDict objectForKey:@"prepayid"];
//    if ( prePayid != nil) {
//        //重新按提交格式组包，微信客户端5.0.3以前版本只支持package=Sign=***格式，须考虑升级后支持携带package具体参数的情况
//        //package       = [NSString stringWithFormat:@"Sign=%@",package];
//        time_t  now = 0;
//        NSString *package         = @"Sign=WXPay";
//        NSString *time_stamp,*nonce_str;
//        time_stamp  = [NSString stringWithFormat:@"%d", (int)now];
//        nonce_str	= [time_stamp dd_md5];
//        //签名参数列表
//        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
//        [signParams setObject: weixinAppId     forKey:@"appid"];
//        [signParams setObject: weixinAppKey    forKey:@"appkey"];
//        [signParams setObject: nonce_str       forKey:@"noncestr"];
//        [signParams setObject: package         forKey:@"package"];
//        [signParams setObject: weixinPartnerId forKey:@"partnerid"];
//        [signParams setObject: time_stamp      forKey:@"timestamp"];
//        [signParams setObject: prePayid        forKey:@"prepayid"];
//        
//        //生成签名
//        NSString *sign = [self createSHA1Sign:signParams];
//        
//        //调起微信支付
//        PayReq *req = [[PayReq alloc] init];
//        req.openID      = weixinAppId;
//        req.partnerId   = weixinPartnerId;
//        req.prepayId    = prePayid;
//        req.nonceStr    = nonce_str;
//        req.timeStamp   = (UInt32)now;
//        req.package     = package;
//        req.sign        = sign;
//        [WXApi safeSendReq:req];
//    }
//}

- (void)paymentResultByWeixin:(NSNotification *)notification{
    if(self.callBack){
        self.callBack ([[[notification userInfo] objectForKey:@"PaymentStatus"] boolValue]);
    }
}

#pragma mark - WXApiDelegate Methods

- (void)onResp:(BaseResp *)resp{
    if(![resp isKindOfClass:[PayResp class]])
        return;
    switch (resp.errCode) {
        case 0:{
            [[NSNotificationCenter defaultCenter] postNotificationName:PaymentByWeixinNotification object:nil userInfo:@{@"PaymentStatus":[NSNumber numberWithBool:YES]}];
        }
            break;
        case -2:{
            [UIView dd_showMessage:@"微信支付已取消"];
        }
            break;
        default:
            [UIView dd_showMessage:@"微信支付发生未知错误"];
            break;
    }
}

#pragma mark - OpenURL Handle Methods

+ (BOOL)handleOpenURL:(NSURL *)url{
    //如果极简SDK不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:PaymentByAlipayNotification
                                                                                                          object:resultDic];
                                                  }];
        return YES;
    }
    //处理微信支付
    else if([url.host isEqualToString:@"pay"] && [url.scheme hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:[DDPaymentKit sharedPaymentKit]];
    }else{
        return NO;
    }
}

@end
