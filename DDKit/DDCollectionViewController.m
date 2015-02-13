//
//  DDCollectionViewController.m
//  DDKit
//
//  Created by Diaoshu on 14-12-23.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "DDCollectionViewController.h"
#import "DMDynamicWaterfall.h"
#import "Post.h"
#import <UIImageView+WebCache.h>


@interface DDCollectionViewCell  : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *header;
@property (nonatomic, weak) IBOutlet UILabel *lblNickname;
@property (nonatomic, weak) IBOutlet UILabel *lblContent;

- (void)setCollectionCellItem:(Post *)p;

+ (CGFloat)heightOfCell:(Post *)p;

@end

#define ItemWidth ([UIScreen mainScreen].bounds.size.width - 30.0)/2.0f

@implementation DDCollectionViewCell

- (void)setCollectionCellItem:(Post *)p{
    [self.header sd_setImageWithURL:[NSURL URLWithString:p.user.avatarImageURLString]];
    self.lblNickname.text = p.user.username;
    self.lblContent.text = p.text;
    self.lblContent.frame = CGRectMake(self.lblContent.frame.origin.x, self.lblContent.frame.origin.y, ItemWidth - 10.0, self.lblContent.frame.size.height);
    [self.lblContent resizeLabelVertical];
    self.layer.borderWidth = boardWidth;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

+ (CGFloat)heightOfCell:(Post *)p{
    CGFloat height = 70.0f;
    CGSize sizeText = CGSizeZero;
    if ([p.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f], NSParagraphStyleAttributeName:paragraphStyle.copy};
        sizeText = [p.text boundingRectWithSize:CGSizeMake(135.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
        sizeText = [p.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(ItemWidth - 10.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return height + ceil(sizeText.height);
}

@end

@interface DDCollectionViewController ()<DMDynamicWaterfallDelegate,UICollectionViewDelegate>{
    NSMutableArray *dataList;
}

@end

@implementation DDCollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    if(!dataList)
        dataList = [[NSMutableArray alloc] init];
    [dataList removeAllObjects];
    
    // Register cell classes
    // 如果你注册了这个Cell Class 你就不能使用Storyboard里的布局了。
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"header"];
    
    self.title = @"DDKit-Waterfall";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"◁返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    
    DMDynamicWaterfall *layout = [[DMDynamicWaterfall alloc] init];
    layout.delegate = self;
    layout.dynamic = NO;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self refreshData];
    // Do any additional setup after loading the view.
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete method implementation -- Return the number of items in the section
    
    if(section == 0)
        return dataList.count > 0 ? 1: 0;
    return dataList.count;
}

- (NSUInteger)collectionView:(UICollectionView *)aCollectionView layout:(DMDynamicWaterfall *)aLayout numberOfColumnsInSection:(NSUInteger)aSectionIdx{
    if(aSectionIdx == 0)
        return 1;
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"header" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    static NSString *reuseIdentifier = @"DDCell";

    DDCollectionViewCell *cell = (DDCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Post *p = dataList[indexPath.row];
        [cell setCollectionCellItem:p];
    
    // Configure the cell
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"dbSegue" sender:nil];
    return YES;
}

// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(section == 0){
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(10.0, 10.0, 0.0, 10.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return CGSizeMake(320.0, 200.0f);
    }else
        return CGSizeMake(145.0, [DDCollectionViewCell heightOfCell:dataList[indexPath.row]]);
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(10.0, 10.0, 0.0, 10.0);
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView
//                   layout:(UICollectionViewWaterfallLayout *)collectionViewLayout
// heightForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return [DDCollectionViewCell heightOfCell:dataList[indexPath.row]];
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(145.0, 183.0 + rand() % 60);
//}

- (void)refreshData{
    [Post getPostList:nil
             parentVC:self
              showHUD:YES
              success:^(id data) {
                  [dataList removeAllObjects];
                  [dataList addObjectsFromArray:data];
                  [self.collectionView reloadData];
              }
              failure:^(NSError *error, NSString *message) {
              }];
}

- (void)goBack{
    [Post cancelRequest:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
