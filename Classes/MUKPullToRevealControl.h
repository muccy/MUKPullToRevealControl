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
     Control has been pulled by user who has not lifted his finger to reveal it
     */
    MUKPullToRevealControlStatePulled,
    /**
     Control is revealed (expanded) and user has lift his finger
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
 How much control is shifted from top-center position.
 Default: UIOffsetZero
 */
@property (nonatomic) UIOffset positionOffset;
/**
 How much this view is shifting scroll view offset
 */
@property (nonatomic, readonly) CGFloat contentInsetTopOffset;
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
