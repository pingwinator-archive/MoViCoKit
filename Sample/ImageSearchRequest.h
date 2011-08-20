//
//  ImageSearchRequest.h
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageSearchRequest : NSObject {

}

@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) NSArray *results;

@property (nonatomic, copy) void (^onSearchDone)(ImageSearchRequest* request);
@property (nonatomic, copy) void (^onSearchFail)(NSError* error);

- (void)searchWithLimit:(int)limit;

@end
