//
//  KKScrollView.h
//  KKScrollView
//
//  Created by Li xuechuan on 12-5-20.
//  Copyright (c) 2012年 SNDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKScrollViewDelegate;

@interface KKScrollView : UIView <UIScrollViewDelegate> {

}

@property (nonatomic, assign) id <KKScrollViewDelegate>delegate;

@property (nonatomic, assign) NSInteger currPageIdx;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) BOOL pageEnabled;
@property (nonatomic, assign) CGFloat colGap; //default is zero
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL isCycle;//if is yes, cycle scrollview

- (UIView *)dequeueReusablePage;
- (UIScrollView*)scrollView;
- (UIView *)viewForPageAtIndex:(NSUInteger)index;

- (void)reloadPageInView:(KKScrollView*)scrollView atIndex:(NSInteger)aIndex;
- (void)reloadData;

@end

@protocol KKScrollViewDelegate <NSObject>

@required

- (UIView*)viewForIndexInView:(KKScrollView*)scrollView index:(NSInteger)index;
- (int)numberOfPagesInView:(KKScrollView*)scrollView;

@optional

- (void)didClickedPagesInView:(KKScrollView*)scrollView atIndex:(NSInteger)aIndex;
- (void)didScrolledInView:(KKScrollView*)scrollView atIndex:(NSInteger)aIndex;
- (void)didScrolledEndInView:(KKScrollView*)scrollView atIndex:(NSInteger)aIndex;

- (void)didSwipeOutOfPage;

@end