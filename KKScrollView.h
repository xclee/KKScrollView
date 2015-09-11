//
//  KKScrollView.h
//  KKScrollView
//
//  Created by Li xuechuan on 12-5-20.
//  Copyright (c) 2012年 SNDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKScrollViewDelegate;

@interface KKScrollView : UIView <UIScrollViewDelegate>{

    id <KKScrollViewDelegate>_delegate;
    
    UIScrollView *_scrollView;
    int          _pageCnt;
    int         lowBoundsPage;
    int         highBoundsPage;
    int         _currPageIdx;
    
    NSMutableSet *_onScreenPages;
    NSMutableSet *_offScreenPages;
    CGSize      _pageSize;//when not use pageEnabled ,pageSize must init
    BOOL        _pageEnabled;//if you use pageEnabled, pageSize must zero
    CGFloat     _colGap;
    UIEdgeInsets    _contentInsets;
    UIImageView *_backgroundView;
}

@property (nonatomic, assign) id <KKScrollViewDelegate>delegate;

@property (assign, readonly) int lowBoundsPage;
@property (assign, readonly) int hightBoundsPage;
@property (nonatomic, assign) int currPageIdx;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) BOOL pageEnabled;
@property (nonatomic, assign) CGFloat colGap;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL isCycle;//if is cycle scrollview

- (UIView *)dequeueReusablePage;
- (UIScrollView*)scrollView;
- (UIView *)viewForPageAtIndex:(NSUInteger)index;

- (void)reloadPageInView:(KKScrollView*)scrollView atIndex:(int)aIndex;
- (void)reloadData;

@end

@protocol KKScrollViewDelegate <NSObject>

@required

- (UIView*)viewForIndexInView:(KKScrollView*)scrollView index:(int)index;
- (int)numberOfPagesInView:(KKScrollView*)scrollView;

@optional

- (void)didClickedPagesInView:(KKScrollView*)scrollView atIndex:(int)aIndex;
- (void)didScrolledInView:(KKScrollView*)scrollView atIndex:(int)aIndex;
- (void)didScrolledEndInView:(KKScrollView*)scrollView atIndex:(int)aIndex;

- (void)didSwipeOutOfPage;

@end