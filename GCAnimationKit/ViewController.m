//
//  ViewController.m
//  GCAnimationKit
//
//  Created by Green Chiu on 13/12/26.
//  Copyright (c) 2013年 ChiuGreen. All rights reserved.
//

#import "ViewController.h"
#import "GCAnimationQueue.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIView *simpleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
	simpleView.backgroundColor = [UIColor redColor];
	[self.view addSubview:simpleView];
    
	GCAnimationQueue *queue = [[GCAnimationQueue alloc] init];
    [queue addAnimations:@[@{ @"duration":@(0.4), @"animation":^{
		simpleView.frame = CGRectMake(100.0, 0.0, 100.0, 100.0);
		simpleView.backgroundColor = [UIColor lightGrayColor];
	}, @"completed":^(BOOL finished){
		NSLog(@"animation1 completed");
	}}, @{ @"duration":@(0.8), @"animation":^{
		self.view.backgroundColor = [UIColor redColor]; },
		   @"completed":^(BOOL finished){
        NSLog(@"animation2 completed");
    }}],@{ @"duration":@(0.6), @"animation":^{
        simpleView.frame = CGRectMake(100.0, 100.0, 50.0, 50.0);
        simpleView.backgroundColor = [UIColor yellowColor];
    }, @"completed":^(BOOL finished){
        NSLog(@"animation3 completed");
    }}, nil];
    queue.finishedAllAnimations = ^{
        [simpleView removeFromSuperview];
    };
	[queue execute];
}


@end
