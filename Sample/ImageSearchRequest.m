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

@property (nonatomic, strong) NSOperationQueue *opQueue;

@end

@implementation ImageSearchRequest

@synthesize opQueue;
@synthesize onSearchDone;
@synthesize onSearchFail;
@synthesize results,searchText;

- (void)dealloc {
	[self.opQueue cancelAllOperations];
}

- (id)init {
	self = [super init];
	self.results = [NSArray array];
	self.opQueue = [[NSOperationQueue alloc] init];
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
    NSString *searchString = self.searchText;
    __unsafe_unretained ImageSearchRequest * selfWeak = self;
	[self.opQueue addOperationWithBlock:^ {
		NSString *fullUrl = [NSString stringWithFormat:SEARCH_URL_FORMAT,limit,searchString];
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
			selfWeak.results = [NSArray arrayWithArray:photos];
			if (selfWeak.onSearchDone) {
				selfWeak.onSearchDone(selfWeak);
			}
			[MoViCo updateControllersForModel:selfWeak];
		} else {
			NSLog(@"%@",error);
			if (selfWeak.onSearchFail) {
				selfWeak.onSearchFail(error);
			}
		}
	}];
}

@end
