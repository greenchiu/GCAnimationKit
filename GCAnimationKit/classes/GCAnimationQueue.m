//
//  GCAnimationQueue.m
//  GCAnimationKit
//
//  Copyright (c) Green. All rights reserved.
//

#import "GCAnimationQueue.h"
#import "GCAnimation.h"

@implementation GCAnimationQueue
{
	NSMutableArray *animationStorage;
	BOOL isRunning;
	BOOL isCompleted;
	BOOL isCancel;
	NSInteger waitCount;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		animationStorage = [[NSMutableArray alloc] initWithCapacity:0];
		isRunning = NO;
	}
	return self;
}

- (void)addAnimateWithDuration:(NSTimeInterval)inDuration animation:(void (^)(void))inAnimation complete:(void (^)(BOOL))completed
{
	if (isRunning) {
		return;
	}
	NSAssert(inDuration, @"There is no animation duration.");
	NSAssert(inAnimation, @"There is no animation.");
	GCAnimation *animator = [[GCAnimation alloc] init];
	animator.duration = inDuration;
	animator.animation = inAnimation;
	animator.completed = completed;
	[animationStorage addObject:animator];
}

- (void)addAnimationWithDictionary:(NSDictionary *)inAnimationDictionary
{
	if (isRunning) {
		return;
	}
	if (inAnimationDictionary[@"animation"]) {
		GCAnimation *animator = [GCAnimation animationWithDictionary:inAnimationDictionary];
		if (animator) {
			[animationStorage addObject:animator];
		}
	}
}

- (void)addConcurrentAnimationsWithArray:(NSArray *)inArray
{
	if (isRunning) {
		return;
	}
	NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[inArray count]];
	for (id anim in inArray) {
		if ([anim isKindOfClass:[NSDictionary class]]) {
			GCAnimation *animator = [GCAnimation animationWithDictionary:anim];
			if (animator) {
				[tempArray addObject:animator];
			}
		}
		else if ([anim isKindOfClass:[GCAnimation class]]) {
			[tempArray addObject:anim];
		}
	}

	if ([tempArray count]) {
		[animationStorage addObject:tempArray];
	}
}

- (void)addAnimations:(id)animations, ...
{
	if (isRunning) {
		return;
	}
	va_list args;
    va_start(args, animations);
	NSMutableArray *tempAnimationStorage = [NSMutableArray array];
	for (id arg = animations; arg != nil; arg = va_arg(args, id))
    {
		if ([arg isKindOfClass:[NSDictionary class]]) {
			GCAnimation *animator = [GCAnimation animationWithDictionary:arg];
			if (animator) {
				[tempAnimationStorage addObject:animator];
			}
		}
		else if ([arg isKindOfClass:[GCAnimation class]]) {
			[tempAnimationStorage addObject:arg];
		}
		else if ([arg isKindOfClass:[NSArray class]]) {
			NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[arg count]];
			for (id anim in arg) {
				if ([anim isKindOfClass:[NSDictionary class]]) {
					GCAnimation *animator = [GCAnimation animationWithDictionary:anim];
					if (animator) {
						[tempArray addObject:animator];
					}
				}
				else if ([anim isKindOfClass:[GCAnimation class]]) {
					[tempArray addObject:anim];
				}
			}
			if ([tempArray count]) {
				if ([tempArray count] == 1) {
					[tempAnimationStorage addObject:[tempArray lastObject]];
				}
				else {
					[tempAnimationStorage addObject:tempArray];
				}
			}
			tempArray = nil;
		}
    }
    va_end(args);
	[animationStorage addObjectsFromArray:tempAnimationStorage];
}

- (void)execute
{
	if (isRunning || isCancel || isCompleted) {
		return;
	}

	isRunning = YES;
	[self _nextInvocation];
}

#pragma mark -

- (void)_nextInvocation
{
	if ([animationStorage count] && !isCancel) {
		if ([[animationStorage firstObject] isKindOfClass:[GCAnimation class]]) {
			GCAnimation *animator = [animationStorage firstObject];
			__block void (^completed)(BOOL) = [animator.completed copy];
			animator.completed = ^(BOOL finished) {
				if (completed) {
					completed(finished);
					completed = nil;
				}
				[self _nextInvocation];
			};
			[animator animate];
		}
		else {
			NSArray *concurrentAnimations = [animationStorage firstObject];
			waitCount = [concurrentAnimations count];
			for (GCAnimation *animator in concurrentAnimations) {
				__block void (^completed)(BOOL) = [animator.completed copy];
				animator.completed = ^(BOOL finished) {
					if (completed) {
						completed(finished);
						completed = nil;
					}
					[self _waitConcurrentAnimationCompleted];
				};
				[animator animate];
			}
		}
		[animationStorage removeObjectAtIndex:0];
	}
	else {
		isRunning = NO;
		isCompleted = YES;
		[animationStorage removeAllObjects];
		if (self.finishedAllAnimations) {
			self.finishedAllAnimations();
			self.finishedAllAnimations = nil;
		}
	}
}

- (void)_waitConcurrentAnimationCompleted
{
	static NSInteger completedCount = 0;
	completedCount++;
	if (completedCount == waitCount) {
		completedCount = 0;
		[self _nextInvocation];
	}
}

@synthesize isRunning;
@synthesize isCancel;
@synthesize isCompleted;
@end
