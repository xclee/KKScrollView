//
//  KKScrollView.m
//  KKScrollView
//
//  Created by Li xuechuan on 12-5-20.
//  Copyright (c) 2012年 SNDA. All rights reserved.
//

#import "KKScrollView.h"

@interface KKScrollView ()
{
    id <KKScrollViewDelegate>_delegate;
    UIPageControl *_pageControl;
    
    UIScrollView *_scrollView;
    NSInteger  _pageCnt;
    NSInteger  lowBoundsPage;
    NSInteger  highBoundsPage;
    NSInteger  _currPageIdx;
    NSMutableSet *_onScreenPages;
    NSMutableSet *_offScreenPages;
    CGSize  _pageSize;//when not use pageEnabled ,pageSize must init
    BOOL  _pageEnabled;//if you use pageEnabled, pageSize must zero
    CGFloat  _colGap;
    UIEdgeInsets  _contentInsets;
    UIImageView *_backgroundView;
}

@property (assign, readonly) NSInteger lowBoundsPage;
@property (assign, readonly) NSInteger hightBoundsPage;

- (void)configurePages;

@end

@implementation KKScrollView

@synthesize lowBoundsPage, hightBoundsPage;
@synthesize currPageIdx = _currPageIdx;
@synthesize delegate = _delegate;
@synthesize pageSize = _pageSize;
@synthesize pageEnabled = _pageEnabled;
@synthesize colGap = _colGap;
@synthesize contentInsets = _contentInsets;
@synthesize backgroundImage = _backgroundImage;

const int preloadCount = 3;

- (void)initContentSize
{
    _pageCnt = [_delegate numberOfPagesInView:self];
    
    _pageControl.numberOfPages = _pageCnt;
    CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
    _pageControl.frame = CGRectMake((self.frame.size.width - size.width)*0.5, _scrollView.frame.size.height - 16 , size.width, 16);
    
    if (self.isCycle && _pageCnt > 1) {
        _pageCnt += 2;
        _currPageIdx = 1;
    }
    if(self.pageSize.width > 0){
        _scrollView.contentSize =  CGSizeMake(self.contentInsets.left + self.pageSize.width * _pageCnt + (_pageCnt - 1) * _colGap, _scrollView.frame.size.height);
        _scrollView.contentOffset = CGPointMake(self.pageSize.width * _currPageIdx,0);
    } else{
        _scrollView.contentSize =  CGSizeMake(_scrollView.frame.size.width * _pageCnt, _scrollView.frame.size.height);
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * _currPageIdx, 0);
    }
}

- (void)reloadData
{
    [self initData];
}

- (void)initData
{
    [self initContentSize];
    if(_onScreenPages){
        for (UIView *page in _onScreenPages){
            [page removeFromSuperview];
        }
        [_onScreenPages removeAllObjects];
        [_onScreenPages release];
        _onScreenPages = nil;
    }
    if(_offScreenPages){
        for (UIView *page in _offScreenPages){
            [page removeFromSuperview];
        }
        [_offScreenPages removeAllObjects];
        [_offScreenPages release];
        _offScreenPages = nil;
    }
    _onScreenPages = [[NSMutableSet alloc] init];
    _offScreenPages = [[NSMutableSet alloc] init];
     
    [self configurePages];
}

- (void)initView
{
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_backgroundView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    _pageSize = CGSizeMake(0, 0);
    _colGap = 0.0f;
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    _pageControl.currentPage = self.currPageIdx;
    _pageControl.hidesForSinglePage = YES;
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    _pageControl.pageIndicatorTintColor = HTHexColor(0xdb7b7b);
    _pageControl.currentPageIndicatorTintColor = HTHexColor(0xde3031);
    [self addSubview:_pageControl];
    [_pageControl release];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
        [self initData];
    }
    return self;
}

- (void)dealloc
{
    [_onScreenPages release];
    _onScreenPages = nil;
    [_offScreenPages release];
    _offScreenPages = nil;
    _delegate = nil;
    _scrollView.delegate = nil;
    [_scrollView release];
    [_backgroundView release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
        [self initData];
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundView.image = backgroundImage;
}

- (void)setPageSize:(CGSize)pageSize
{
    _pageSize = CGSizeMake(pageSize.width, pageSize.height);
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
}

- (void)setPageEnabled:(BOOL)pageEnabled
{
    _pageEnabled = pageEnabled;
    _scrollView.pagingEnabled = _pageEnabled;
    _scrollView.scrollEnabled = YES;
}

- (void)setDelegate:(id<KKScrollViewDelegate>)delegate
{
    _delegate = delegate;
    if(_delegate)
        [self initData];
}

- (NSInteger)newPageIndex
{
    CGRect visibleBounds = _scrollView.bounds;
    NSInteger newPageIndex = MIN(MAX(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)), 0), _pageCnt - 1);
    
    newPageIndex = MAX(0, MIN(_pageCnt, newPageIndex));
    return newPageIndex;
}

- (BOOL) isOutOfPageRange
{
    CGRect visibleBounds = _scrollView.bounds;
    return ((CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)) > _pageCnt - 1 + 0.8);
}

- (UIView *)viewForPageAtIndex:(NSUInteger)index {
    for (UIView *page in _onScreenPages)
        if (page.tag == index)
            return page;
    return nil;
}

- (void)reloadPage:(UIView*)page AtIndex:(NSInteger)index
{
    page.tag = index;
    CGSize pageSizes = self.bounds.size;
    if(self.pageSize.width > 0){
        page.frame = CGRectMake(self.contentInsets.left + self.pageSize.width * index + index * _colGap,
                                self.contentInsets.top , self.pageSize.width, self.pageSize.height - self.contentInsets.top);
    }else{
        page.frame = CGRectMake(_scrollView.frame.size.width * index ,
                      0, pageSizes.width, pageSizes.height);
    }
    [page setNeedsDisplay];
}

- (void)reloadPageInView:(KKScrollView*)scrollView atIndex:(NSInteger)aIndex
{
    UIView *view = [self viewForPageAtIndex:aIndex];
    if(view){
        [_onScreenPages removeObject:view];
        [view removeFromSuperview];
        [self configurePages];
    }
}

- (UIScrollView*)scrollView
{
    return _scrollView;
}

- (UIView *)dequeueReusablePage
{
    UIView *result = [_offScreenPages anyObject];
    if (result) {
        [_offScreenPages removeObject:[[result retain] autorelease]];
    }
    return result;
}

- (void)configurePages {
    if (_pageCnt < 1) {
        return;
    }
    NSInteger newPage = [self newPageIndex];
    NSInteger lowVisiblePage = self.lowBoundsPage;
    NSInteger highVisiblePage  = self.hightBoundsPage;
    NSInteger low = MAX(0,            MIN(lowVisiblePage, newPage - preloadCount));
    NSInteger high  = MIN(_pageCnt - 1, MAX(highVisiblePage,  newPage + preloadCount));
    
    NSMutableSet *pagesToRemove = [NSMutableSet set];
    for (UIView *page in _onScreenPages) {
        if (page.tag < low || page.tag > high) {
            [pagesToRemove addObject:page];
            [_offScreenPages addObject:page];
            [page removeFromSuperview];
        }
    }
    if(pagesToRemove.count)
        [_onScreenPages minusSet:pagesToRemove];
    
    
    for(NSInteger i = low; i<= high; i++) {
        NSInteger index = i;
        NSInteger count = [_delegate numberOfPagesInView:self];
        if(![self viewForPageAtIndex:i]){
            if (self.isCycle) {
                if (count > 0) {
                    if (index == 0) {
                        index = _pageControl.numberOfPages - 1;
                    } else if(index == _pageControl.numberOfPages + 1) {
                        index = 0;
                    } else {
                        index--;
                    }
                }
            }
            UIView *page = [_delegate viewForIndexInView:self index:index];
            [self reloadPage:page AtIndex:i];
            [_scrollView addSubview:page];
            [_onScreenPages addObject:page];
        }
    }
    
    if(_currPageIdx != newPage) {
        if([_delegate respondsToSelector:@selector(didScrolledInView:atIndex:)]){
            [_delegate didScrolledInView:self atIndex:newPage];
        }
        _currPageIdx = newPage;
    }
    
    if (!self.isCycle && _pageControl.numberOfPages > 0) {
        _pageControl.currentPage = _currPageIdx;
    }
}

- (NSInteger)firstVisibleItemIndex
{
    int firstRow = MAX(floorf((CGRectGetMinX(_scrollView.bounds)  -  self.contentInsets.left) / (self.pageSize.width + _colGap)), 0);
    return MIN( MAX(0,firstRow - (preloadCount)) , _pageCnt - 1);
}

- (NSInteger)lastVisibleItemIndex
{
    int lastRow = MIN( ceilf((CGRectGetMaxX(_scrollView.bounds) -  self.contentInsets.left) / (self.pageSize.width + _colGap)), _pageCnt - 1);
    return MIN((lastRow + (preloadCount + 1))  - 1, _pageCnt - 1);
}

- (NSInteger)lowBoundsPage
{
    if(self.pageSize.width > 0)
        return [self firstVisibleItemIndex];
    
    CGRect visibleBounds = _scrollView.bounds;
    return MAX(floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds)), 0);
}

- (NSInteger)hightBoundsPage
{
    if(self.pageSize.width > 0)
        return [self lastVisibleItemIndex];
    CGRect visibleBounds = _scrollView.bounds;
    return MIN(floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds)), _pageCnt - 1);
}

- (void)setCurrPageIdx:(NSInteger)aPageIdx{

    if(self.pageSize.width > 0) {
         [_scrollView setContentOffset:CGPointMake(self.contentInsets.left +  self.pageSize.width * aPageIdx + aPageIdx * _colGap, 0) animated:NO];
    } else {
         [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * aPageIdx, 0) animated:NO];
    }
   
    _currPageIdx = aPageIdx;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isCycle) {
        CGFloat width = CGRectGetWidth(scrollView.frame);
        NSInteger pageIndex = scrollView.contentOffset.x / width;
        if ((pageIndex == 0 || pageIndex == _pageControl.numberOfPages + 1) && scrollView.isDecelerating) {
            scrollView.scrollEnabled = NO;
            return;
        }
    }
    [self configurePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollView.scrollEnabled = YES;

    NSInteger newIndex = _currPageIdx;
    if (self.isCycle) {
        int count = [_delegate numberOfPagesInView:self];
        if (count > 0) {
            if (newIndex == 0) {
                self.currPageIdx = _pageControl.numberOfPages;
                newIndex = _pageControl.numberOfPages - 1;
                
            } else if(newIndex == _pageControl.numberOfPages + 1) {
                self.currPageIdx = 1;
                newIndex = 0;
            } else {
                newIndex--;
            }
            if (_pageControl.numberOfPages > 0) {
                _pageControl.currentPage = newIndex;
            }
        }
    }
    
    if([_delegate respondsToSelector:@selector(didScrolledEndInView:atIndex:)]) {
        [_delegate didScrolledEndInView:self atIndex:newIndex];
    }
}

#pragma mark - pageControll

- (void)changePage:(id)sender
{
    
}

@end
