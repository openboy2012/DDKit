//
//  DDBasicModel.m
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "DDBasicModel.h"
#import "MBProgressHUD.h"

@interface DDAFNetworkClient()

//根据Key值加入Opeartion
- (void)addOperation:(AFURLConnectionOperation *)operation withKey:(NSString *)key;

//根据Key值取消某个Opeartion
- (void)removeOperation:(AFURLConnectionOperation *)operation withKey:(NSString *)key;

//根据Key取消所有的Operation
- (void)cancelOperationWithKey:(NSString *)key;

@end

@implementation DDAFNetworkClient

+ (instancetype)sharedClient{
    static DDAFNetworkClient *afSharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afSharedClient = [[DDAFNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:kAppURL]];
        afSharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        //实例队列字典
        afSharedClient.ddHttpQueueDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    });
    return afSharedClient;
}

- (void)addOperation:(AFURLConnectionOperation *)operation withKey:(NSString *)key{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *operations = self.ddHttpQueueDict[key];
        if(!operations)
            operations = [[NSMutableArray alloc] initWithObjects:operation, nil];
        else
            [operations addObject:operation];
        [self.ddHttpQueueDict setObject:operations forKey:key];
    });
}

- (void)removeOperation:(AFURLConnectionOperation *)operation withKey:(NSString *)key{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *operations = self.ddHttpQueueDict[key];
        [operations removeObject:operation];
    });
}

- (void)cancelOperationWithKey:(NSString *)key{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *operations = self.ddHttpQueueDict[key];
        if(operations.count > 0)
            [operations makeObjectsPerformSelector:@selector(cancel)];
        [self.ddHttpQueueDict removeObjectForKey:key];
    });
}

@end


@interface DDBasicModel()

//处理responseString
+ (id)getJSONObjectFromString:(NSString *)responseString;

//处理参数
+ (NSDictionary *)handleParameters:(NSDictionary *)params;

@end


@implementation DDBasicModel

#pragma mark - HUD Methods

static MBProgressHUD *hud = nil;
static int hudCount = 0;

//增加请求HUD
+ (void)addHud{
    UIWindow *topWindow = [[[UIApplication sharedApplication] windows] lastObject];
    if(!hud)
        hud = [[MBProgressHUD alloc] initWithView:topWindow];
    if(hudCount > 0){
        hudCount ++;
        return;
    }
    hud.labelText = @"请稍候...";
    hud.yOffset = -20.0f;
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeIndeterminate;
    [topWindow addSubview:hud];
#warning 处理HUD背景颜色 按需更换
    //处理背景颜色 按需更换
    hud.color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3f];
    hudCount++;
    [hud show:NO];
}

//取消HUD
+ (void)hideHud{
    if(hudCount == 1 && hud){
        [hud hide:NO];
    }
    hudCount --;
}

#pragma mark - Cancel HTTP Request Methods
//取消这个viewController下的所有请求
+ (void)cancelRequest:(id)viewController{
    if(hud){
        [hud hide:NO];
    }
    if(viewController){
        NSString *key = NSStringFromClass([viewController class]);
        [[DDAFNetworkClient sharedClient] cancelOperationWithKey:key];
    }
}

#pragma mark - HTTP Request Handler Methods

+ (AFHTTPRequestOperation *)get:(NSString *)path
                         params:(id)params
                        showHUD:(BOOL)show
           parentViewController:(id)viewController
                        success:(DDBasicSuccessBlock)success
                        failure:(DDBasicFailureBlock)failure{
    if(show){
        [self addHud];
    }
    NSString *key = @"mainKey";
    if(viewController)
        key = NSStringFromClass([viewController class]);
    params = [self handleParameters:params];
    AFHTTPRequestOperation *getOperation =
    [[DDAFNetworkClient sharedClient] GET:path
                               parameters:params
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      if(show){
                                          [self hideHud];
                                      }
                                      [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                      id JSON = [self getJSONObjectFromString:operation.responseString];
                                      if (success)
                                          success([[self class] convertJsonToObject:JSON]);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if(show){
                                          [self hideHud];
                                      }
                                      [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                      NSLog(@"error = %@",error);
                                      if([error code] != kCFURLErrorCancelled){
                                          NSLog(@"error = %@",error);
                                      }
                                  }];
    [[DDAFNetworkClient sharedClient] addOperation:getOperation withKey:key];
    return getOperation;
}

+ (AFHTTPRequestOperation *)post:(NSString *)path
                          params:(id)params
                         showHUD:(BOOL)show
            parentViewController:(id)viewController
                         success:(DDBasicSuccessBlock)success
                         failure:(DDBasicFailureBlock)failure{
    if(show){
        [self addHud];
    }
    NSString *key = @"mainKey";
    if(viewController)
        key = NSStringFromClass([viewController class]);
    params = [self handleParameters:params];
    AFHTTPRequestOperation *postOperation =
    [[DDAFNetworkClient sharedClient] POST:path
                                parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if(show){
                                           [self hideHud];
                                       }
                                       [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                       id JSON = [self getJSONObjectFromString:operation.responseString];
                                       if (success)
                                           success([[self class] convertJsonToObject:JSON]);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if(show){
                                           [self hideHud];
                                       }
                                       [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                       NSLog(@"error = %@",error);
                                       if([error code] != kCFURLErrorCancelled){
                                           NSLog(@"error = %@",error);
                                       }
                                   }];
    [[DDAFNetworkClient sharedClient] addOperation:postOperation withKey:key];
    return postOperation;
}

+ (AFHTTPRequestOperation *)post:(NSString *)path
                      fileStream:(NSData *)stream
                          params:(id)params
                        userInfo:(id)userInfo
                         showHUD:(BOOL)show
            parentViewController:(id)viewController
                         success:(DDBasicSuccessBlock)success
                         failure:(DDBasicFailureBlock)failure{
    if(show){
        [self addHud];
    }
    NSString *key = @"mainKey";
    if(viewController)
        key = NSStringFromClass([viewController class]);
    params = [self handleParameters:params];
    AFHTTPRequestOperation *uploadOperation =
    [[DDAFNetworkClient sharedClient] POST:path
                                parameters:params
                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                     [formData appendPartWithFileData:stream name:@"uploadFile" fileName:@"file" mimeType:@"image/jpg"];
                 }
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if(show){
                                           [self hideHud];
                                       }
                                       [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                       id JSON = [self getJSONObjectFromString:operation.responseString];
                                       if (success)
                                           success([[self class] convertJsonToObject:JSON]);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if(show){
                                           [self hideHud];
                                       }
                                       [[DDAFNetworkClient sharedClient] removeOperation:operation withKey:key];
                                       if([error code] != kCFURLErrorCancelled){
                                           NSLog(@"error = %@",error);
                                       }
                                   }];
    uploadOperation.userInfo = userInfo;
    [[DDAFNetworkClient sharedClient] addOperation:uploadOperation withKey:key];
    return uploadOperation;
}

#pragma mark - Parameter & Response String Handler Methods

+ (NSDictionary *)handleParameters:(NSDictionary *)params{
    /* TO-DO
     * 处理参数(该加密的加密，添加公共参数等等)
     */
    return params;
}

+ (id)getJSONObjectFromString:(NSString *)responseString{
    
    /* TO-DO
     * 处理返回的字符串(该解密的解密等等)
     */
    
    NSError *decodeError = nil;
    NSData *decodeData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    if(decodeData == nil){
        return @{};
    }
    NSDictionary *jsonValue = [NSJSONSerialization JSONObjectWithData:decodeData
                                                              options:NSJSONReadingAllowFragments
                                                                error:&decodeError];
    return jsonValue;
}

#pragma mark - JSON Mapping Handle Methods

// 处理解析字符串的的节点
+ (NSString *)jsonNode{
    return @"NULL";
}

// NSDictionary 对象到Mode属性的映射方法，具体实现在各子类的实现方法内。
+ (NSDictionary *)jsonMappings{
    return nil;
}

// 处理Json对象到Model对象
+ (id)convertJsonToObject:(id)jsonObject{
    if(jsonObject == nil){
        return nil;
    }
    id data = nil;
    if([jsonObject isKindOfClass:[NSArray class]]){
        data = jsonObject;
    }else{
        if ([[[self class] jsonNode] isEqualToString:@"NULL"]) {
            data = jsonObject;
        }else{
            data = [jsonObject objectForKey:[[self class] jsonNode]];
        }
    }
    if(data == nil){
        return nil;
    }
    return [[self class] objectFromJSONObject:data mapping:[[self class] jsonMappings]];
}

#pragma mark - Other Methods

- (NSDictionary *)propertiesOfSelf {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = DD_AUTORELEASE([[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding]);
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if ([propertyValue isKindOfClass:[NSArray class]]){
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
            for (id propetyItem in propertyValue) {
                if([propetyItem isKindOfClass:[DDBasicModel class]]){
                    [list addObject:[propetyItem propertiesOfSelf]];
                }else{
                    if(propetyItem)
                        [list addObject:propetyItem];
                }
            }
            [props setObject:list forKey:propertyName];
        }
        else if ([propertyValue isKindOfClass:[DDBasicModel class]]){
            [props setObject:[propertyValue propertiesOfSelf] forKey:propertyName];
        }
        else{
            if(propertyValue)
                [props setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return props;
}

#pragma mark - DB Methods Overloaded

//重载DB存储方法
- (void)save{
    dispatch_async(ddkit_db_queue(), ^{
        [super save];
    });
}

//重载DB删除方法
- (void)deleteObjectCascade:(BOOL)cascade{
    dispatch_async(ddkit_db_queue(), ^{
        [super deleteObjectCascade:cascade];
    });
}

@end

