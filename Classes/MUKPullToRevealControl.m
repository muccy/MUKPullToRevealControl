#import "MUKPullToRevealControl.h"
#import <KVOController/FBKVOController.h>

#define DEBUG_SHOW_BORDERS          0
#define DEBUG_LOG_FRAME             0
#define DEBUG_LOG_CONTENT_INSET     0
#define DEBUG_LOG_SCROLLS           0
#define DEBUG_LOG_USER_STATES       0

@interface MUKPullToRevealControlScroll : NSObject
@property (nonatomic, readonly) CGPoint contentOffset;
@property (nonatomic, readonly) BOOL animated;
@property (nonatomic, readonly, copy) void (^completionHandler)(BOOL finished);
@end

@implementation MUKPullToRevealControlScroll

- (instancetype)initWithContentOffset:(CGPoint)contentOffset animated:(BOOL)animated completionHandler:(void (^__nonnull)(BOOL finished))completionHandler
{
    self = [super init];
    if (self) {
        _contentOffset = contentOffset;
        _animated = animated;
        _completionHandler = [completionHandler copy];
    }
    
    return self;
}

@end

#pragma mark -

@interface MUKPullToRevealControl ()
@property (nonatomic, readwrite) MUKPullToRevealControlState revealState;
@property (nonatomic, readwrite) CGFloat contentInsetTopOffset;

@property (nonatomic, readonly, nullable) UIScrollView *scrollView;

@property (nonatomic) BOOL userIsTouchingScrollView;

@property (nonatomic, copy) dispatch_block_t jobAfterUserTouch;
@property (nonatomic) MUKPullToRevealControlScroll *runningScroll;
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
        
        [self updateUserIsTouchingScrollView:scrollView];
        [self observeScrollViewContentInset:scrollView];
        [self observeScrollViewContentOffset:scrollView];
    }
    else if ([self.superview isKindOfClass:[UIScrollView class]]) {
        // Removing
        UIScrollView *const oldScrollView = (UIScrollView *)self.superview;
        [self unobserveScrollView:oldScrollView];
        [self updateUserIsTouchingScrollView:nil];

        UIEdgeInsets const newInset = [self newContentInsetForScrollView:oldScrollView inTransitionFromRevealState:self.revealState toRevealState:MUKPullToRevealControlStateCovered];
        [self setContentInset:newInset toScrollView:oldScrollView];
    }
}

#pragma mark - Accessors

- (UIScrollView * __nullable)scrollView {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)self.superview;
    }
    
    return nil;
}

- (void)setRevealState:(MUKPullToRevealControlState)revealState {
    if (revealState != _revealState) {
        MUKPullToRevealControlState const oldState = _revealState;

        _revealState = revealState;
        
        // React
        [self didChangeRevealStateFromState:oldState];
    }
}

- (void)setUserIsTouchingScrollView:(BOOL)userIsTouchingScrollView {
    if (userIsTouchingScrollView != _userIsTouchingScrollView) {
        _userIsTouchingScrollView = userIsTouchingScrollView;
        
        // React
        if (!userIsTouchingScrollView) {
            [self userFinishedToTouchScrollView];
        }
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
        UIEdgeInsets const newInset = [self newContentInsetForScrollView:scrollView inTransitionFromRevealState:self.revealState toRevealState:MUKPullToRevealControlStateRevealed];

        __weak typeof(self) weakSelf = self;
        void const (^update)(void) = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [self setContentInset:newInset toScrollView:scrollView];
            [strongSelf updateFrameInScrollView:scrollView];
        };
        
        CGRect potentialFrame = self.frame;
        potentialFrame.size.height = self.revealHeight;
        
        BOOL const shouldScroll = CGRectIntersectsRect(potentialFrame, scrollView.bounds);
        if (shouldScroll) {
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y = -newInset.top;
            
            MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithContentOffset:contentOffset animated:animated completionHandler:^(BOOL finished)
            {
                if (finished) {
                    update();
                }
            }];
            
            [self performScroll:scroll onScrollView:scrollView];
        }
        else {
            update();
        }
        
        self.revealState = MUKPullToRevealControlStateRevealed;
    }
}

- (void)coverAnimated:(BOOL)animated {
    if (self.revealState == MUKPullToRevealControlStateRevealed) {
        UIScrollView *const scrollView = self.scrollView;
        UIEdgeInsets const newInset = [self newContentInsetForScrollView:scrollView inTransitionFromRevealState:self.revealState toRevealState:MUKPullToRevealControlStateCovered];
        
        __weak typeof(self) weakSelf = self;
        void const (^update)(void) = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [self setContentInset:newInset toScrollView:scrollView];
            [strongSelf updateFrameInScrollView:scrollView];
        };
        
        BOOL const shouldScroll = CGRectIntersectsRect(self.frame, self.scrollView.bounds);
        if (shouldScroll) {
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y = -newInset.top;
            
            MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithContentOffset:contentOffset animated:animated completionHandler:^(BOOL finished)
            {
                if (finished) {
                    update();
                }
            }];

            if (self.userIsTouchingScrollView) {
                // Postpone
                __weak typeof(self) weakSelf = self;
                [self addJobAfterUserTouch:^{
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf.revealState == MUKPullToRevealControlStateCovered)
                    {
                        [strongSelf performScroll:scroll onScrollView:scrollView];
                    }
                }];
            }
            else {
                [self performScroll:scroll onScrollView:scrollView];
            }
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
    
#if DEBUG_SHOW_BORDERS
    me.layer.borderWidth = 2.0f;
    me.layer.borderColor = [UIColor redColor].CGColor;
#endif
}

#pragma mark - Private — Observations

- (void)observeScrollViewContentInset:(UIScrollView *__nonnull)scrollView {
    [self.KVOControllerNonRetaining observe:scrollView keyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew block:^(MUKPullToRevealControl *observer, UIScrollView *object, NSDictionary *change)
    {
#if DEBUG_LOG_CONTENT_INSET
        NSLog(@"New inset = %@", NSStringFromUIEdgeInsets(object.contentInset));
#endif
        [observer updateFrameInScrollView:object];
    }];
}

- (void)observeScrollViewContentOffset:(UIScrollView *__nonnull)scrollView {
    [self.KVOControllerNonRetaining observe:scrollView keyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew block:^(MUKPullToRevealControl *observer, UIScrollView *object, NSDictionary *change)
    {
        // Resize
        [observer updateFrameInScrollView:scrollView];
        
        // Update user is touching
        [observer updateUserIsTouchingScrollView:object];
        
        // Manage manual scrolling completion
        if (observer.runningScroll) {
            if (CGPointEqualToPoint(observer.runningScroll.contentOffset, scrollView.contentOffset))
            {
                [observer didCompleteScroll:observer.runningScroll finished:YES];
            }
        }
        
        // Signal pull only with user interaction
        if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating)
        {
            CGFloat const pulledHeight = PulledHeightInScrollView(object);
            [observer didChangePulledHeight:pulledHeight inScrollView:object];
        }
    }];
}

- (void)unobserveScrollView:(UIScrollView *__nonnull)scrollView {
    [self.KVOController unobserve:scrollView];
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

- (void)userFinishedToTouchScrollView {
    if (self.revealState == MUKPullToRevealControlStatePulled) {
#if DEBUG_LOG_USER_STATES
        NSLog(@"Reveal state = Revealed");
#endif
        self.revealState = MUKPullToRevealControlStateRevealed;
    
        // Scroll to top
        UIScrollView *const scrollView = self.scrollView;
        UIEdgeInsets const newInset = [self newContentInsetForScrollView:scrollView inTransitionFromRevealState:MUKPullToRevealControlStatePulling toRevealState:MUKPullToRevealControlStateRevealed];
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.y = -newInset.top;
        
        __weak typeof(self) weakSelf = self;
        MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithContentOffset:contentOffset animated:YES completionHandler:^(BOOL finished)
        {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setContentInset:newInset toScrollView:scrollView];
            [strongSelf updateFrameInScrollView:scrollView];
        }];
        
        [self performScroll:scroll onScrollView:scrollView];
        
        // Trigger control state
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    // Consume job postponed after touch
    if (self.jobAfterUserTouch) {
        [self consumeJobAfterTouch];
    }
}

#pragma mark - Private — Inset

- (UIEdgeInsets)newContentInsetForScrollView:(UIScrollView *__nonnull)scrollView inTransitionFromRevealState:(MUKPullToRevealControlState)oldState toRevealState:(MUKPullToRevealControlState)newState
{
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    // Go to natural inset
    contentInset.top -= self.contentInsetTopOffset;
    
    // Go to new inset
    if (newState == MUKPullToRevealControlStateRevealed)
    {
        contentInset.top += self.revealHeight;
    }

    return contentInset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset toScrollView:(UIScrollView *__nonnull)scrollView
{
    CGFloat const offset = contentInset.top - scrollView.contentInset.top;
    scrollView.contentInset = contentInset;
    self.contentInsetTopOffset += offset;
}

#pragma mark - Private - Scroll

- (void)performScroll:(MUKPullToRevealControlScroll *__nonnull)scroll onScrollView:(UIScrollView *__nonnull)scrollView
{
    if (self.runningScroll) {
        [self didCompleteScroll:self.runningScroll finished:NO];
    }
    
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
    
    return CGRectMake(CGRectGetMinX(scrollView.bounds) + self.positionOffset.horizontal, y + self.positionOffset.vertical, CGRectGetWidth(scrollView.bounds), height);
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

#pragma mark - Private — Reveal State

- (void)setRevealStateOnce:(MUKPullToRevealControlState)newState {
    // One KVO only
    if (newState != self.revealState) {
        self.revealState = newState;
    }
}

@end
