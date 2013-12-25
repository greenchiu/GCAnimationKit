//
//  GCAnimation.m
//  GCAnimationKit
//
//  Copyright (c) Green. All rights reserved.
//

#import "GCAnimation.h"

@interface GCAnimation ()
{
	BOOL isCompleted;
	BOOL isRunning;
}
@end

@implementation GCAnimation

- (void)dealloc
{
	[self clear];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.delay = 0.0;
		self.duration = 0.25;
		self.options = 0;
	}
	return self;
}

#pragma mark - Public Methods
- (void)animate
{
	if (isCompleted || isRunning || !self.animation) {
		return;
	}

	isRunning = YES;
	[UIView animateKeyframesWithDuration:self.duration delay:self.delay options:self.options animations:self.animation completion:^(BOOL finished) {
		if (self.completed) {
			self.completed(finished);
			self.completed = nil;
		}
		self.animation = nil;
		isRunning = NO;
		isCompleted = YES;
	}];
}

#pragma mark - Protected Methods
- (void)clear
{
	self.completed = nil;
	self.animation = nil;
}

@end

#import <objc/runtime.h>
@implementation GCAnimation (Additional)

+ (GCAnimation *)animationWithDictionary:(NSDictionary *)inDictonary
{
	NSArray *allKeys = [inDictonary allKeys];
	GCAnimation *animator = [[GCAnimation alloc] init];
	for (NSString* key in allKeys) {
		if ([[self animationProperties] indexOfObject:key] != NSNotFound) {
			[animator setValue:inDictonary[key] forKey:key];
		}
	}
	if (!animator.animation) {
		animator = nil;
		NSLog(@"the dictionary is invalid for animation.");
	}
	return animator;
}

+ (BOOL)animateWithDictionary:(NSDictionary *)inDictonary
{
	GCAnimation *animator = [self animationWithDictionary:inDictonary];
	if (animator) {
		[animator animate];
		return YES;
	}
	return NO;
}

+ (NSArray *)animationProperties
{
	static NSArray *animateProperties = nil;
	if (!animateProperties) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSMutableArray *mutableArray = [NSMutableArray array];
			unsigned int outCount, i;
			objc_property_t *properties = class_copyPropertyList([GCAnimation class], &outCount);
			for(i = 0; i < outCount; i++) {
				objc_property_t property = properties[i];
				const char *propName = property_getName(property);
				if(propName) {
					NSString *propertyName = [NSString stringWithCString:propName
																encoding:[NSString defaultCStringEncoding]];
					[mutableArray addObject:propertyName];
				}
			}
			free(properties);
			animateProperties = [[NSArray alloc] initWithArray:mutableArray];
		});
	}
	return animateProperties;
}

@end
