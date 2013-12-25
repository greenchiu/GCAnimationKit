//
//  GCAnimation.h
//  GCAnimationKit
//
//  Copyright (c) Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCAnimation : NSObject
- (void)animate;
@property (assign, nonatomic) NSTimeInterval delay;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSUInteger options;
@property (copy, nonatomic) void(^animation)(void);
@property (copy, nonatomic) void(^completed)(BOOL finished);
@end


@interface GCAnimation (Additional)
+ (GCAnimation *)animationWithDictionary:(NSDictionary *)inDictonary;
+ (BOOL)animateWithDictionary:(NSDictionary *)inDictonary;

//- (void)setAnimationWithDictionary:(NSDictionary *)inDictionary;
// @{target:, @{frame:,delay:, delay},completed:}
// @{x:duration:delay:completed:}
// @{}
//- (void)addAnimationWithDictionary:(NSDictionary *)inDictionary;
//- (void)addAnimations:(NSArray *)inAnimations;
@end