//
//  DDOAuthKit.m
//  DDKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import "DDOAuthKit.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "WechatAuthSDK.h"
#import "DDCategory.h"
#import "DDKitManager.h"

@interface DDOAuthKit()<WeiboSDKDelegate, WXApiDelegate, TencentLoginDelegate, TencentSessionDelegate,TencentApiInterfaceDelegate> {
    TencentOAuth *tcOauth;
    OAuthResult oauthResult;
    
    NSString *tencentAppId;
    NSString *weiboCallbackURL;
    NSString *weixinAppKey;
    NSString *weixinSecretKey;
}

@end

@implementation DDOAuthKit

+ (instancetype)sharedOAuthKit {
    static DDOAuthKit *kit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kit = [[DDOAuthKit alloc] init];
    });
    return kit;
}

#pragma mark - TencentLogin Delegate Methods

- (BOOL)onTencentReq:(TencentApiReq *)req
{
    return YES;
}

- (void)tencentDidLogin {
    [UIView dd_showMessage:@"正在授权中..."];
    if (tcOauth.accessToken && 0 != [tcOauth.accessToken length]){
        [self onGetUserInfo];
    }else{
        [UIView dd_showMessage:@"登录不成功 没有获取accesstoken"];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled){
        [UIView dd_showMessage:@"QQ授权已取消"];
    } else {
        [UIView dd_showMessage:@"QQ授权失败"];
    }
}

- (void)tencentDidNotNetWork{
    [UIView dd_showDetailMessage:@"网络已断开" onParentView:nil];
}

#pragma mark - TencentSession Delegate Methods

- (void)getUserInfoResponse:(APIResponse *)response {
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary *tcUserDict = response.jsonResponse;
        NSDictionary *params = @{@"unionType":@(DDUnionLoginTypeQQ),
                                 @"openId":[tcOauth openId],
                                 @"passportId":@"501",
                                 @"passportName":@"QQ",
                                 @"email":@"",
                                 @"nickname":[tcUserDict objectForKey:@"nickname"]?:@""};
        if(oauthResult){
            oauthResult(params);
        }
    } else {
        [UIView dd_showDetailMessage:response.errorMsg onParentView:nil];
    }
}

#pragma mark - WXApi Delegate Methods

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if(authResp.errCode == 0 && 0 != [authResp.code length]){
            [UIView dd_showMessage:@"微信授权成功"];
            [self wxOAuthByCode:authResp.code];
        }else if(authResp.errCode == -2){
            [UIView dd_showMessage:@"微信授权已取消"];
        }else{
            [UIView dd_showMessage:@"微信授权未知错误"];
        }
    }
}

#pragma mark - WeiboSDK Delegate Methods

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if([response isKindOfClass:[WBAuthorizeResponse class]]){
        if(response.statusCode == WeiboSDKResponseStatusCodeSuccess){
            WBAuthorizeResponse *wbResp = (WBAuthorizeResponse *)response;
            [self wbOAuthByUid:[wbResp userID] andToken:[wbResp accessToken]];
        }else if(response.statusCode == WeiboSDKResponseStatusCodeAuthDeny){
            [UIView dd_showMessage:@"新浪微博授权失败"];
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
            [UIView dd_showMessage:@"新浪微博授权已取消"];
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

#pragma mark - Custom Methods

- (void)dd_doOAuthByQQ:(OAuthResult)result{
    oauthResult = result;
    
    if(([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) ||
       ([TencentOAuth iphoneQZoneInstalled] && [TencentOAuth iphoneQZoneSupportSSOLogin])){
        if(!tcOauth)
            tcOauth = [[TencentOAuth alloc] initWithAppId:[DDKitManager sharedManager].tencentId
                                              andDelegate:self];
        NSArray *_permissions = [NSArray arrayWithObjects:
                                 kOPEN_PERMISSION_GET_USER_INFO,
                                 kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                 nil];
        [tcOauth authorize:_permissions inSafari:YES];
    }else{
        [UIView dd_showDetailMessage:@"您的手机没有安装QQ相关客户端，无法使用该功能" onParentView:nil];
    }
}

- (void)dd_doOAuthByAlipay:(OAuthResult)result {
    oauthResult = result;
    NSString *pid = @"";
    NSString *appid = @"";
    NSString *returnUri = @"";
    
    APayAuthInfo *info = [[APayAuthInfo alloc] initWithAppID:appid
                                                         pid:pid
                                                 redirectUri:returnUri];
    [[AlipaySDK defaultService] authWithInfo:info callback:^(NSDictionary *resultDic) {
        oauthResult(resultDic);
    }];
}

- (void)dd_doOAuthByWeibo:(NSString *)rediectUrl completion:(OAuthResult)result {
    oauthResult = result;
    WBAuthorizeRequest *weiboReq = [WBAuthorizeRequest request];
    weiboReq.redirectURI = rediectUrl?:@"https://api.weibo.com/oauth2/default.html";
    weiboReq.scope = @"all";
    [WeiboSDK sendRequest:weiboReq];
}

- (void)dd_doOAuthByWeixin:(NSString *)appSecrect completion:(OAuthResult)result {
    oauthResult = result;
    weixinSecretKey = appSecrect;
    
    if(![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        [UIView dd_showDetailMessage:@"您的手机没有安装微信客户端，无法使用该功能" onParentView:nil];
        return;
    }
    
    //构造SendAuthReq结构体
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"ddkit.com" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

#pragma mark - Custom Methods

- (void)onGetUserInfo {
    if(![tcOauth getUserInfo]){
        [UIView dd_showMessage:@"获取用户信息可能授权已过期，请重新获取"];
    }
}

#pragma mark - Weibo OAuth Handle Methods

- (void)wbOAuthByUid:(NSString *)uid andToken:(NSString *)token {
    
    NSString *sinaUserInfoURL = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@",token,uid];
    NSURLRequest *userInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sinaUserInfoURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    NSData *data = [NSURLConnection sendSynchronousRequest:userInfoRequest returningResponse:nil error:nil];
    NSError *error = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *params = @{@"unionType":@(DDUnionLoginTypeWeibo),
                             @"openId":uid,
                             @"passportId":@"25",
                             @"passportName":@"weibo",
                             @"email":@"",
                             @"nickname":jsonData[@"name"]?:@""};
    if(oauthResult){
        oauthResult(params);
    }
}

#pragma mark - Weixin OAuth Handle Methods

- (void)wxOAuthByCode:(NSString *)code
{
    NSString *authURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",weixinAppKey?:@"",weixinSecretKey?:@"",code];
    NSURLRequest *authRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:authURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    NSData *data = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:nil error:nil];
    NSError *error = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSString *userInfoURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",jsonData[@"access_token"],jsonData[@"openid"]];
    NSURLRequest *userInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:userInfoURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    NSData *userData = [NSURLConnection sendSynchronousRequest:userInfoRequest returningResponse:nil error:nil];
    NSDictionary *userJsonData = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:&error];
    if(!error && [userJsonData[@"unionid"] length] > 0 && oauthResult){
        NSDictionary *params =  @{@"unionType":@(DDUnionLoginTypeWeixin),
                                  @"openId":[userJsonData objectForKey:@"unionid"],
                                  @"passportId":@"707",
                                  @"passportName":@"weixin",
                                  @"email":@"",
                                  @"nickname":[userJsonData objectForKey:@"nickname"]};
        oauthResult(params);
    }
}

#pragma mark -

+ (BOOL)handleOpenURL:(NSURL *)url{
    if ([url.host isEqualToString:@"platformapi"]) {
        //支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            [DDOAuthKit sharedOAuthKit]->oauthResult(resultDic);
        }];
        return YES;
    }else if([url.scheme hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }else if([url.scheme hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:[DDOAuthKit sharedOAuthKit]];
    }else if ([url.scheme hasPrefix:@"wx"] && [url.host isEqualToString:@"oauth"]) {
        return [WXApi handleOpenURL:url delegate:[DDOAuthKit sharedOAuthKit]];
    }
    return NO;
}

@end