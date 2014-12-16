//
//  ViewController.m
//  DDKit
//
//  Created by Diaoshu on 14-12-15.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "ViewController.h"
#import "Post.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()<UINavigationControllerDelegate>{
    NSMutableArray *dataList;
}

@end

@implementation ViewController

- (void)dealloc
{
    [Post cancelRequest:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(!dataList)
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    [dataList removeAllObjects];
    
    [Post getPostList:nil
             parentVC:self
              showHUD:YES
              success:^(id data) {
                  [dataList addObjectsFromArray:data];
                  [self.tableView reloadData];
              }
              failure:^(NSError *error, NSDictionary *info) {
              }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"PostIdentifier";
    //注意在heightForRowAtIndexPath:indexPath无法使用dequeueReusableCellWithIdentifier:forIndexPath:
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //用dequeueReusableCellWithIdentifier:就得判断Cell为nil的情况
    //如果在Storyboard中Prototype Cells中设置了具体Table View Cell的Identifier也是"MyCell"（也就是重用ID），那这里不会有返回nil的情况
    UIImageView *header = (UIImageView *)[cell.contentView viewWithTag:1];
    Post *p = dataList[indexPath.row];
    [header sd_setImageWithURL:[NSURL URLWithString:p.user.avatarImageURLString]];
    UILabel *lblUserName = (UILabel *)[cell.contentView viewWithTag:2];
    lblUserName.text = p.user.username;
    UILabel *lblText = (UILabel *)[cell.contentView viewWithTag:3];
    lblText.text = p.text;
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    Post *p = dataList[indexPath.row];
    CGSize sizeText = CGSizeZero;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000)
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f], NSParagraphStyleAttributeName:paragraphStyle.copy};
    sizeText = [p.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
#else
    sizeText = [p.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    
    height  = fmaxf(80.0f, ceilf(sizeText.height) + 50.0f);
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.navigationController.viewControllers.count > 1){
        return;
    }
    [self performSegueWithIdentifier:@"nextSegue" sender:self];
}

@end
