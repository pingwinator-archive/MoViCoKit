//
//  MVCTestDelegate.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/12/11.
//  Copyright 2011. All rights reserved.
//

#import "MVCTestDelegate.h"
#import "RootViewController.h"

@interface MVCTestDelegate()

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *rootVC;

@end

@implementation MVCTestDelegate

@synthesize rootVC;
@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.rootVC = [[[RootViewController alloc] init] autorelease];
	[window addSubview:self.rootVC.view];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	self.rootVC = nil;
	[window release];
	[super dealloc];
}
@end
