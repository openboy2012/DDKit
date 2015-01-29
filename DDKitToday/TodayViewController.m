//
//  TodayViewController.m
//  DDKitToday
//
//  Created by Diaoshu on 15-1-8.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <UIImageView+WebCache.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, weak) IBOutlet UIImageView *todayImageView;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NCWidgetProviding Methods

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsZero;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    [self.todayImageView sd_setImageWithURL:[NSURL URLWithString:@"http://mobimage.mbbimg.cn/sku/1503023501-1-320-320-90.jpg"]];
    completionHandler(NCUpdateResultNewData);
}

@end
