#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 State of control
 */
typedef NS_ENUM(NSInteger, MUKPullToRevealControlState) {
    /**
     Control is not revealed (unexpanded)
     */
    MUKPullToRevealControlStateCovered = 0,
    /**
     Control is being pulled by user to be revealed
     */
    MUKPullToRevealControlStatePulling,
    /**
     Control is revealed (expanded)
     */
    MUKPullToRevealControlStateRevealed
};

/**
 A control which when added to a UIScrollView instance places itself at top
 and can be pulled to be revealed.
 When user has revealed the control, the control fires its UIControlEventValueChanged 
 event.
 */
@interface MUKPullToRevealControl : UIControl
/**
 When the control is pulled more than this value the control is revealed.
 Default: 60.0f
 */
@property (nonatomic) CGFloat revealHeight;
/**
 Current reveal state
 */
@property (nonatomic, readonly) MUKPullToRevealControlState revealState;
/**
 Reveal control manually
 */
- (void)revealAnimated:(BOOL)animated;
/**
 Cover control manually
 */
- (void)coverAnimated:(BOOL)animated;
@end

@interface MUKPullToRevealControl (Callbacks)
/**
 Reveal state has changed
 @param oldState Reveal state before transition
 */
- (void)didChangeRevealStateFromState:(MUKPullToRevealControlState)oldState;
/**
 Pulled height has changed
 @param pulledHeight How much user has pulled the scroll view
 */
- (void)didChangePulledHeight:(CGFloat)pulledHeight;
@end

NS_ASSUME_NONNULL_END
