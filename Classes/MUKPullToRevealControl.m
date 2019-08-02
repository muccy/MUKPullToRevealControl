#import "MUKPullToRevealControl.h"
#import <MUKSignal/MUKSignal.h>
#import "MUKPullToRevealControlScroll.h"
#import "MUKPullToRevealControlInsertion.h"
#import "MUKPullToRevealControlRemoval.h"

#define DEBUG_SHOW_BORDERS          0
#define DEBUG_LOG_FRAME             0
#define DEBUG_LOG_CONTENT_INSET     0
#define DEBUG_LOG_SCROLLS           0
#define DEBUG_LOG_USER_STATES       0

@interface MUKPullToRevealControl ()
@property (nonatomic, readwrite) MUKPullToRevealControlState revealState;

@property (nonatomic, readonly, nullable) MUKSignalObservation<MUKKVOSignal *> *scrollViewContentInsetObservation, *scrollViewContentOffsetObservation;

@property (nonatomic) NSValue *trackedContentInset, *trackedContentOffset;

@property (nonatomic, copy) dispatch_block_t jobAfterUserTouch;
@property (nonatomic) MUKPullToRevealControlScroll *runningScroll;

@property (nonatomic, nullable) MUKPullToRevealControlLayouter *layouter;
@end

@implementation MUKPullToRevealControl
@dynamic scrollView, originalTopInset, ignoresOriginalTopInset;

- (void)dealloc {
    // Ensure immediate unobservation
    _scrollViewContentInsetObservation = nil;
    _scrollViewContentOffsetObservation = nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

#pragma mark - Overrides

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    MUKPullToRevealControlInsertion *const insertion = [[MUKPullToRevealControlInsertion alloc] initWithControl:self superview:newSuperview];
    
    if (insertion.canStart) {
        self.layouter = [insertion start];
        [self.layouter start];
    }
    else {
        MUKPullToRevealControlRemoval *const removal = [[MUKPullToRevealControlRemoval alloc] initWithSuperview:newSuperview layouter:self.layouter];
        if (removal.canStart) {
            [removal start];
        }
    }
}

#pragma mark - Accessors

- (UIScrollView * __nullable)scrollView {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)self.superview;
    }
    
    return nil;
}

- (BOOL)ignoresOriginalTopInset {
    return self.layouter.insetLayouter.ignoresOriginal;
}

- (CGFloat)originalTopInset {
    return self.layouter.insetLayouter.original.top;
}

- (void)setOriginalTopInset:(CGFloat)originalTopInset {
    self.layouter.insetLayouter.originalTop = originalTopInset;
}

- (void)setRevealState:(MUKPullToRevealControlState)revealState {
    if (revealState != _revealState) {
        MUKPullToRevealControlState const oldState = _revealState;
        
        _revealState = revealState;
        
        // React
        [self didChangeRevealStateFromState:oldState];
    }
}

- (void)setPositionOffset:(UIOffset)positionOffset {
    if (!UIOffsetEqualToOffset(positionOffset, _positionOffset)) {
        _positionOffset = positionOffset;
        
        UIScrollView *const scrollView = self.scrollView;
        if (scrollView) {
            [self updateFrameInScrollView:scrollView];
        }
    }
}

#pragma mark - Methods

- (void)revealAnimated:(BOOL)animated {
    if (self.revealState != MUKPullToRevealControlStateRevealed) {
        UIScrollView *const scrollView = self.scrollView;
        UIEdgeInsets const newInset = [self revealedInsetsOfScrollView:scrollView];
        
        __weak typeof(self) weakSelf = self;
        __weak __typeof__(scrollView) weakScrollView = scrollView;

        void const (^update)(void) = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            __strong __typeof__(weakScrollView) strongScrollView = weakScrollView;

            [strongSelf setContentInset:newInset toScrollView:strongScrollView];
            [strongSelf updateFrameInScrollView:strongScrollView];
            [strongSelf updateContentViewFrameInScrollView:strongScrollView];
        };
        
        CGRect const boundsAfterScroll = ({
            CGRect rect = scrollView.bounds;
            rect.origin.y += scrollView.contentInset.top - newInset.top;
            rect;
        });
        
        CGRect potentialFrame = self.frame;
        potentialFrame.size.height = self.revealHeight;
        
        BOOL const shouldScroll = CGRectIntersectsRect(potentialFrame, boundsAfterScroll);
        if (shouldScroll) {
            CGPoint contentOffset = scrollView.contentOffset;
            
            if (@available(iOS 11, *)) {
                contentOffset.y = -newInset.top - scrollView.safeAreaInsets.top;
            }
            else {
                contentOffset.y = -newInset.top;
            }
            
            MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithName:@"reveal" contentOffset:contentOffset animated:animated loggingEnabled:DEBUG_LOG_SCROLLS completionHandler:^(BOOL finished)
            {
                if (finished) {
                   update();
                }
            }];
            
            [self performScroll:scroll onScrollView:scrollView];
        }
        else {
            update();
            
            if (@available(iOS 11, *)) {
                // Don't wait first user scroll in order to adjust insets
                [self updateContentInsetForContentOffsetChangeInScrollView:scrollView];
            }
        }
        
        self.revealState = MUKPullToRevealControlStateRevealed;
    }
}

- (void)coverAnimated:(BOOL)animated {
    if (self.revealState == MUKPullToRevealControlStateRevealed) {
        UIScrollView *const scrollView = self.scrollView;
        UIEdgeInsets const newInset = [self coveredInsetsOfScrollView:scrollView];

        self.revealState = MUKPullToRevealControlStateCovered;
        [UIView animateWithDuration:animated ? 0.4 : 0.0 animations:^{
            [self setContentInset:newInset toScrollView:scrollView];
            [self updateFrameInScrollView:scrollView];
            [self updateContentViewFrameInScrollView:scrollView];
        }];
        
        CGFloat const yOffsetAfterRunningScroll = scrollView.contentOffset.y + self.runningScroll.contentOffset.y;
        
        CGFloat scrollThreshold;
        if (@available(iOS 11, *)) {
            scrollThreshold = -scrollView.safeAreaInsets.top;
        }
        else {
            scrollThreshold = -scrollView.contentInset.top;
        }
        
        BOOL const shouldScroll = yOffsetAfterRunningScroll < scrollThreshold;
        if (shouldScroll) {
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y = -newInset.top;
            
            if (@available(iOS 11, *)) {
                contentOffset.y -= scrollView.safeAreaInsets.top;
            }

            MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithName:@"cover" contentOffset:contentOffset animated:animated loggingEnabled:DEBUG_LOG_SCROLLS completionHandler:nil];
            
            if (self.userIsTouchingScrollView) {
                // Postpone
                __weak typeof(self) weakSelf = self;
                __weak __typeof__(scrollView) weakScrollView = scrollView;

                [self addJobAfterUserTouch:^{
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    __strong __typeof__(weakScrollView) strongScrollView = weakScrollView;

                    if (strongSelf.revealState == MUKPullToRevealControlStateCovered)
                    {
                        [strongSelf performScroll:scroll onScrollView:strongScrollView];
                    }
                }];
            }
            else {
                [self performScroll:scroll onScrollView:scrollView];
            }
        } // if shouldScroll
    }
}

#pragma mark - Callbacks

- (void)didChangeRevealStateFromState:(MUKPullToRevealControlState)oldState {
    [self updateContentViewFrameInScrollView:self.scrollView];
}

- (void)didChangePulledHeight:(CGFloat)pulledHeight {
    //
}

#pragma mark - Private

static inline CGFloat PulledHeightInScrollView(UIScrollView *__nonnull scrollView) {
    CGFloat pulledHeight = -scrollView.contentOffset.y;
    
    if (@available(iOS 11, *)) {
        pulledHeight -= scrollView.adjustedContentInset.top;
    }
    else {
        pulledHeight -= scrollView.contentInset.top;
    }
    
    return pulledHeight;
}

static void CommonInit(MUKPullToRevealControl *__nonnull me) {
    me->_revealHeight = 60.0f;
    
    UIView *const contentView = [[UIView alloc] initWithFrame:me.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    contentView.clipsToBounds = YES;
    [me addSubview:contentView];
    me->_contentView = contentView;
    
#if DEBUG_SHOW_BORDERS
    me.layer.borderWidth = 2.0f;
    me.layer.borderColor = [UIColor redColor].CGColor;
    
    contentView.layer.borderWidth = 1.0f;
    contentView.layer.borderColor = [UIColor blueColor].CGColor;
#endif
}

#pragma mark - Private — Observations

- (void)observeScrollViewContentInset:(UIScrollView * _Nonnull)scrollView {
    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(scrollView) weakScrollView = scrollView;
    
    MUKKVOSignal *const signal = [[MUKKVOSignal alloc] initWithObject:scrollView keyPath:NSStringFromSelector(@selector(contentInset))];
    _scrollViewContentInsetObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(MUKKVOSignalChange<NSNumber *> * _Nonnull change)
    {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        __strong __typeof__(weakScrollView) strongScrollView = weakScrollView;
        UIEdgeInsets const newInset = change.value.UIEdgeInsetsValue;
        
#if DEBUG_LOG_CONTENT_INSET
        NSLog(@"New inset = %@", NSStringFromUIEdgeInsets(newInset));
#endif
        
        if (![strongSelf revealStateAffectsContentInset]) {
            // Keep track when not affected by reveal state
            strongSelf.originalContentInset = newInset;
        }
        
        [strongSelf updateFrameInScrollView:strongScrollView];
        [strongSelf updateContentViewFrameInScrollView:strongScrollView];
    }]];
}

- (void)observeScrollViewContentOffset:(UIScrollView * _Nonnull)scrollView {
    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(scrollView) weakScrollView = scrollView;
    
    MUKKVOSignal *const signal = [[MUKKVOSignal alloc] initWithObject:scrollView keyPath:NSStringFromSelector(@selector(contentOffset))];
    _scrollViewContentOffsetObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(MUKKVOSignalChange<NSNumber *> * _Nonnull change)
    {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        __strong __typeof__(weakScrollView) strongScrollView = weakScrollView;
        CGPoint const newOffset = change.value.CGPointValue;
        
        // Resize
        [strongSelf updateFrameInScrollView:strongScrollView];
        [strongSelf updateContentViewFrameInScrollView:strongScrollView];
        
        // Update user is touching
        [strongSelf updateUserIsTouchingScrollView:strongScrollView];
        
        // Manage manual scrolling completion
        if (strongSelf.runningScroll) {
            if (CGPointEqualToPoint(strongSelf.runningScroll.contentOffset, newOffset))
            {
                [strongSelf didCompleteScroll:strongSelf.runningScroll finished:YES];
            }
        }
        
        if ([strongSelf revealStateAffectsContentInset]) {
            // This helps to place table sections headers better
            [strongSelf updateContentInsetForContentOffsetChangeInScrollView:strongScrollView];
        }
        else {
            // Keep track
            strongSelf.originalContentInset = strongScrollView.contentInset;
        }
        
        // Signal pull only with user interaction
        if (strongScrollView.isTracking || strongScrollView.isDragging || strongScrollView.isDecelerating)
        {
            CGFloat const pulledHeight = PulledHeightInScrollView(strongScrollView);
            [strongSelf didChangePulledHeight:pulledHeight inScrollView:strongScrollView];
        }
    }]];
}

- (void)unobserveScrollView:(UIScrollView * _Nonnull)scrollView {
    if ([self.scrollViewContentInsetObservation.signal isObservingObject:scrollView])
    {
        _scrollViewContentInsetObservation = nil;
    }
    
    if ([self.scrollViewContentOffsetObservation.signal isObservingObject:scrollView])
    {
        _scrollViewContentOffsetObservation = nil;
    }
}

#pragma mark - Private — Events

- (void)didChangePulledHeight:(CGFloat)pulledHeight inScrollView:(UIScrollView *__nonnull)scrollView
{
    // Only if user is moving scroll view
    if (scrollView.isDragging && !scrollView.isDecelerating) {
        if (self.revealState == MUKPullToRevealControlStateRevealed) {
            // Do nothing
        }
        else if (pulledHeight < self.revealHeight) {
            if (pulledHeight <= 0.0f) {
#if DEBUG_LOG_USER_STATES
                NSLog(@"Reveal state = Covered");
#endif
                self.revealState = MUKPullToRevealControlStateCovered;
            }
            else {
#if DEBUG_LOG_USER_STATES
                NSLog(@"Reveal state = Pulling");
#endif
                [self setRevealStateOnce:MUKPullToRevealControlStatePulling];
            }
        }
        else if (pulledHeight >= self.revealHeight) {
#if DEBUG_LOG_USER_STATES
            NSLog(@"Reveal state = Pulled");
#endif
            [self setRevealStateOnce:MUKPullToRevealControlStatePulled];
        }
    }
    
    // Inform about pulling height changes when user originated
    BOOL const isPullState = self.revealState == MUKPullToRevealControlStatePulling || self.revealState == MUKPullToRevealControlStatePulled;
    BOOL const scrollViewIsMoving = scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating;
    if (isPullState && scrollViewIsMoving) {
        [self didChangePulledHeight:pulledHeight];
    }
}


#pragma mark - Private — Inset



- (UIEdgeInsets)revealedInsetsOfScrollView:(nonnull UIScrollView *)scrollView
{
    UIEdgeInsets inset;
    
    if (@available(iOS 11, *)) {
        inset = scrollView.safeAreaInsets;
        inset.top = self.revealHeight;
    }
    else {
        inset = self.originalContentInset;
        inset.top += self.revealHeight;
    }
    
    return inset;
}

- (UIEdgeInsets)coveredInsetsOfScrollView:(nonnull UIScrollView *)scrollView
{
    UIEdgeInsets inset;
    
    if (@available(iOS 11, *)) {
        inset = scrollView.safeAreaInsets;
        inset.top = 0.0f;
    }
    else {
        inset = self.originalContentInset;
    }
    
    return inset;
}









#pragma mark - Private - Scroll

- (void)performScroll:(MUKPullToRevealControlScroll *__nonnull)scroll onScrollView:(UIScrollView *__nonnull)scrollView
{
    [self forceRunningScrollCompletion];
    
#if DEBUG_LOG_SCROLLS
    NSLog(@"Performing scroll to y = %f", scroll.contentOffset.y);
#endif
    
    self.runningScroll = scroll;
    [scrollView setContentOffset:scroll.contentOffset animated:scroll.animated];
    
    // Watchdog
    __weak typeof(self) weakSelf = self;
    __weak typeof(scroll) weakScroll = scroll;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        __strong __typeof(weakScroll) strongScroll = weakScroll;
        
        if (strongSelf && strongScroll && [strongScroll isEqual:strongSelf.runningScroll])
        {
#if DEBUG_LOG_SCROLLS
            NSLog(@"Watchdog is cancelling running scroll to y = %f", strongScroll.contentOffset.y);
#endif
            [strongSelf didCompleteScroll:strongScroll finished:NO];
        }
    });
}

- (void)didCompleteScroll:(MUKPullToRevealControlScroll *__nonnull)scroll finished:(BOOL)finished
{
    if ([scroll isEqual:self.runningScroll]) {
        self.runningScroll = nil;
    }
    
    if (scroll.completionHandler) {
        scroll.completionHandler(finished);
    }
    
#if DEBUG_LOG_SCROLLS
    NSLog(@"Completed scroll to y = %f (finished = %@)", scroll.contentOffset.y, finished ? @"Y" : @"N");
#endif
}

- (void)forceRunningScrollCompletion {
    if (self.runningScroll) {
        [self didCompleteScroll:self.runningScroll finished:NO];
    }
}

#pragma mark - Private — User Touch

- (void)updateUserIsTouchingScrollView:(UIScrollView *__nullable)scrollView {
    BOOL const userIsTouchingScrollView = scrollView.isDragging || scrollView.isTracking;
    
    if (userIsTouchingScrollView != self.userIsTouchingScrollView) {
        self.userIsTouchingScrollView = userIsTouchingScrollView;
    }
}

- (void)addJobAfterUserTouch:(dispatch_block_t __nonnull)job {
    if (self.jobAfterUserTouch) {
        dispatch_block_t previousJob = [self.jobAfterUserTouch copy];
        self.jobAfterUserTouch = ^{
            previousJob();
            job();
        };
    }
    else {
        self.jobAfterUserTouch = job;
    }
}

- (void)consumeJobAfterTouch {
    dispatch_block_t const job = [self.jobAfterUserTouch copy];
    self.jobAfterUserTouch = nil;
    job();
}

#pragma mark - Private — Layout

- (CGRect)newFrameInScrollView:(UIScrollView *__nonnull)scrollView {
    return CGRectMake(CGRectGetMinX(scrollView.bounds) + self.positionOffset.horizontal,
                      self.positionOffset.vertical - self.revealHeight,
                      CGRectGetWidth(scrollView.bounds),
                      self.revealHeight);
}

- (void)updateFrameInScrollView:(UIScrollView *__nonnull)scrollView {
    CGRect const newFrame = [self newFrameInScrollView:scrollView];
    if (!CGRectEqualToRect(self.frame, newFrame)) {
        self.frame = newFrame;
        
#if DEBUG_LOG_FRAME
        NSLog(@"New frame: %@", NSStringFromCGRect(newFrame));
#endif
    }
}

- (CGRect)newContentViewFrameInScrollView:(UIScrollView *__nonnull)scrollView {
    CGRect frame = self.bounds;
    CGFloat const pulledHeight = PulledHeightInScrollView(scrollView);
    
    CGFloat const height = ({
        CGFloat h;
        
        switch (self.revealState) {
            case MUKPullToRevealControlStatePulled:
            case MUKPullToRevealControlStateRevealed:
                h = self.revealHeight;
                break;
                
            default:
                h = MIN(CGRectGetHeight(frame), pulledHeight);
                break;
        }
        
        h;
    });
    
    frame.origin.y = CGRectGetHeight(frame) - height;
    frame.size.height = height;
    
    return frame;
}

- (void)updateContentViewFrameInScrollView:(UIScrollView *__nonnull)scrollView {
    CGRect const newFrame = [self newContentViewFrameInScrollView:scrollView];
    if (!CGRectEqualToRect(self.contentView.frame, newFrame)) {
        self.contentView.frame = newFrame;
        
#if DEBUG_LOG_FRAME
        NSLog(@"New content view frame: %@", NSStringFromCGRect(newFrame));
#endif
    }
}

#pragma mark - Private — Reveal State

- (void)setRevealStateOnce:(MUKPullToRevealControlState)newState {
    // One KVO only
    if (newState != self.revealState) {
        self.revealState = newState;
    }
}

@end
