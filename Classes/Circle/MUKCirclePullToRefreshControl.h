#import "MUKPullToRevealControl.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A refresh control which displays a circle which fills itself during while pulling.
 When the control is revealed a spinner appears.
 */
@interface MUKCirclePullToRefreshControl : MUKPullToRevealControl
/**
 Spinner
 */
@property (nonatomic, readonly, weak, nullable) UIActivityIndicatorView *activityIndicatorView;
@end

NS_ASSUME_NONNULL_END
