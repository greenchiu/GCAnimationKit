//
//  GCAnimationQueue.h
//  GCAnimationKit
//
//  Copyright (c) Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCAnimationQueue : NSObject
- (void)addAnimateWithDuration:(NSTimeInterval)inDuration animation:(void(^)(void))inAnimation complete:(void(^)(BOOL finished))completed;
- (void)addAnimationWithDictionary:(NSDictionary *)inAnimationDictionary;
- (void)addConcurrentAnimationsWithArray:(NSArray *)inArray;
- (void)addAnimations:(id)animations, ... NS_REQUIRES_NIL_TERMINATION;
- (void)execute;

@property (copy, nonatomic) void(^finishedAllAnimations)(void);
// TODO: implement autoReleaseAfterFibishedAnimations action.
@property (assign, nonatomic) BOOL autoReleaseAfterFibishedAnimations;
@property (readonly) BOOL isRunning;
@property (readonly) BOOL isCancel;
@property (readonly) BOOL isCompleted;
@end
