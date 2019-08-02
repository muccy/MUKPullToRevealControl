//
//  MUKPullToRevealControlScroll.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlScroll : NSObject
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) CGPoint contentOffset;
@property (nonatomic, readonly) BOOL animated, loggingEnabled;
@property (nonatomic, readonly, nullable, copy) void (^completionHandler)(BOOL finished);

- (instancetype)initWithName:(NSString *)name contentOffset:(CGPoint)contentOffset animated:(BOOL)animated loggingEnabled:(BOOL)loggingEnabled completionHandler:(void (^_Nullable)(BOOL finished))completionHandler NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)performOnScrollView:(nonnull UIScrollView *)scrollView;
@end

NS_ASSUME_NONNULL_END
