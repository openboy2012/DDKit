///
//  DDWaterfallViewController.m
//  DDKit
//
//  Created by Diaoshu on 15-1-19.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import "DDWaterfallViewController.h"
#import "DDWaterfallView.h"
#import "PostCell.h"
#import "Post.h"

@interface DDWaterfallViewController ()<DDWaterfallViewDataSource,DDWaterfallViewDelegate>{
    NSMutableArray *dataList;
}

@property (nonatomic, weak) IBOutlet DDWaterfallView *waterfallView;

@end

@implementation DDWaterfallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!dataList){
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    self.title = @"DDWaterfall";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"◁返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    
    self.waterfallView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    [self refreshData];
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

#pragma mark - DDWaterfallDataSource Methods

- (NSInteger)numberOfColumnsInWaterfallView:(DDWaterfallView *)waterfallView{
    return 2;
}

- (NSInteger)waterfallView:(DDWaterfallView *)waterfallView numberOfRowsInColumn:(NSInteger)column{
    if(column == 0){
        return ceilf(dataList.count/[waterfallView numberOfColumns]);
    }else
        return floorf(dataList.count/[waterfallView numberOfColumns]);
}

- (DDWaterfallCell *)waterfallView:(DDWaterfallView *)waterfallView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostCell *cell = (PostCell *)[waterfallView dequeueReusableCellWithIdentifier:@"DemoCell"];
    if(!cell){
        cell = [[PostCell alloc] initWithIdentifier:@"DemoCell"];
    }
//    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0f green:arc4random()%255/255.0f blue:arc4random()%255/255.0f alpha:1.0f];
//    cell.textLabel.text = [NSString stringWithFormat:@"#%@",dataList[indexPath.row * [waterfallView numberOfColumns] + indexPath.section]];
//    if(indexPath.row * [waterfallView numberOfColumns] + indexPath.section == 18){
//        cell.textLabel.text = nil;
//    }
    [cell setPostItem:dataList[indexPath.row * [waterfallView numberOfColumns] + indexPath.section] itemWidth:[waterfallView itemWidth]];
    return cell;
}

#pragma mark - DDWaterfallDelegate Methods

- (void)waterfallView:(DDWaterfallView *)waterfallView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath = %@",indexPath);
}

- (CGFloat)waterfallView:(DDWaterfallView *)waterfallView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [PostCell heightOfCell:dataList[indexPath.row * [waterfallView numberOfColumns] + indexPath.section] itemWidth:[waterfallView itemWidth]];
}

#pragma mark - Custom Methods

- (void)refreshData{
    [Post getPostList:nil
             parentVC:self
              showHUD:YES
              success:^(id data) {
                  [dataList removeAllObjects];
                  [dataList addObjectsFromArray:data];
                  [self.waterfallView reloadData];
              }
              failure:^(NSError *error, NSString *message) {
              }];
}

- (void)goBack{
    [Post cancelRequest:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
