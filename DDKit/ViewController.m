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
#import <GameKit/GameKit.h>

@interface DDTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *header;
@property (nonatomic, weak) IBOutlet UILabel *lblNickname;
@property (nonatomic, weak) IBOutlet UILabel *lblContent;

- (void)setPostItem:(Post *)p;

+ (CGFloat)heightOfCell:(Post *)p;

@end

@implementation DDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
}

- (void)setPostItem:(Post *)p{
    [self.header sd_setImageWithURL:[NSURL URLWithString:p.user.avatarImageURLString]];
    self.lblNickname.text = p.user.username;
    self.lblContent.text = p.text;
    self.lblContent.frame = CGRectMake(self.lblContent.frame.origin.x, self.lblContent.frame.origin.y, [NSNumber propertyWidth:90.0f], self.lblContent.frame.size.height);
    [self.lblContent resizeLabelVertical];
    
}

+ (CGFloat)heightOfCell:(Post *)p{
    CGFloat height = 50.0f;
    CGSize sizeText = CGSizeZero;
    CGSize constrainSize = CGSizeMake([NSNumber propertyWidth:90.0f], CGFLOAT_MAX);
    if ([p.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        sizeText = [p.text boundingRectWithSize:constrainSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
        sizeText = [p.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    height += ceilf(sizeText.height);
    if(height <= 95.0)
        height = 95.0;
    return height;
}

@end

@interface ViewController ()<UINavigationControllerDelegate,GKSessionDelegate>{
    NSMutableArray *dataList;
    BOOL isLoadedFirst;
}

@property (nonatomic, strong) GKSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    if(!dataList)
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    [dataList removeAllObjects];
    
    self.title = @"DDKit";
        
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self refreshData];
    [self.refreshControl beginRefreshing];
    
    self.session = [[GKSession alloc] initWithSessionID:@"ddkitServer" displayName:@"Server" sessionMode:GKSessionModeServer];
    self.session.delegate = self;
    [self.session connectToPeer:@"ddkitClient" withTimeout:10.0f];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"GameKit" style:UIBarButtonItemStyleBordered target:self action:@selector(go2GameKit)];
    
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
    DDTableViewCell *cell = (DDTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //用dequeueReusableCellWithIdentifier:就得判断Cell为nil的情况
    //如果在Storyboard中Prototype Cells中设置了具体Table View Cell的Identifier也是"MyCell"（也就是重用ID），那这里不会有返回nil的情况
//    UIImageView *header = (UIImageView *)[cell.contentView viewWithTag:1];
//    Post *p = dataList[indexPath.row];
//    [header sd_setImageWithURL:[NSURL URLWithString:p.user.avatarImageURLString]];
//    UILabel *lblUserName = (UILabel *)[cell.contentView viewWithTag:2];
//    lblUserName.text = p.user.username;
//    UILabel *lblText = (UILabel *)[cell.contentView viewWithTag:3];
//    lblText.text = p.text;
//    lblText.numberOfLines = 0;
//    [lblText resizeLabelVertical];
    [cell setPostItem:dataList[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *p = dataList[indexPath.row];
    return [DDTableViewCell heightOfCell:p];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath = %@",indexPath);
    [self performSegueWithIdentifier:@"nextSegue" sender:self];
}

#pragma mark - KVO 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"changed");
}

- (void)go2GameKit{
    [self performSegueWithIdentifier:@"DDWaterfallSegue" sender:self];
}

#pragma mark - Custome Methods

- (void)refreshData{
    [Post getPostList:nil
             parentVC:self
              showHUD:NO
              success:^(id data) {
                  if(self.refreshControl)
                      [self.refreshControl endRefreshing];
                  if(!isLoadedFirst){
                      [dataList removeAllObjects];
                      [dataList addObjectsFromArray:data];
                      [self.tableView reloadData];
                      isLoadedFirst = YES;
                  }else{
                      [dataList addObjectsFromArray:data];
                      [self.tableView reloadData];
                  }
              }
              failure:^(NSError *error, NSString *message) {
              }];
}

@end
