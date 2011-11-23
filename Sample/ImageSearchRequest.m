//
//  ImageSearchRequest.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import "ImageSearchRequest.h"
#import "MoViCoKit.h"
#import "JSON.h"
#import "FlickrPhoto.h"

#define SEARCH_URL_FORMAT @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9d3ea1e79bf9a7a4172511221b3d0c4f&per_page=%i&page=0&text=%@&format=json&nojsoncallback=1"

@interface ImageSearchRequest()

@property (nonatomic, retain) NSOperationQueue *opQueue;

@end

@implementation ImageSearchRequest

@synthesize opQueue;
@synthesize onSearchDone;
@synthesize onSearchFail;
@synthesize results,searchText;

- (void)dealloc {
	[self.opQueue cancelAllOperations];
	self.opQueue = nil;
	self.onSearchDone = nil;
	self.onSearchFail = nil;
	self.results = nil;
	self.searchText = nil;
	[super dealloc];
}

- (id)init {
	self = [super init];
	self.results = [NSArray array];
	self.opQueue = [[[NSOperationQueue alloc] init] autorelease];
	[self.opQueue setMaxConcurrentOperationCount:1];
	return self;
}

- (void)searchWithLimit:(int)limit {
	[MoViCo beginUpdatesForModel:self];
	[self.opQueue cancelAllOperations];
	if ([self.searchText length] == 0) {
		self.results = [NSArray array];
		[MoViCo updateControllersForModel:self];
		return;
	}
	[self.opQueue addOperationWithBlock:^ {
		NSString *fullUrl = [NSString stringWithFormat:SEARCH_URL_FORMAT,limit,self.searchText];
		NSURL *url = [NSURL URLWithString:[fullUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSError *error = nil;
		NSLog(@"%@",url);
		NSString *responseJSON = [NSString stringWithContentsOfURL:url
														  encoding:NSUTF8StringEncoding
															 error:&error];
		id resopnse = nil;
		if (error == nil && [responseJSON length] > 0) {
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			resopnse = [parser objectWithString:responseJSON error:&error];
			[parser release];
		}
		
		if (error == nil && resopnse != nil) {
			NSInteger count = [[[resopnse objectForKey:@"photos"] objectForKey:@"photo"] count];
			NSArray *flickrImages = nil;
			if (count > 0) {
				NSLog(@"get %i images",count);
				NSDictionary *requestResults = [resopnse objectForKey:@"photos"];
				if (requestResults != nil) {
					id photos = [requestResults objectForKey:@"photo"];
					flickrImages = [photos isKindOfClass:[NSArray class]] ? photos : [NSArray array];
				} else {
					flickrImages = [NSArray array];
					NSLog(@"results are nil %@",resopnse);
				}
				
			} else {
				flickrImages = [NSArray array];
				NSLog(@"count of images is zero %@",resopnse);
			}

			NSMutableArray *photos = [NSMutableArray array];
			for (NSDictionary *photo in flickrImages) {
				[photos addObject:[FlickrPhoto photoWithDictioary:photo]];
			}
			self.results = [NSArray arrayWithArray:photos];
			if (self.onSearchDone) {
				self.onSearchDone(self);
			}
			[MoViCo updateControllersForModel:self];
		} else {
			NSLog(@"%@",error);
			if (self.onSearchFail) {
				self.onSearchFail(error);
			}
		}
	}];
}

@end
