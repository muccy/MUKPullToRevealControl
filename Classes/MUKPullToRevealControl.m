#import "MUKPullToRevealControl.h"
#import "MUKPullToRevealControlInsertion.h"
#import "MUKPullToRevealControlRemoval.h"
#import "MUKPullToRevealControlRevealTransition.h"
#import "MUKPullToRevealControlCoverTransition.h"

#define DEBUG_SHOW_BORDERS          0
#define DEBUG_LOG_USER_STATES       0

@interface MUKPullToRevealControl () <MUKPullToRevealControlLayouterDelegate, MUKPullToRevealControlRevealTransitionDelegate, MUKPullToRevealControlCoverTransitionDelegate>
@property (nonatomic, readwrite) MUKPullToRevealControlState revealState;
@property (nonatomic, copy) dispatch_block_t jobAfterUserTouch;
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
    if ([MUKPullToRevealControlRevealTransition isValidFromState:self.revealState])
    {
        MUKPullToRevealControlRevealTransition *const transition = [[MUKPullToRevealControlRevealTransition alloc] initWithLayouter:self.layouter animated:animated];
        transition.delegate = self;
        [transition start];
    }
}

- (void)coverAnimated:(BOOL)animated {
    MUKPullToRevealControlCoverTransition *const transition = [[MUKPullToRevealControlCoverTransition alloc] initWithLayouter:self.layouter control:self animated:animated];
    if (transition.canStart) {
        transition.delegate = self;
        [transition start];
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

#pragma mark - <MUKPullToRevealControlRevealTransitionDelegate>

- (void)revealTransitionIsReadyToChangeControlState:(MUKPullToRevealControlRevealTransition *)transition
{
    self.revealState = MUKPullToRevealControlStateRevealed;
}

#pragma mark - <MUKPullToRevealControlCoverTransitionDelegate>

- (void)coverTransitionIsReadyToChangeControlState:(MUKPullToRevealControlCoverTransition *)transition
{
    self.revealState = MUKPullToRevealControlStateCovered;
}

- (void)coverTransition:(MUKPullToRevealControlCoverTransition *)transition needsToPostponeAfterUserTouchJob:(dispatch_block_t)job
{
    [self addJobAfterUserTouch:job];
}

@end
