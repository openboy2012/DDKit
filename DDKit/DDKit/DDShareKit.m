//
//  DDShareKit.m
//  DDShareKit
//
//  Created by Diaoshu on 15-3-18.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "DDShareKit.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/WeiBoAPI.h>
#import <MessageUI/MessageUI.h>
#import <UIView+DDKit.h>
#import "WXApi.h"
#import "WeiboSDK.h"

#define DDKitAppDisplayName [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]
#define DDKitImageWithImageName(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"DDKit_iOS_Bundle.bundle/icons/%@",imageName]]

@interface DDShareItemButton : UIControl

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *lblTitle;

@end

@implementation DDShareItemButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        if(!_imageView){
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width * 0.2, frame.size.width * 0.2, frame.size.width * 3/5.0, frame.size.width * 3 / 5.0f)];
        }
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
        if(!_lblTitle){
            _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _imageView.frame.origin.y +_imageView.frame.size.height, frame.size.width, 20.0f)];
        }
        _lblTitle.font = [UIFont systemFontOfSize:12.0f];
        _lblTitle.textAlignment = NSTextAlignmentCenter;
        _lblTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:_lblTitle];
    }
    return self;
}

@end

@interface DDShareKit ()<MFMessageComposeViewControllerDelegate,TCAPIRequestDelegate,TencentSessionDelegate,WeiboSDKDelegate,WXApiDelegate,TencentLoginDelegate,QQApiInterfaceDelegate>{
    CALayer *maskLayer;
    NSMutableArray *shareItems;
    TencentOAuth *tcOauth;
    BOOL imageReady;
    DDShareType oauthBeforeType;
}

@property (nonatomic, strong) UIView *carryView;
@property (nonatomic, strong) UIScrollView *platformScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, weak) id<DDShareKitDelegate> delegate;


@end

@implementation DDShareKit

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.carryView)
        self.carryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 290.0)];
    
    self.carryView.backgroundColor = [UIColor whiteColor];
    
    if(!self.platformScrollView){
        self.platformScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 40.0f, self.view.bounds.size.width, 200.0f)];
        [self getSharePlatforms];
        for (int i = 0 ; i < shareItems.count ; i ++) {
            int row = i / 4;
            int colum = i % 4;
            CGFloat width = [UIScreen mainScreen].bounds.size.width/4.0f ;
            DDShareItemButton *btnV = [[DDShareItemButton alloc] initWithFrame:CGRectMake(colum * width , 80.0 * row + 10.0f, width, 90.0)];
            NSDictionary *item = shareItems[i];
            btnV.tag = [item[@"type"] unsignedIntegerValue];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClicked:)];
            btnV.lblTitle.text = item[@"title"];
//            NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DDKitBundle" ofType:@"bundle"]];
//            NSString *imagePath = [resourceBundle pathForResource:item[@"icon"] ofType:@"png" inDirectory:@"icons"];
//            btnV.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
            btnV.imageView.image = DDKitImageWithImageName(item[@"icon"]);
            [btnV addGestureRecognizer:tap];
            [self.platformScrollView addSubview:btnV];
        }
        [self.platformScrollView dd_addSeparatorWithType:ViewSeparatorTypeVerticalSide];
    }
    [self.carryView addSubview:self.platformScrollView];
    
    if(!self.btnCancel)
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCancel.frame = CGRectMake(0.0, 240.0f, self.view.bounds.size.width, 50.0);
    [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.carryView addSubview:self.btnCancel];
    
    if(!self.lblTitle)
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40.0f)];
    self.lblTitle.font = [UIFont systemFontOfSize:15.0f];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.text = @"分享到";
    [self.carryView addSubview:self.lblTitle];
    
    [self.view addSubview:self.carryView];
    
    
    UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.view addGestureRecognizer:tapHide];
    
    if(!tcOauth)
        tcOauth = [[TencentOAuth alloc] initWithAppId:@""
                                          andDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MFMessageComposeViewControllerDelegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    //Notifies users about errors associated with the interface
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - TCApiRequestDelegate Methods

- (void)cgiRequest:(TCAPIRequest *)request didResponse:(APIResponse *)response{
    if(response.retCode == URLREQUEST_SUCCEED){
        [UIView dd_showMessage:@"腾讯微博分享成功"];
        if([self.delegate respondsToSelector:@selector(callBack:)]){
            [self.delegate callBack:[self.shareContent callbackParams]];
        }
    }
}

#pragma mark - QQApiInterfaceDelegate Methods

- (void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[SendMessageToQQResp class]]){
        SendMessageToQQResp *response = (SendMessageToQQResp *)resp;
        if([response.result isEqualToString:@"0"]){
            [UIView dd_showMessage:@"分享成功"];
            if([self.delegate respondsToSelector:@selector(callBack:)]){
                [self.delegate callBack:[self.shareContent callbackParams]];
            }
        }
    }else if([resp isKindOfClass:[SendMessageToWXResp class]]){
        if(((SendMessageToWXResp *)resp).errCode == 0){
            [UIView dd_showMessage:@"微信分享成功"];
            if([self.delegate respondsToSelector:@selector(callBack:)]){
                [self.delegate callBack:[self.shareContent callbackParams]];
            }
        }else if(((SendMessageToWXResp *)resp).errCode == -2){
            [UIView dd_showMessage:@"微信分享已取消"];
        }else{
            [UIView dd_showMessage:@"微信分享未知错误"];
        }
    }
}

- (void)onReq:(QQBaseReq *)req{
    
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
}

#pragma mark - TencentLoginDelegate Methods

- (void)tencentDidLogin{
    [self shareToQQPlatform:oauthBeforeType];
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    [UIView dd_showMessage:@"授权取消"];
}

- (void)tencentDidNotNetWork{
    [UIView dd_showMessage:@"暂无网络连接"];
}

#pragma mark - WeiboSDK Delegate Methods

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        WBSendMessageToWeiboResponse *wbResp = (WBSendMessageToWeiboResponse *)response;
        NSString *msg = @"";
        switch (wbResp.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:{
                msg = @"新浪微博分享成功";
                if([self.delegate respondsToSelector:@selector(callBack:)]){
                    [self.delegate callBack:[self.shareContent callbackParams]];
                }
            }
                break;
            case WeiboSDKResponseStatusCodeSentFail:
                msg = @"新浪微博分享失败";
                break;
            case WeiboSDKResponseStatusCodeUserCancel:
                msg = @"新浪微博分享取消";
                break;
            default:
                break;
        }
        [UIView dd_showMessage:msg];
    }
}

#pragma mark - Public Methods

+ (instancetype)manager{
    static DDShareKit *shareKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareKit = [[DDShareKit alloc] init];
    });
    return shareKit;
}

- (void)startWithTencentId:(NSString *)tencentId{
    if(!tcOauth)
        tcOauth = [[TencentOAuth alloc] initWithAppId:tencentId?:@""
                                          andDelegate:self];
}

+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id<DDShareKitDelegate>)delegate{
    [DDShareKit manager].delegate = delegate;
    if([url.scheme hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url] && [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)[DDShareKit manager]];
    }else if([url.scheme hasPrefix:@"wx"] && [url.host isEqualToString:@"platformId=wechat"]){
        return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)[DDShareKit manager]];
    }else if([url.scheme isEqualToString:@"wb"]){
        return [WeiboSDK handleOpenURL:url delegate:(id<WeiboSDKDelegate>)[DDShareKit manager]];
    }
    return NO;
}

- (void)show{
    if(!maskLayer)
        maskLayer = [CALayer layer];
    maskLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    maskLayer.opacity = 0.0f;
    maskLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:maskLayer atIndex:0];
    
    if(self.shareKitTitle){
        if ([self.lblTitle respondsToSelector:@selector(setAttributedText:)]) {
            self.lblTitle.attributedText = nil;
            NSString *shareTitle = [NSString stringWithFormat:@"分享的商品被购买,您可获得%@的收益",self.shareKitTitle];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:shareTitle];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:226.0f/255 green:25.0f/255 blue:83.0f/255 alpha:1.0f] range:NSMakeRange(13,self.shareKitTitle.length)];
            self.lblTitle.attributedText = str;
        }
    }
    UIWindow *topWindows = [[[UIApplication sharedApplication] windows] lastObject];
    [topWindows addSubview:self.view];
    [topWindows.rootViewController addChildViewController:self];
    CGRect frame = self.carryView.frame;
    frame.origin.y = self.view.frame.size.height - self.carryView.frame.size.height;
    [UIView animateWithDuration:0.2f animations:^{
        maskLayer.opacity = 1.0f;
        self.carryView.frame = frame;
    }];
    
    imageReady = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        if(!self.shareContent.image){
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.shareContent.imageURL]];
            self.shareContent.image = [UIImage imageWithData:imageData];
            imageReady = YES;
        }
    });
}

- (void)shareImmediately:(DDShareType)type{
    imageReady = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        if(!self.shareContent.image){
            [self.view dd_showMessageHUD:@"正在分享中..."];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.shareContent.imageURL]];
            self.shareContent.image = [UIImage imageWithData:imageData];
            imageReady = YES;
            [self.view dd_removeHUD];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shareToPlatfroms:type];
        });
    });
}

- (void)hide{
    self.shareKitTitle = nil;
    self.lblTitle.text = @"分享到";
    CGRect frame = self.carryView.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.carryView.frame = frame;
                         maskLayer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
    
}

- (void)getSharePlatforms{
    if(!shareItems)
        shareItems = [[NSMutableArray alloc] initWithCapacity:0];
    [shareItems removeAllObjects];
    
    [shareItems addObject:@{@"icon":@"share_weixin",@"title":@"微信",@"type":@(DDShareTypeWX)}];
    [shareItems addObject:@{@"icon":@"share_timeline",@"title":@"朋友圈",@"type":@(DDShareTypeWX_TIMELINE)}];
    [shareItems addObject:@{@"icon":@"share_sinaweibo",@"title":@"新浪微博",@"type":@(DDShareTypeWeibo)}];
    [shareItems addObject:@{@"icon":@"share_tcweibo",@"title":@"腾讯微博",@"type":@(DDShareTypeTCWB)}];
    [shareItems addObject:@{@"icon":@"share_qq",@"title":@"QQ",@"type":@(DDShareTypeQQ)}];
    [shareItems addObject:@{@"icon":@"share_qzone",@"title":@"QQ空间",@"type":@(DDShareTypeQZone)}];
    [shareItems addObject:@{@"icon":@"share_sms",@"title":@"短信",@"type":@(DDShareTypeSMS)}];
    [shareItems addObject:@{@"icon":@"share_copy",@"title":@"复制链接",@"type":@(DDShareTypeCopy)}];
}

- (void)buttonClicked:(id)sender{
    if(!imageReady){
        [UIView dd_showMessage:@"图片未处理完毕,请稍候..."];
    }
    [self shareToPlatfroms:[sender view].tag];
}

- (void)shareToPlatfroms:(DDShareType)type{
    switch (type) {
        case DDShareTypeCopy:{
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            pboard.string = self.shareContent.link?:@"";
            [UIView dd_showMessage:@"链接复制成功"];
        }
            break;
        case DDShareTypeSMS:{
            [self shareToSMS];
        }
            break;
        case DDShareTypeQQ:
        case DDShareTypeQZone:
        case DDShareTypeTCWB:{
            if([tcOauth isSessionValid]){
                [self shareToQQPlatform:type];
            }else{
                NSArray *permissions = @[kOPEN_PERMISSION_ADD_PIC_T,
                                         kOPEN_PERMISSION_ADD_SHARE];
                [tcOauth authorize:permissions inSafari:NO];
                oauthBeforeType = type;
            }
        }
            break;
        case DDShareTypeWX:
        case DDShareTypeWX_TIMELINE:{
            [self shareToWeixinPlatform:type];
        }
            break;
        default:{
            [self shareToSinaWeibo];
        }
            break;
    }
    [self hide];
}

- (void)shareToSinaWeibo{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        WBMessageObject *message = [WBMessageObject message];
        message.text = [self convertString:self.shareContent];
        if(self.shareContent.image){
            WBImageObject *image = [WBImageObject object];
            image.imageData = UIImageJPEGRepresentation(self.shareContent.image, 1.0f);
            message.imageObject = image;
        }
        
        WBSendMessageToWeiboRequest *weiboReq = [WBSendMessageToWeiboRequest requestWithMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [WeiboSDK sendRequest:weiboReq];
        });
    });
}


- (void)shareToQQPlatform:(DDShareType)type{
    [self.view dd_showMessageHUD:@"正在分享，请稍候..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        if(type == DDShareTypeTCWB){
            WeiBo_add_pic_t_POST *tcwbRequest = [[WeiBo_add_pic_t_POST alloc] init];
            tcwbRequest.param_pic = self.shareContent.image;
            tcwbRequest.param_content = [self convertString:self.shareContent];
            tcwbRequest.param_compatibleflag = @"0x2|0x4|0x8|0x20";
            dispatch_async(dispatch_get_main_queue(), ^{
                [tcOauth sendAPIRequest:tcwbRequest callback:self];
                [self.view dd_removeHUD];
            });
        }else{
            QQApiNewsObject *obj = [[QQApiNewsObject alloc] initWithURL:[NSURL URLWithString:self.shareContent.link] title:self.shareContent.title description:self.shareContent.content previewImageData:UIImageJPEGRepresentation(self.shareContent.image, 0.5) targetContentType:QQApiURLTargetTypeNews];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
            dispatch_async(dispatch_get_main_queue(), ^{
                __unused QQApiSendResultCode resultCode;
                if(type == DDShareTypeQQ){
                    resultCode = [QQApiInterface sendReq:req];
                }else{
                    resultCode = [QQApiInterface SendReqToQZone:req];
                }
                if(resultCode == EQQAPISENDSUCESS){
                    
                }
                [self.view dd_removeHUD];
            });
        }
    });
}

- (void)shareToWeixinPlatform:(DDShareType)type{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = self.shareContent.title;
    message.description = self.shareContent.content;
    [message setThumbImage:[self scaleFromImage:self.shareContent.image toSize:CGSizeMake(100.0, 100.0)]];
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.shareContent.link;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    if(type == DDShareTypeWX_TIMELINE){
        req.scene = WXSceneTimeline;
    }
    [WXApi sendReq:req];
}


// 计算分享的内容长度
- (int)convertToInt:(NSString *)strtemp {
    int strlength = 0;
    char *p = (char *)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i < [strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if( *p ){
            p++;
            strlength++;
        }else {
            p++;
        }
    }
    return (strlength + 1)/2;
}

// 处理微博分享的文案
- (NSString *)convertString:(DDShareItem *)item{
    NSString *shareContent = [NSString stringWithFormat:@"%@%@",item.content,item.link];
    NSUInteger contentLength = [self convertToInt:shareContent];
    return  contentLength > 139.0 ? [NSString stringWithFormat:@"%@%@",@"想“出柜”，就来[麦包包]。", item.link] : shareContent;
}

// 缩小图片 微信的图片不超过32k（用于微信分享）
- (UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)shareToSMS {
    BOOL canSendSMS = [MFMessageComposeViewController canSendText];
    if (canSendSMS) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.navigationBar.tintColor = [UIColor blackColor];
        
        picker.body = [NSString stringWithFormat:@"%@来自%@",self.shareContent.link,DDKitAppDisplayName];

        UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
        [topWindow.rootViewController presentViewController:picker animated:YES completion:NULL];
    }
}


@end
