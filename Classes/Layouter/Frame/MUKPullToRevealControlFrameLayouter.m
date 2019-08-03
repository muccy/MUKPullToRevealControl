//
//  MUKPullToRevealControlFrameLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlFrameLayouter.h"

@implementation MUKPullToRevealControlFrameLayouter

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setOffset:(UIOffset)offset {
    if (!UIOffsetEqualToOffset(offset, _offset)) {
        _offset = offset;
        [self updateFrame];
    }
}

#pragma mark - Methods

- (void)start {
    [self updateFrame];
    [self updateContentViewFrame];
}

- (void)stop {
    
}

- (void)updateFrame {
    CGRect const newFrame = [self newFrame];
    if (!CGRectEqualToRect(self.control.frame, newFrame)) {
        self.control.frame = newFrame;
        
        if (self.loggingEnabled) {
            NSLog(@"New frame: %@", NSStringFromCGRect(newFrame));
        }
    }
}

- (void)updateContentViewFrame {
    CGRect const newFrame = [self newContentViewFrame];
    if (!CGRectEqualToRect(self.control.contentView.frame, newFrame)) {
        self.control.contentView.frame = newFrame;
        
        if (self.loggingEnabled) {
            NSLog(@"New content view frame: %@", NSStringFromCGRect(newFrame));
        }
    }
}

#pragma mark - Private

- (CGRect)newFrame {
    CGFloat const x = CGRectGetMinX(self.scrollView.bounds) + self.offset.horizontal;
    CGFloat const y = self.offset.vertical - self.control.revealHeight;
    CGFloat const w = CGRectGetWidth(self.scrollView.bounds);
    CGFloat const h = self.control.revealHeight;
    return CGRectMake(x, y, w, h);
}

- (CGRect)newContentViewFrame {
    CGRect frame = self.control.bounds;
    
    CGFloat const height = ({
        CGFloat h;
        
        switch (self.control.revealState) {
            case MUKPullToRevealControlStatePulled:
            case MUKPullToRevealControlStateRevealed:
                h = self.control.revealHeight;
                break;
                
            default: {
                CGFloat const pulledHeight = [self.delegate scrollViewPulledHeightForFrameLayouter:self];
                h = MIN(CGRectGetHeight(frame), pulledHeight);
                break;
            }
        }
        
        h;
    });
    
    frame.origin.y = CGRectGetHeight(frame) - height;
    frame.size.height = height;
    
    return frame;
}

@end
