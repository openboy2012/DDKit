//
//  DDWaterfallView.m
//  DDWaterfall
//
//  Created by Diaoshu on 15-1-18.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import "DDWaterfallView.h"

#define HoritonzalSpacing 10.0f
#define VerticalSpacing 10.0f
#define DefaultHeight 100.0f

@interface DDWaterfallView()<UIGestureRecognizerDelegate>{
    CGFloat itemWidth;
    BOOL isRegisterNib;
    UINib *regsiterNib;
    NSString *registerNibReuseIdentifier;
}

@property (nonatomic) NSInteger columns; // waterfall columns in current waterfallView
@property (nonatomic, strong) NSMutableDictionary *reuseDict; //reuse Dictionary
@property (nonatomic, strong) NSMutableArray *cellRectArray; // all the rectangles array
@property (nonatomic, strong) NSMutableArray *visibleCells; // visible cell arry in waterfallView

/**
 *  waterfallView initalize
 */
- (void)initialize;

/**
 *  waterfallView scroll methods
 */
- (void)onScroll;

/**
 *  check the rectangle can remove from the waterfallView
 *
 *  @param rect rectangle will check
 *
 *  @return true or false
 */
- (BOOL)canRemoveCellForRect:(CGRect)rect;

/**
 *  check the indexPath had added the waterfallView
 *
 *  @param indexPath indexPath will check
 *
 *  @return true or false
 */
- (BOOL)containVisibleCellForIndexPath:(NSIndexPath *)indexPath;

/**
 *  add the waterfallCell into reuseDictionary
 *
 *  @param cell waterfallCell will add into reuse
 */
- (void)addReusableCell:(DDWaterfallCell *)cell;

/**
 *  add the waterfallCell in the waterfallView
 *
 *  @param cell waterfallCell
 */
- (void)addSubCell:(DDWaterfallCell *)cell;

/**
 *  add the tapGestureRecongnizer on the the cell
 *
 *  @param recognizer tapGestureRecongnizer
 */
- (void)didTap:(UITapGestureRecognizer *)recognizer;

@end

@implementation DDWaterfallView

#pragma mark - DDWaterfallView Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.delegate = self;
        self.clipsToBounds = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.reuseDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.clipsToBounds = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.reuseDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self onScroll];
    
    if ([self.waterfallDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.waterfallDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [(id<UIScrollViewDelegate>)self.waterfallDelegate scrollViewDidScroll:self];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self onScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    ;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.waterfallDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [self.waterfallDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [(id<UIScrollViewDelegate>)self.waterfallDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    ;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    ;
}

#pragma mark - UIGestureRecognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    UIView *touchView = touch.view;
    if([touchView isKindOfClass:[UIButton class]]){
        return NO;
    }else
        return YES;
}

#pragma mark - DDWaterfallView Interface

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier{
    isRegisterNib = YES;
    regsiterNib = nib;
    registerNibReuseIdentifier = identifier;
//    [cell.layer setValue:identifier forKey:@"reuseKey"];
//    [cell prepareForReuse];
//    [self addReusableCell:cell];
}

- (void)reloadData
{
    if (self.visibleCells && [self.visibleCells count] > 0) {
        for (int i = 0; i < [self.visibleCells count]; ++i) {
            NSMutableArray *singleVisibleArray = [self.visibleCells objectAtIndex:i];
            if (!singleVisibleArray || 0 == [singleVisibleArray count]) continue;
            
            NSUInteger visibleCellCount = [singleVisibleArray count];
            for (int j = 0; j < visibleCellCount; ++j) {
                DDWaterfallCell *cell = [singleVisibleArray objectAtIndex:j];
                [self addReusableCell:cell];
                if (cell.superview)
                    [cell removeFromSuperview];
            }
        }
    }
    
    [self initialize];
}

- (DDWaterfallCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (nil == identifier || 0 == identifier.length) {
        return nil;
    }
    
    NSMutableArray *reuseQueue = [self.reuseDict objectForKey:identifier];
    if(reuseQueue && [reuseQueue isKindOfClass:[NSArray class]] && reuseQueue.count > 0) {
        DDWaterfallCell *cell = [reuseQueue lastObject];
        [reuseQueue removeLastObject];
        return cell;
    }
    
    if(isRegisterNib){
        DDWaterfallCell *cell = [regsiterNib instantiateWithOwner:nil options:0][0];
        [cell.layer setValue:registerNibReuseIdentifier forKey:@"reuseKey"];
        [cell prepareForReuse];
        return cell;
    }
    
    return nil;
}

#pragma mark - Private Methods

- (void)initialize
{
    self.columns = [self.waterfallDataSource numberOfColumnsInWaterfallView:self];
    self.reuseDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    self.cellRectArray = [NSMutableArray arrayWithCapacity:self.columns];
    self.visibleCells = [NSMutableArray arrayWithCapacity:self.columns];
    
    CGFloat scrollHeight = 0.0f;
    
    for (int i = 0; i < self.columns; ++i) {
        NSMutableArray *singleRectArray = [NSMutableArray array];
        
        NSInteger rows = [self.waterfallDataSource waterfallView:self numberOfRowsInColumn:i];
        
        CGFloat heightTillNow = 0.0f;
        
        CGFloat hSpacing = HoritonzalSpacing;
        CGFloat vSpacing = VerticalSpacing;
        if([self.waterfallDelegate respondsToSelector:@selector(horizontalSpacingInWaterfallView:)]){
            hSpacing = [self.waterfallDelegate horizontalSpacingInWaterfallView:self];
        }
        if([self.waterfallDelegate respondsToSelector:@selector(verticalSpacingInWaterfallView:)]){
            vSpacing = [self.waterfallDelegate verticalSpacingInWaterfallView:self];
        }
        
        itemWidth = ceilf((self.bounds.size.width - self.contentInset.left - self.contentInset.right - hSpacing * (self.columns - 1) )/self.columns);
        
        CGFloat originX = (itemWidth + hSpacing) * i;
        
        for (int j = 0; j < rows; ++j) {
            CGFloat originY = heightTillNow;
            CGFloat itemHeight = DefaultHeight;
            if([self.waterfallDelegate respondsToSelector: @selector(waterfallView:heightForRowAtIndexPath:)]){
                itemHeight = [self.waterfallDelegate waterfallView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inColumn:i]];
            }
            
            CGRect rect = CGRectMake(originX, originY, itemWidth, itemHeight);
            [singleRectArray addObject:[NSValue valueWithCGRect:rect]];
            
            heightTillNow += (itemHeight + ((j < rows - 1) ? vSpacing : 0.0f));
        }
        
        scrollHeight = (heightTillNow >= scrollHeight) ? heightTillNow : scrollHeight;
        [self.cellRectArray addObject:singleRectArray];
        
        // create a empty array
        NSMutableArray *singleItemArray = [NSMutableArray array];
        [self.visibleCells addObject:singleItemArray];
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width - self.contentInset.left - self.contentInset.right, scrollHeight);
    
    [self onScroll];
}

- (CGFloat)itemWidth{
    return itemWidth;
}

- (void)onScroll
{
    for (int i = 0; i < self.columns; ++i) {
        int basicVisibleRow = 0;
        DDWaterfallCell *cell = nil;
        CGRect cellRect = CGRectZero;
        
        NSMutableArray *singleRectArray = [self.cellRectArray objectAtIndex:i];
        NSMutableArray *singleItemArray = [self.visibleCells objectAtIndex:i];
        
        if (0 == [singleItemArray count]) {
            // There is no visible cells in current column now, find one.
            for (int j = 0; j < [singleRectArray count]; ++j) {
                cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
                if (![self canRemoveCellForRect:cellRect]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inColumn:i];
                    basicVisibleRow = j;
                    
                    cell = [self.waterfallDataSource waterfallView:self cellForRowAtIndexPath:indexPath];
                    
                    cell.frame = cellRect;
                    
                    //add the indentifier IndexPath
                    [cell.layer setValue:indexPath forKey:@"indexPathKey"];
                    
                    [self addSubCell:cell];
                    
                    [singleItemArray insertObject:cell atIndex:0];
                    break;
                }
            }
        } else {
            cell = [singleItemArray objectAtIndex:0];
            basicVisibleRow = (int)[self.cellRectArray[i] indexOfObject:[NSValue valueWithCGRect:cell.frame]];
        }
        
        // Look back to load visible cells
        for (int j = basicVisibleRow - 1; j >= 0; --j) {
            cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
            //check the cell rectangle can add the waterfallView
            if (![self canRemoveCellForRect:cellRect]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inColumn:i];
                if ([self containVisibleCellForIndexPath:indexPath]) {
                    continue ;
                }
                
                cell = [self.waterfallDataSource waterfallView:self cellForRowAtIndexPath:indexPath];
                cell.frame = cellRect;
                //add the indentifier IndexPath
                [cell.layer setValue:indexPath forKey:@"indexPathKey"];
                
                [self addSubCell:cell];
                
                [singleItemArray insertObject:cell atIndex:0];
            } else {
                // jump out the for recycle.
                break;
            }
        }
        
        // Look forward to load visible cells
        for (int j = basicVisibleRow + 1; j < [singleRectArray count]; ++j) {
            cellRect = [(NSValue *)[singleRectArray objectAtIndex:j] CGRectValue];
            //check the cell rectangle can add the waterfallView
            if (![self canRemoveCellForRect:cellRect]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inColumn:i];
                if ([self containVisibleCellForIndexPath:indexPath]) {
                    continue ;
                }
                
                cell = [self.waterfallDataSource waterfallView:self cellForRowAtIndexPath:indexPath];
                
                [cell.layer setValue:indexPath forKey:@"indexPathKey"];

                cell.frame = cellRect;
                
                [self addSubCell:cell];
                
                [singleItemArray insertObject:cell atIndex:0];
            } else {
                // jump out the for recycle.
                break;
            }
        }
        
        // Recycle invisible cells
        for (int j = 0; j < [singleItemArray count]; ++j) {
            cell = [singleItemArray objectAtIndex:j];
            if ([self canRemoveCellForRect:cell.frame]) {
                [self addReusableCell:cell];
                [singleItemArray removeObject:cell];
                [cell removeFromSuperview];
                --j;
            }
        }
    }
}

- (void)addSubCell:(DDWaterfallCell *)cell{
    if(!cell.superview){
        UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        cellTap.delegate = self;
        [cell addGestureRecognizer:cellTap];
        [self addSubview:cell];
    }
}

- (void)didTap:(UITapGestureRecognizer *)recognizer{
    NSIndexPath *indexPath = nil;
    id item = recognizer.view;
    if([item isKindOfClass:[DDWaterfallCell class]]){
        indexPath = [[(DDWaterfallCell *)item layer] valueForKey:@"indexPathKey"];
    }
    if([self.waterfallDelegate respondsToSelector:@selector(waterfallView:didSelectRowAtIndexPath:)]){
        [self.waterfallDelegate waterfallView:self didSelectRowAtIndexPath:indexPath];
    }
}


- (BOOL)canRemoveCellForRect:(CGRect)rect
{
    CGPoint offset = [self contentOffset];
    
    if (rect.origin.y + rect.size.height < offset.y
        || rect.origin.y > (offset.y + self.bounds.size.height)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)containVisibleCellForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *singleItemArray = [self.visibleCells objectAtIndex:indexPath.section];
    for (int i = 0; i < [singleItemArray count]; ++i) {
        DDWaterfallCell *cell = [singleItemArray objectAtIndex:i];
        if ([[cell.layer valueForKey:@"indexPathKey"] isEqual:indexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)addReusableCell:(DDWaterfallCell *)cell
{
    if (nil == cell.reuseIdentifier || 0 == cell.reuseIdentifier.length) {
        return ;
    }
    
    NSMutableArray *reuseQueue = [self.reuseDict objectForKey:cell.reuseIdentifier];
    
    if(nil == reuseQueue) {
        reuseQueue = [NSMutableArray arrayWithObject:cell];
        [self.reuseDict setObject:reuseQueue forKey:cell.reuseIdentifier];
    } else {
        [reuseQueue addObject:cell];
    }
}

- (NSInteger)numberOfColumns{
    return self.columns;
}

@end


@implementation NSIndexPath(DDWaterfallView)

@dynamic column;
@dynamic row;

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:column];
    return indexPath;
}

@end