//
//  FlickrPhoto.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import "FlickrPhoto.h"

@interface FlickrPhoto()

@property (nonatomic, retain) NSString *farm;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *server;

@end


@implementation FlickrPhoto

@synthesize farm, imageId, secret, server, title;

- (void)dealloc {
	self.farm = nil;
	self.imageId = nil;
	self.secret = nil;
	self.server = nil;
	self.title = nil;
	[super dealloc];
}

+ (FlickrPhoto*)photoWithDictioary:(NSDictionary*)photoDictionary {
	FlickrPhoto *ret = [[FlickrPhoto alloc] init];
	ret.farm = [photoDictionary objectForKey:@"farm"];
	ret.imageId = [photoDictionary objectForKey:@"id"];
	ret.secret = [photoDictionary objectForKey:@"secret"];
	ret.server = [photoDictionary objectForKey:@"server"];
	ret.title = [photoDictionary objectForKey:@"title"];
	return [ret autorelease];
}

- (NSURL*)urlForSize:(NSString*)size {
	NSString *ext = @"jpg";
	NSString *res = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_%@.%@",self.farm, self.server, self.imageId, self.secret, size, ext];
	return [NSURL URLWithString:res];
}

- (NSURL*)smallImageURl {
	return [self urlForSize:@"m"];
}

@end
