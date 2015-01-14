//
//  DDKitTests.m
//  DDKitTests
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Post.h"

@interface DDKitTests : XCTestCase

@end

@implementation DDKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Post getPostList:nil
             parentVC:nil
              showHUD:NO
              success:^(id data) {
                  
              }
              failure:^(NSError *error, NSDictionary *info) {
              }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    [Post getPostList:nil
             parentVC:nil
              showHUD:NO
              success:^(id data) {
                  XCTAssert(YES, @"Pass");
              }
              failure:^(NSError *error, NSDictionary *info) {
              }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
