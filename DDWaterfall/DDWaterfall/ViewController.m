//
//  ViewController.m
//  DDWaterfall
//
//  Created by Diaoshu on 15-1-18.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import "ViewController.h"
#import "DDWaterfallView.h"

@interface ViewController ()<DDWaterfallViewDataSource,DDWaterfallViewDelegate>{
    NSMutableArray *dataList;
}

@property (nonatomic, strong) DDWaterfallView *waterfallView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(!dataList){
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    for (int i = 0; i < 20; ++i) {
        [dataList addObject:@(i)];
    }
    
    self.waterfallView = [[DDWaterfallView alloc] initWithFrame:self.view.bounds];
    self.waterfallView.waterfallDelegate = self;
    self.waterfallView.waterfallDataSource = self;
    self.waterfallView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0f);
    
    [self.view addSubview:self.waterfallView];
    [self.waterfallView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    DDWaterfallCell *cell = [waterfallView dequeueReusableCellWithIdentifier:@"DemoCell"];
    if(!cell){
        cell = [[DDWaterfallCell alloc] initWithIdentifier:@"DemoCell"];
    }
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0f green:arc4random()%255/255.0f blue:arc4random()%255/255.0f alpha:1.0f];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@",dataList[indexPath.row * [waterfallView numberOfColumns] + indexPath.section]];
    if(indexPath.row * [waterfallView numberOfColumns] + indexPath.section == 18){
        cell.textLabel.text = nil;
    }
    return cell;
}

#pragma mark - DDWaterfallDelegate Methods

- (void)waterfallView:(DDWaterfallView *)waterfallView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath = %@",indexPath);
}

- (CGFloat)waterfallView:(DDWaterfallView *)waterfallView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return arc4random() % 120 + 100.0f;
}

@end
