//
//  FlickrPhoto.h
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FlickrPhoto : NSObject {

}

@property (nonatomic, retain) NSString *title;

+ (FlickrPhoto*)photoWithDictioary:(NSDictionary*)photoDictionary;

- (NSURL*)smallImageURl;

@end
