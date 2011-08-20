    //
//  RootViewController.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/12/11.
//  Copyright 2011. All rights reserved.
//

#import "RootViewController.h"
#import "LinkImage.h"
#import "ImageSearchController.h"
#import "MoViCoKit.h"

@implementation RootViewController

- (void)dealloc {
	[super dealloc];
}

- (id)init {
	self = [super init];
	return self;
}

- (void)closeSearchController {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)switchMVCMode:(UISegmentedControl*)sender {
	switch (sender.selectedSegmentIndex) {
		case 0:
			[MoViCo setMultiThreadingEnable:YES];
			break;
		case 1:
			[MoViCo setMultiThreadingEnable:NO];
			break;
		default:
			break;
	}
}

- (void)showSearchController {
	UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																			  @"MVC in bkg",@"in main",nil]];
	[segments setSelectedSegmentIndex:1];
	segments.segmentedControlStyle = UISegmentedControlStyleBar;
	[segments addTarget:self action:@selector(switchMVCMode:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeSearchController)];
	ImageSearchController *isc = [[ImageSearchController alloc] init];
	isc.navigationItem.leftBarButtonItem = close;
	isc.navigationItem.titleView = segments;
	[segments release];
	[close release];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:isc];
	[isc release];
	[self presentModalViewController:nav animated:YES];
	[nav release];
}

- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchController)];
	NSArray *items = [NSArray arrayWithObjects:search,nil];
	[search release];
	UIToolbar *toolBar = [[UIToolbar alloc] init];
	[toolBar setItems:items];
	[toolBar sizeToFit];
	toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:toolBar];
	[toolBar release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

@end
