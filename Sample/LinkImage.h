//
//  LinkImage.h
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/12/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LinkImage : NSObject {

}

@property (nonatomic, retain) UIImage *image;

- (void)updateImage;

+ (LinkImage*)imageWithLink:(NSURL*)link;

@end
