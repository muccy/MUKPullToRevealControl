#import "MUKPullToRevealControl.h"
#import "MUKPullToRevealControlScroll.h"
#import "MUKPullToRevealControlInsertion.h"
#import "MUKPullToRevealControlRemoval.h"

#define DEBUG_SHOW_BORDERS          0
#define DEBUG_LOG_USER_STATES       0

@interface MUKPullToRevealControl () <MUKPullToRevealControlLayouterDelegate>
@property (nonatomic, readwrite) MUKPullToRevealControlState revealState;


@property (nonatomic) NSValue *trackedContentInset, *trackedContentOffset;

@property (nonatomic, copy) dispatch_block_t jobAfterUserTouch;
@property (nonatomic) MUKPullToRevealControlScroll *runningScroll;

@property (nonatomic, nullable) MUKPullToRevealControlLayouter *layouter;
@end

@implementation MUKPullToRevealControl
@dynamic originalTopInset, ignoresOriginalTopInset;

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
        self.layouter.delegate = self;
        [self.layouter start];
    }
    else {
        MUKPullToRevealControlRemoval *const removal = [[MUKPullToRevealControlRemoval alloc] initWithSuperview:newSuperview layouter:self.layouter];
        if (removal.canStart) {
            [removal start];
            self.layouter = nil;
        }
    }
}

#pragma mark - Accessors

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
    self.layouter.frameLayouter.offset = positionOffset;
}

#pragma mark - Methods

- (void)revealAnimated:(BOOL)animated {
    if (self.revealState != MUKPullToRevealControlStateRevealed) {
        // TODO: transition
        
        self.revealState = MUKPullToRevealControlStateRevealed;
    }
}

- (void)coverAnimated:(BOOL)animated {
    if (self.revealState == MUKPullToRevealControlStateRevealed) {
        // TODO: transition
    }
}

#pragma mark - Callbacks

- (void)didChangeRevealStateFromState:(MUKPullToRevealControlState)oldState {
    [self.layouter.frameLayouter updateContentViewFrame];
}

- (void)didChangePulledHeight:(CGFloat)pulledHeight {
    //
}

#pragma mark - Private

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

#pragma mark - Private — Reveal State

- (void)setRevealStateOnce:(MUKPullToRevealControlState)newState {
    // One KVO only
    if (newState != self.revealState) {
        self.revealState = newState;
    }
}

#pragma mark - <MUKPullToRevealControlLayouterDelegate>

- (void)layouter:(MUKPullToRevealControlLayouter *)layouter didChangePulledHeight:(CGFloat)pulledHeight
{
    UIScrollView *const scrollView = layouter.scrollView;
    
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

- (void)layouter:(MUKPullToRevealControlLayouter *)layouter didRecognizeUserTouchLeadingToState:(MUKPullToRevealControlState)state
{
    self.revealState = state;
}

- (void)layouterNeedsToSendControlActions:(MUKPullToRevealControlLayouter *)layouter
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)layouterDidConsumeUserTouch:(MUKPullToRevealControlLayouter *)layouter
{
    // Consume job postponed after touch
    if (self.jobAfterUserTouch) {
        [self consumeJobAfterTouch];
    }
}

@end
