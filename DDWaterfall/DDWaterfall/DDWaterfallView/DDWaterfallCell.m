//
//  DDWaterfallCell.m
//  DDWaterfall
//
//  Created by Diaoshu on 15-1-18.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import "DDWaterfallCell.h"

@implementation DDWaterfallCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.clipsToBounds = YES;
        [self initialize];
    }
    return self;
}

- (void)prepareForReuse{
    _reuseIdentifier = [self.layer valueForKey:@"reuseKey"];
}

- (void)dealloc
{
    [_textLabel removeObserver:self forKeyPath:@"text" context:NULL];
    [self removeObserver:self forKeyPath:@"frame" context:NULL];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        [self.layer setValue:identifier forKey:@"reuseKey"];
        self.clipsToBounds = YES;
        
        [self initialize];
    }
    return self;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"text"]){
        _textLabel.hidden = NO;
        if(!change[@"new"])
            _textLabel.hidden = YES;
    }else if([keyPath isEqual:@"frame"] && [object isEqual:self]){
        _textLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        _contentView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        if(_backgroundView)
            _backgroundView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    }
}

#pragma mark - Private Methods

- (void)initialize{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.hidden = YES;
    [self addSubview:_textLabel];
    
    [_textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
}


@end
