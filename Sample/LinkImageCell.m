//
//  LinkImageCell.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/20/11.
//  Copyright 2011. All rights reserved.
//

#import "LinkImageCell.h"
#import "LinkImage.h"

@implementation LinkImageCell

@synthesize linkImage;

- (void)linkImageDidUpdate {
	if (self.linkImage.image == nil) {
		[self.linkImage updateImage];
	} else {
		self.imageView.image = self.linkImage.image;
	}
}

- (void)setLinkImage:(LinkImage *)anImage {
	if (self.linkImage == anImage) {
		return;
	}
	linkImage = anImage;
	[self linkImageDidUpdate];
}

- (void)dealloc {
	linkImage = nil;
}

#pragma mark -
#pragma mark ModelControllerDelegate methods

- (NSArray*)interestedModels {
	NSArray *models = [super interestedModels];
	IF_NOT_NIL_ADD_TO_ARRAY(self.linkImage,&models);
	return models;
}

- (void)modelDidUpdate:(id)aModel {
	/*
     * !!!: When multithreading is enabled we might get Assertion failure in -[LinkImageCell modelDidUpdate:].
	 * That becouse threads are not synchronous for interested models. 
	 * For handle this problem we can just check the model and if we need it we can continue.
	 * Super call just needs for check if model is in interesting models of current controller. If not then will throw Assertion failure.
     */
	[super modelDidUpdate:aModel];
	if (aModel == self.linkImage) {
		[self linkImageDidUpdate];
	}
}

- (void)modelWillUpdate:(id)aModel {
	self.imageView.image = [UIImage imageNamed:@"default.png"];
}

@end
