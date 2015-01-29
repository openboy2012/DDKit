//
//  DDWaterfallView.h
//  DDWaterfall
//
//  Created by Diaoshu on 15-1-18.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDWaterfallCell.h"

@protocol DDWaterfallViewDataSource;
@protocol DDWaterfallViewDelegate;

@interface DDWaterfallView : UIScrollView <UIScrollViewDelegate>{
}

@property (nonatomic, weak) IBOutlet id<DDWaterfallViewDataSource>  waterfallDataSource;
@property (nonatomic, weak) IBOutlet id<DDWaterfallViewDelegate>  waterfallDelegate;

@property (nonatomic) NSInteger currentPageIndex;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)reloadData;

- (DDWaterfallCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (NSInteger)numberOfColumns;

- (CGFloat)itemWidth;

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

@end


@protocol DDWaterfallViewDataSource <NSObject>

@required
/**
 *  Get number of rows in column at the waterfallView
 *
 *  @param waterfallView   waterfallView
 *  @param column   column index
 *
 *  @return number of rows;
 */
- (NSInteger)waterfallView:(DDWaterfallView *)waterfallView numberOfRowsInColumn:(NSInteger)column;

/**
 *  Get the waterfall cell for row at indexPath in waterfallView
 *
 *  @param waterfallView   waterfallView
 *  @param indexPath   indexPath
 *
 *  @return waterfall cell (you can use a custom cell)
 */
- (DDWaterfallCell *)waterfallView:(DDWaterfallView *)waterfallView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Get number of column in waterfallView
 *
 *  @param waterfallView waterfallView
 *
 *  @return number of column
 */
- (NSInteger)numberOfColumnsInWaterfallView:(DDWaterfallView *)waterfallView;

@end


@protocol DDWaterfallViewDelegate <NSObject>

@optional
/**
 *  Did select row at indexPath
 *
 *  @param waterfallView waterfallView
 *  @param indexPath indexPath
 */
- (void)waterfallView:(DDWaterfallView *)waterfallView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Get height for row at indexPath
 *
 *  @param waterfallView waterfallView
 *  @param indexPath indexPath
 *
 *  @return height of item
 */
- (CGFloat)waterfallView:(DDWaterfallView *)waterfallView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Get the horizontal spacing in waterfallView
 *
 *  @param waterfallView waterfallView
 *
 *  @return horizontal spacing
 */
- (CGFloat)horizontalSpacingInWaterfallView:(DDWaterfallView *)waterfallView;


/**
 *  Get the vertical spacing in waterfallView
 *
 *  @param waterfallView waterfallView
 *
 *  @return vertical spacing
 */
- (CGFloat)verticalSpacingInWaterfallView:(DDWaterfallView *)waterfallView;

@end


@interface NSIndexPath(DDWaterfallView)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger column;

@end