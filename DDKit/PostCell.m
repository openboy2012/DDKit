//
//  PostCell.m
//  DDKit
//
//  Created by Diaoshu on 15-1-19.
//  Copyright (c) 2015年 Dejohn Dong. All rights reserved.
//

#import "PostCell.h"
#import <UIImageView+WebCache.h>

@implementation PostCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithIdentifier:(NSString *)identifier{
    self = [super initWithIdentifier:identifier];
    if(self){
        if(!self.headerImageView){
            self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 60.0, 60.0)];
        }
        [self.contentView addSubview:self.headerImageView];
//        self.headerImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        if(!self.lblNickname){
            self.lblNickname = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 10.0, 70.0, 40.0)];
        }
        self.lblNickname.numberOfLines = 2;
        self.lblNickname.textColor = [UIColor darkGrayColor];
        self.lblNickname.font = [UIFont systemFontOfSize:14.0f];
        self.lblNickname.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lblNickname];
        
        if(!self.lblContent){
            self.lblContent = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 70.0, 200.0f, 40.0)];
        }
        self.lblContent.numberOfLines = 0;
        self.lblContent.font = [UIFont systemFontOfSize:14.0f];
        self.lblContent.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lblContent];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setPostItem:(Post *)p itemWidth:(CGFloat)width{
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:p.user.avatarImageURLString]];
    self.lblNickname.text = p.user.username;
    self.lblNickname.frame = CGRectMake(70.0, 10.0, width - 75.0, 40.0f);
    
    self.lblContent.text = p.text;
    self.lblContent.textColor = [UIColor lightGrayColor];
    self.lblContent.frame = CGRectMake(5.0, 70.0, width - 10.0f, 40.0f);
    [self.lblContent resizeLabelVertical];
    
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
    
}


+ (CGFloat)heightOfCell:(Post *)p itemWidth:(CGFloat)width{
    CGFloat height = 70.0f;
    CGSize sizeText = CGSizeZero;
    if ([p.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f], NSParagraphStyleAttributeName:paragraphStyle.copy};
        sizeText = [p.text boundingRectWithSize:CGSizeMake(width - 10.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
        sizeText = [p.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width - 10.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    height += ceil(sizeText.height);
    return height;
}

@end
