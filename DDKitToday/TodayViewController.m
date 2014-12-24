//
//  TodayViewController.m
//  DDKitToday
//
//  Created by Diaoshu on 14-12-23.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
//#import <UIImageView+WebCache.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) IBOutlet UIImageView *todayImageView;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img3.imgtn.bdimg.com/it/u=2190204034,63084497&fm=23&gp=0.jpg"]];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
//            dispatch_async(dispatch_get_main_queue(), ^{
                self.todayImageView.image = image;
//            });
//    self.todayImageView.image = [UIImage imageNamed:@"Icon"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
