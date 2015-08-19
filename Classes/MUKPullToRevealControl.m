#import "MUKPullToRevealControl.h"
#import <KVOController/FBKVOController.h>

#define DEBUG_SHOW_BORDERS  0
#define DEBUG_LOG_FRAME     0

@interface MUKPullToRevealControl ()
@property (nonatomic, readwrite) MUKPullToRevealControlState revealState;

@property (nonatomic, readonly, nullable) UIScrollView *scrollView;
@property (nonatomic) BOOL needsScrollToTopToReveal;
@property (nonatomic) CGFloat contentInsetTopOffset;

@property (nonatomic, getter=isManuallyScrolling) BOOL manuallyScrolling;
@property (nonatomic) CGPoint manualScrollTarget;
@property (nonatomic, copy, nullable) void (^manualScrollCompletionHandler)(BOOL finished);
@end

@implementation MUKPullToRevealControl
@dynamic scrollView;

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
    
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        // Adding
        UIScrollView *const scrollView = (UIScrollView *)newSuperview;
        [self updateFrameInScrollView:scrollView];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self observeScrollViewContentInset:scrollView];
        [self observeScrollViewContentOffset:scrollView];
    }
    else if ([self.superview isKindOfClass:[UIScrollView class]]) {
        // Removing
        UIScrollView *const oldScrollView = (UIScrollView *)self.superview;
        [self unobserveScrollView:oldScrollView];
        [self updateContentInsetOfScrollView:oldScrollView topOffset:-self.contentInsetTopOffset];
    }
}

#pragma mark - Accessors

- (UIScrollView * __nullable)scrollView {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)self.superview;
    }
    
    return nil;
}

#pragma mark - Methods

- (void)revealAnimated:(BOOL)animated {
    if (self.revealState != MUKPullToRevealControlStateRevealed) {
        CGFloat const offset = self.revealHeight;
        
        void const (^update)(void) = ^{
            [self updateContentInsetOfScrollView:self.scrollView topOffset:offset];
            [self updateFrameInScrollView:self.scrollView];
        };
        
        CGRect potentialFrame = self.frame;
        potentialFrame.size.height = self.revealHeight;
        
        BOOL const shouldScroll = CGRectIntersectsRect(potentialFrame, self.scrollView.bounds);
        if (shouldScroll) {
            CGFloat const newY = self.scrollView.contentOffset.y - offset;
            [self manualScrollToY:newY scrollView:self.scrollView animated:animated completion:^(BOOL finished)
             {
                 update();
             }];
        }
        else {
            update();
        }
        
        self.revealState = MUKPullToRevealControlStateRevealed;
    }
}

- (void)coverAnimated:(BOOL)animated {
    if (self.revealState == MUKPullToRevealControlStateRevealed) {
        CGFloat const offset = -self.revealHeight;
        
        void const (^update)(void) = ^{
            [self updateContentInsetOfScrollView:self.scrollView topOffset:offset];
            [self updateFrameInScrollView:self.scrollView];
        };
        
        BOOL const shouldScroll = CGRectIntersectsRect(self.frame, self.scrollView.bounds);
        if (shouldScroll) {
            CGFloat const newY = self.scrollView.contentOffset.y - offset;
            [self manualScrollToY:newY scrollView:self.scrollView animated:animated completion:^(BOOL finished)
            {
                update();
            }];
        }
        else {
            update();
        }
        
        self.revealState = MUKPullToRevealControlStateCovered;
    }
}

#pragma mark - Callbacks

- (void)didChangeRevealStateFromState:(MUKPullToRevealControlState)oldState {
    //
}

- (void)didChangePulledHeight:(CGFloat)pulledHeight {
    //
}

#pragma mark - Private

static inline CGFloat PulledHeightInScrollView(UIScrollView *__nonnull scrollView) {
    return -scrollView.contentOffset.y - scrollView.contentInset.top;
}

static void CommonInit(MUKPullToRevealControl *__nonnull me) {
    me->_revealHeight = 60.0f;
    [me observeRevealState];
    
#if DEBUG_SHOW_BORDERS
    me.layer.borderWidth = 2.0f;
    me.layer.borderColor = [UIColor redColor].CGColor;
#endif
}

#pragma mark - Private — Observations

- (void)observeScrollViewContentInset:(UIScrollView *__nonnull)scrollView {
    [self.KVOController observe:scrollView keyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew block:^(MUKPullToRevealControl *observer, UIScrollView *object, NSDictionary *change)
    {
        [observer updateFrameInScrollView:object];
    }];
}

- (void)observeScrollViewContentOffset:(UIScrollView *__nonnull)scrollView {
    [self.KVOController observe:scrollView keyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew block:^(MUKPullToRevealControl *observer, UIScrollView *object, NSDictionary *change)
    {
        CGFloat const pulledHeight = PulledHeightInScrollView(object);
        [observer didChangePulledHeight:pulledHeight inScrollView:object];
    }];
}

- (void)unobserveScrollView:(UIScrollView *__nonnull)scrollView {
    [self.KVOController unobserve:scrollView];
}

- (void)observeRevealState {
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(revealState)) options:NSKeyValueObservingOptionNew block:^(MUKPullToRevealControl *observer, MUKPullToRevealControl *object, NSDictionary *change)
    {
        MUKPullToRevealControlState const oldState = [change[NSKeyValueChangeNewKey] integerValue];
        [observer didChangeRevealStateFromState:oldState];
    }];
}

#pragma mark - Private — Events

- (void)didChangePulledHeight:(CGFloat)pulledHeight inScrollView:(UIScrollView *__nonnull)scrollView
{
    // Resize
    [self updateFrameInScrollView:scrollView];
    
    // Manage manual scrolling completion
    if (self.isManuallyScrolling) {
        if (CGPointEqualToPoint(self.manualScrollTarget, scrollView.contentOffset)) {
            [self didFinishManualScroll];
        }
        
        return;
    }
    
    // No user interaction
    if (!scrollView.isTracking && !scrollView.isDragging) {
        // Start scroll to top
        if (self.needsScrollToTopToReveal) {
            if (self.revealState == MUKPullToRevealControlStateRevealed) {
                self.needsScrollToTopToReveal = NO;
                
                CGFloat const offset = self.revealHeight;
                CGFloat const targetY = -scrollView.contentInset.top - offset;
                
                [self manualScrollToY:targetY scrollView:scrollView animated:YES completion:^(BOOL finished)
                {
                    [self updateContentInsetOfScrollView:scrollView topOffset:offset];
                    [self updateFrameInScrollView:scrollView];
                }];
            } // if
        } // if
    }

    // Change state only if user is moving scroll view
    if (scrollView.isDragging && !scrollView.isDecelerating) {
        if (self.revealState == MUKPullToRevealControlStateRevealed) {
            // Do nothing
        }
        else if (pulledHeight < self.revealHeight) {
            if (pulledHeight <= 0.0f) {
                self.revealState = MUKPullToRevealControlStateCovered;
            }
            else {
                self.revealState = MUKPullToRevealControlStatePulling;
            }
        }
        else {
            self.revealState = MUKPullToRevealControlStateRevealed;
            self.needsScrollToTopToReveal = YES; // When user lifts his finger
            
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    
    // Inform about pulling height changes when user originated
    if (self.revealState == MUKPullToRevealControlStatePulling &&
        (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating))
    {
        [self didChangePulledHeight:pulledHeight];
    }
}

#pragma mark - Private — Inset

- (void)updateContentInsetOfScrollView:(UIScrollView *__nonnull)scrollView topOffset:(CGFloat)offset
{
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top += offset;
    scrollView.contentInset = inset;
    self.contentInsetTopOffset += offset;
}

#pragma mark - Private - Scroll

- (void)manualScrollToY:(CGFloat)y scrollView:(UIScrollView *__nonnull)scrollView animated:(BOOL)animated completion:(void (^__nullable)(BOOL))completionHandler
{
    if (self.isManuallyScrolling) {
        return;
    }
    
    self.manuallyScrolling = YES;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = y;
    
    self.manualScrollTarget = contentOffset;
    self.manualScrollCompletionHandler = completionHandler;
    [scrollView setContentOffset:contentOffset animated:animated];
    
    // Watchdog (manual scroll could be interrupted)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.manualScrollCompletionHandler) {
            [self didInterruptManualScroll];
        }
    });
}

- (void)didFinishManualScroll {
    self.manuallyScrolling = NO;
    
    if (self.manualScrollCompletionHandler) {
        self.manualScrollCompletionHandler(YES);
        self.manualScrollCompletionHandler = nil;
    }
}

- (void)didInterruptManualScroll {
    self.manuallyScrolling = NO;
    
    if (self.manualScrollCompletionHandler) {
        self.manualScrollCompletionHandler(NO);
        self.manualScrollCompletionHandler = nil;
    }
}

#pragma mark - Private — Layout

- (CGRect)newFrameInScrollView:(UIScrollView *__nonnull)scrollView {
    CGFloat const pulledHeight = PulledHeightInScrollView(scrollView);
    
    CGFloat height;
    if (self.revealState == MUKPullToRevealControlStateRevealed) {
        height = pulledHeight > self.revealHeight - self.contentInsetTopOffset ? pulledHeight + self.contentInsetTopOffset : self.revealHeight;
    }
    else {
        height = pulledHeight > 0.0f ? pulledHeight : 0.0f;
    }
    
    CGFloat y;
    if (pulledHeight > 0.0f) {
        y = -pulledHeight - self.contentInsetTopOffset;
    }
    else {
        y = -self.contentInsetTopOffset;
    }
    
    return CGRectMake(CGRectGetMinX(scrollView.bounds), y, CGRectGetWidth(scrollView.bounds), height);
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

@end
