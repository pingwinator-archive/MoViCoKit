//
//  FlickrPhoto.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import "FlickrPhoto.h"

@interface FlickrPhoto()

@property (nonatomic, strong) NSString *farm;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *server;

@end


@implementation FlickrPhoto

@synthesize farm, imageId, secret, server, title;


+ (FlickrPhoto*)photoWithDictioary:(NSDictionary*)photoDictionary {
	FlickrPhoto *ret = [[FlickrPhoto alloc] init];
	ret.farm = [photoDictionary objectForKey:@"farm"];
	ret.imageId = [photoDictionary objectForKey:@"id"];
	ret.secret = [photoDictionary objectForKey:@"secret"];
	ret.server = [photoDictionary objectForKey:@"server"];
	ret.title = [photoDictionary objectForKey:@"title"];
	return ret;
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
