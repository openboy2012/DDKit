//
//  ViewController.m
//  DDKit
//
//  Created by DeJohn Dong on 15/12/7.
//  Copyright © 2015年 ddkit. All rights reserved.
//

#import "ViewController.h"
#import "DDShareKit.h"
#import "DDOAuthKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender{
    DDShareItem *shareContent = [[DDShareItem alloc] init];
    shareContent.title = @"万万没想到，这个包这么好！";
    shareContent.content = shareContent.title;
    shareContent.link = @"http://m.baidu.com";
    shareContent.imageURL = @"http://d.hiphotos.baidu.com/zhidao/pic/item/562c11dfa9ec8a13e028c4c0f603918fa0ecc0e4.jpg";
    shareContent.type = @"detail";
    [DDShareKit sharedKit].shareContent = shareContent;
    [DDShareKit sharedKit].shareTypes = @[@(DDShareTypeWX),@(DDShareTypeTCWB),@(DDShareTypeQQ),@(DDShareTypeSMS),@(DDShareTypeWX_TIMELINE),@(DDShareTypeWeibo)];
    [[DDShareKit sharedKit] show];
}

- (IBAction)wxOAuth:(id)sender{
    [[DDOAuthKit sharedOAuthKit] dd_doOAuthByWeixin:nil completion:^(id result) {
        NSLog(@"result = %@",result);
    }];
}

- (IBAction)alipayOAuth:(id)sender{
    [[DDOAuthKit sharedOAuthKit] dd_doOAuthByAlipay:^(id result) {
        NSLog(@"result = %@",result);
    }];
}

- (IBAction)wbOAuth:(id)sender{
    [[DDOAuthKit sharedOAuthKit] dd_doOAuthByWeibo:@"http://www.sina.com" completion:^(id result) {
        NSLog(@"result = %@",result);
    }];
}

- (IBAction)qqOAuth:(id)sender{
    [[DDOAuthKit sharedOAuthKit] dd_doOAuthByQQ:^(id result) {
        NSLog(@"result = %@",result);
    }];
}


@end
