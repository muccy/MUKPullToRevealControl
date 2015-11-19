#import "MUKCirclePullToRefreshControl.h"

@interface MUKCirclePullToRefreshControlCircleView : UIView
@property (nonatomic) float filledFraction;
@end

@implementation MUKCirclePullToRefreshControlCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *const layer = (CAShapeLayer *)self.layer;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 2.0f;
        layer.strokeColor = self.tintColor.CGColor;
        layer.strokeEnd = 0.0f; // because _filledFraction = 0
    }
    
    return self;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    CAShapeLayer *const layer = (CAShapeLayer *)self.layer;
    layer.strokeColor = self.tintColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAShapeLayer *const layer = (CAShapeLayer *)self.layer;
    if (!CGRectEqualToRect(CGPathGetBoundingBox(layer.path), self.bounds)) {
        CGFloat const radius = CGRectGetWidth(self.bounds)/2.0f;
        CGPoint const center = CGPointMake(radius, radius);
        UIBezierPath *const bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI/2.0f endAngle:M_PI*2.0f clockwise:YES];
        layer.path = bezierPath.CGPath;
    }
}

- (void)setFilledFraction:(float)filledFraction {
    if (filledFraction != _filledFraction) {
        _filledFraction = filledFraction;
        
        CAShapeLayer *const layer = (CAShapeLayer *)self.layer;
        layer.strokeEnd = filledFraction;
    }
}

@end

#pragma mark -

@interface MUKCirclePullToRefreshControl ()
@property (nonatomic, weak, nullable) MUKCirclePullToRefreshControlCircleView *circleView;
@property (nonatomic, readwrite, weak, nullable) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation MUKCirclePullToRefreshControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setRevealHeight:(CGFloat)revealHeight {
    [super setRevealHeight:revealHeight];
    [self updateCircleViewLayout];
}

#pragma mark - Overrides

- (void)didChangeRevealStateFromState:(MUKPullToRevealControlState)oldState {
    [super didChangeRevealStateFromState:oldState];
    
    [UIView animateWithDuration:0.2 animations:^{
        switch (self.revealState) {
            case MUKPullToRevealControlStateRevealed: {
                self.circleView.alpha = 0.0f;
                [self.activityIndicatorView startAnimating];
                break;
            }
                
            case MUKPullToRevealControlStatePulled: {
                self.circleView.alpha = 0.0f;
                [self.activityIndicatorView startAnimating];
                break;
            }
                
            case MUKPullToRevealControlStatePulling : {
                self.circleView.alpha = 1.0f;
                [self.activityIndicatorView stopAnimating];
                break;
            }
                
            case MUKPullToRevealControlStateCovered : {
                self.circleView.alpha = 0.0f;
                [self.activityIndicatorView stopAnimating];
                break;
            }
                
            default:
                break;
        }
    }];
}

- (void)didChangePulledHeight:(CGFloat)pulledHeight {
    [super didChangePulledHeight:pulledHeight];
    
    // Do not overlap with contents
    CGFloat const ignoredHeight = 0.37f * self.revealHeight;
    
    float progress;
    if (pulledHeight < ignoredHeight) {
        progress = 0.0f;
    }
    else {
        progress = (pulledHeight - ignoredHeight)/(self.revealHeight - ignoredHeight);
        progress = progress >= 0.0f ? progress : 0.0f;
        progress = progress <= 1.0f ? progress : 1.0f;
    }

    self.circleView.filledFraction = progress;
}

#pragma mark - Private

static void CommonInit(MUKCirclePullToRefreshControl *__nonnull me) {
    me.clipsToBounds = NO;
    [me insertCircleViewIfNeeded];
    [me insertActivityIndicatorViewIfNeededAlignedWithCircleView:me.circleView];
}

#pragma mark - Private — Circle View

- (CGRect)newCircleViewFrame {
    UIEdgeInsets const insets = UIEdgeInsetsMake(13.0f, 0.0f, 27.0f, 0.0f);
    CGFloat const height = self.revealHeight - insets.top - insets.bottom;
    return CGRectMake(roundf(CGRectGetMidX(self.bounds) - height/2.0f), insets.top, height, height);
}

- (void)insertCircleViewIfNeeded {
    if (!self.circleView) {
        // Insert new
        MUKCirclePullToRefreshControlCircleView *const circleView = [[MUKCirclePullToRefreshControlCircleView alloc] initWithFrame:[self newCircleViewFrame]];
        circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:circleView];
        self.circleView = circleView;
    }
}

- (void)updateCircleViewLayout {
    // Update frame
    self.circleView.frame = [self newCircleViewFrame];
}

#pragma mark - Private — Activity Indicator View

- (void)insertActivityIndicatorViewIfNeededAlignedWithCircleView:(MUKCirclePullToRefreshControlCircleView *__nonnull)circleView
{
    if (!self.activityIndicatorView) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        self.activityIndicatorView = view;
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }
}

@end
