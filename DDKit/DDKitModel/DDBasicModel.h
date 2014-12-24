//
//  DDBasicModel.h
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//


#import "SQLitePersistentObject.h"
#import "NSObject+JTObjectMapping.h"
#import "NSString+DES3.h"
#import "NSString+MD5.h"

#import "AFNetworking.h"

#define kAppURL @"https://api.app.net/"

#ifndef DD_STRONG
#if __has_feature(objc_arc)
#define DD_STRONG strong
#else
#define DD_STRONG retain
#endif
#endif

#ifndef DD_WEAK
#if __has_feature(objc_arc_weak)
#define DD_WEAK weak
#elif __has_feature(objc_arc)
#define DD_WEAK unsafe_unretained
#else
#define DD_WEAK assign
#endif
#endif

#if __has_feature(objc_arc)
#define DD_AUTORELEASE(exp) exp
#define DD_RELEASE(exp) exp
#define DD_RETAIN(exp) exp
#else
#define DD_AUTORELEASE(exp) [exp autorelease]
#define DD_RELEASE(exp) [exp release]
#define DD_RETAIN(exp) [exp retain]
#endif

#ifndef __USE_ENCRYPT_REQUEST
#define __USE_ENCRYPT_REQUEST 0
#endif

#define ddkit_db_write_queue_name "com.ddkit.iphone.dbqueue.write"
#define ddkit_db_read_queue_name "com.ddkit.iphone.dbqueue.read"

UIKIT_EXTERN NSString *const DDKitHeadFieldUpdateNotification;

//全局DB写队列，防止并发存储产生的问题
static __unused dispatch_queue_t ddkit_db_write_queue() {
    static dispatch_queue_t ddkit_db_write_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ddkit_db_write_queue = dispatch_queue_create(ddkit_db_write_queue_name, DISPATCH_QUEUE_SERIAL);
    });
    return ddkit_db_write_queue;
}

//全局DB读队列，防止并发存储产生的问题
static __unused dispatch_queue_t ddkit_db_read_queue() {
    static dispatch_queue_t ddkit_db_read_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ddkit_db_read_queue = dispatch_queue_create(ddkit_db_read_queue_name, DISPATCH_QUEUE_SERIAL);
    });
    return ddkit_db_read_queue;
}

//Basic Success Block callback a id object;
typedef void(^DDBasicSuccessBlock)(id data);
//Basic Failure Block callback an error object & a message object
typedef void(^DDBasicFailureBlock)(NSError *error, NSDictionary *info);

//Block callback of get data from DB
typedef void(^DBGetBlock)(id data);

typedef NS_OPTIONS(NSUInteger, DDDataCacheType){
    DDDataCacheTypeMemory          = 1 << 0,
    DDDataCacheTypeDB              = 1 << 1,
    DDDataCacheTypeNone            = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, DBDataType) {
    DBDataTypeFirstItem            = 1 << 0,
    DBDataTypeItemList             = 1 << 1
};

@interface DDBasicModel : SQLitePersistentObject{
    
}

//parse self object as NSDictionary object.
- (NSDictionary *)propertiesOfSelf;

//return the parse json node.
+ (NSString *)jsonNode;

//handle the mappings about the json key-value transform to a model object.
+ (NSDictionary *)jsonMappings;

//get json data from http server by HTTP GET Mehod.
+ (AFHTTPRequestOperation *)get:(NSString *)path
                         params:(id)params
                        showHUD:(BOOL)show
           parentViewController:(id)viewController
                        success:(DDBasicSuccessBlock)success
                        failure:(DDBasicFailureBlock)failure;

//get json data from http server by HTTP POST Mehod.
+ (AFHTTPRequestOperation *)post:(NSString *)path
                          params:(id)params
                         showHUD:(BOOL)show
            parentViewController:(id)viewController
                         success:(DDBasicSuccessBlock)success
                         failure:(DDBasicFailureBlock)failure;

//upload fileStream to http server by HTTP POST Mehod.
+ (AFHTTPRequestOperation *)post:(NSString *)path
                      fileStream:(NSData *)stream
                          params:(id)params
                        userInfo:(id)userInfo
                         showHUD:(BOOL)show
            parentViewController:(id)viewController
                         success:(DDBasicSuccessBlock)success
                         failure:(DDBasicFailureBlock)failure;

//cancel all the request of the key viewController.
+ (void)cancelRequest:(id)viewController;

//get data from db use a block
+ (void)getDataFromDBWithParameters:(id)params success:(DBGetBlock)block;

@end

@interface DDAFNetworkClient : AFHTTPRequestOperationManager{
    
}

@property (nonatomic, strong) NSMutableDictionary *ddHttpQueueDict;

@end
