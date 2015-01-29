//
//  DDWaterfallCell.h
//  DDWaterfall
//
//  Created by Diaoshu on 15-1-18.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDWaterfallCell : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *backgroundView;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (void)prepareForReuse;

@end