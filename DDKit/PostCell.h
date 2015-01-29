//
//  PostCell.h
//  DDKit
//
//  Created by Diaoshu on 15-1-19.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import "DDWaterfallCell.h"
#import "Post.h"

@interface PostCell : DDWaterfallCell

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *lblNickname;
@property (nonatomic, strong) UILabel *lblContent;

- (void)setPostItem:(Post *)p itemWidth:(CGFloat)width;

+ (CGFloat)heightOfCell:(Post *)p itemWidth:(CGFloat)width;

@end
