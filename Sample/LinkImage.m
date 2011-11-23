//
//  LinkImage.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/12/11.
//  Copyright 2011. All rights reserved.
//

#import "LinkImage.h"
#import "MoViCoKit.h"
#import "UIImage+Resize.h"

@interface LinkImage()

@property (nonatomic, strong) NSURL *link;

@end

@implementation LinkImage

@synthesize link;
@synthesize image;


- (void)updateImage {
	[MoViCo beginUpdatesForModel:self];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
		NSData *data = [NSData dataWithContentsOfURL:self.link];
		self.image = [[UIImage imageWithData:data] resizedImage:CGSizeMake(44,44) interpolationQuality:kCGInterpolationHigh];
		[MoViCo updateControllersForModel:self];
	});
}

+ (LinkImage*)imageWithLink:(NSURL *)link {
	LinkImage *ret = [[LinkImage alloc] init];
	ret.link = link;
	return ret;
}

@end
