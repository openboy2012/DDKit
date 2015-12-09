//
//  DDShareKit.h
//  DDShareKit
//
//  Created by DeJohn Dong on 15/12/8.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDShareItem.h"

typedef NS_OPTIONS(NSUInteger, DDShareType) {
    DDShareTypeWX          = 1 << 0,         // shareType Wechat
    DDShareTypeWX_TIMELINE = 1 << 1,         // shareType Wechat-Timeline
    DDShareTypeWeibo       = 1 << 2,         // shareType Sina Weibo
    DDShareTypeTCWB        = 1 << 3,         // shareType Tencent Weibo
    DDShareTypeQZone       = 1 << 4,         // shareType QZone
    DDShareTypeSMS         = 1 << 5,         // shareType SMS
    DDShareTypeCopy        = 1 << 6,         // shareType Copy
    DDShareTypeQQ          = 1 << 7          // shareType QQ
};

@protocol DDShareKitDelegate;

@interface DDShareKit : UIViewController

@property (nonatomic, strong) DDShareItem *shareContent;
@property (nonatomic, copy) NSString *shareKitTitle;

/**
 *  simple initalize methods
 *
 *  @return DDShareKit initalize object
 */
+ (instancetype)sharedKit;

/**
 *  show the shareKit actionSheet
 */
- (void)show;

/**
 *  Do a share action without show the UI
 *
 *  @param type ShareType
 */
- (void)shareImmediately:(DDShareType)type;

/**
 *  handle the open url
 *
 *  @param url      url
 *  @param delegate DDShareKitDelegate 
 */
+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id<DDShareKitDelegate>)delegate;

@end

@protocol DDShareKitDelegate <NSObject>

@optional
- (void)shareKitFinished:(id)callbackInfo;

@end