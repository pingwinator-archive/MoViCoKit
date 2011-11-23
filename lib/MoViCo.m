//
//  MoViCo.m
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/21/11.
//  Copyright 2011. All rights reserved.
//

#import "MoViCo.h"

@interface ARCWrapper : NSObject {}
@property (unsafe_unretained, nonatomic) id<ModelControllerDelegate> controller;
@end

@implementation ARCWrapper
@synthesize controller;
@end

///////////////////////////////////////////////////////////////////////////////////////
@interface MoViCo()

@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, strong) NSOperationQueue *updateQueue;

+ (MoViCo *)sharedMVC;

#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MoViCo

@synthesize controllers;
@synthesize updateQueue;

static MoViCo* sharedMVC;
static BOOL initialized;
static BOOL isMultiThread;

+ (MoViCo *)sharedMVC {
	@synchronized([self class]) {
		if (!sharedMVC) {
			sharedMVC = [[self alloc] init];
		}
	}
	return sharedMVC;
}

#pragma mark -
#pragma mark static methods

+ (id)alloc {
	@synchronized([self class]) {
		NSAssert(sharedMVC == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

+ (void)end {
	sharedMVC = nil;
}

+ (void)setMultiThreadingEnable:(BOOL)enable {
	isMultiThread = enable;
}

+ (void)addController:(id<ModelControllerDelegate>)aController {
	@synchronized([MoViCo sharedMVC].controllers) {
		NSMutableArray *cached = [MoViCo sharedMVC].controllers;
		if ([cached indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj controller] == aController) {
                *stop = YES;
                return YES;
            } else {
                return NO;
            }
        }] == NSNotFound) {
            ARCWrapper *wrapper = [[ARCWrapper alloc] init];
            wrapper.controller = aController;
			[cached addObject:wrapper];
		}
	}
}

+ (void)removeController:(id <ModelControllerDelegate>)aController {
	@synchronized([MoViCo sharedMVC].controllers) {
		NSMutableArray *cached = [MoViCo sharedMVC].controllers;
        NSInteger idx = [cached indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj controller] == aController) {
                *stop = YES;
                return YES;
            } else {
                return NO;
            }
        }];
		if (idx != NSNotFound) {
			[cached removeObjectAtIndex:idx];
			if ([cached count] == 0) {
				[MoViCo end];
				return;
			}
		}
	}
}

+ (void (^)(void))lookingForControllersWithModel:(id)aModel onFindBlock:(void (^)(NSArray *needs))onFindBlock {
	return [ ^ {
		NSMutableArray *cached = [[MoViCo sharedMVC].controllers copy];
		NSMutableArray *needs = [NSMutableArray array];
		[cached enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			id <ModelControllerDelegate> controller = (id<ModelControllerDelegate>)[obj controller];
			[[controller interestedModels] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if ([obj isEqual:aModel]) {
					*stop = YES;
					[needs addObject:controller];
				}
			}];
		}];
		if (onFindBlock) {
			dispatch_async(dispatch_get_main_queue(), ^ {
				onFindBlock(needs);
			});
		}
	} copy];
}

+ (void)beginUpdatesForModel:(id)aModel {
	if (!initialized) {
		return;
	}
	NSOperationQueue *runQueue = nil;
	if (isMultiThread) {
		runQueue = [MoViCo sharedMVC].updateQueue;
	} else {
		runQueue = [NSOperationQueue mainQueue];
	}
	
	[runQueue addOperationWithBlock:[self lookingForControllersWithModel:aModel onFindBlock:^ (NSArray *needs) {
		[needs makeObjectsPerformSelector:@selector(modelWillUpdate:) withObject:aModel];
	}]];
}

+ (void)updateControllersForModel:(id)aModel {
	if (!initialized) {
		return;
	}
	NSOperationQueue *runQueue = nil;
	if (isMultiThread) {
		runQueue = [MoViCo sharedMVC].updateQueue;
	} else {
		runQueue = [NSOperationQueue mainQueue];
	}
	
	[runQueue addOperationWithBlock:[self lookingForControllersWithModel:aModel onFindBlock:^ (NSArray *needs) {
		[needs makeObjectsPerformSelector:@selector(modelDidUpdate:) withObject:aModel];
	}]];
}

#pragma mark -
#pragma mark instance methods

- (id)init {
	if ((self = [super init])) {
#ifdef MVC_DEBUG
		NSLog(@"MoViCo initialized");
#endif
		self.controllers = [NSMutableArray array];
		self.updateQueue = [[NSOperationQueue alloc] init];
		[self.updateQueue setMaxConcurrentOperationCount:1];
		initialized = YES;
	}
	return self;
}

- (void)dealloc {
	initialized = NO;
	[self.updateQueue cancelAllOperations];
#ifdef MVC_DEBUG
	NSLog(@"MoViCo deinitialized");
#endif
}

#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCController

MVC_INIT

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCViewController

MVC_INIT

MVC_INIT_WITH_CODER

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	if ([self.view superview] == nil) {
		self.view = nil;
	}
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}
#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCTableViewController

MVC_INIT

MVC_INIT_WITH_CODER

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		[MoViCo addController:self];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	if ([self.view superview] == nil) {
		self.view = nil;
	}
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}
#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCTableViewCell

#pragma mark -
#pragma mark instance methods

MVC_INIT

MVC_INIT_WITH_CODER

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
#pragma mark -
@end

///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCView

MVC_INIT

MVC_INIT_WITH_CODER

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
#pragma mark -
@end
///////////////////////////////////////////////////////////////////////////////////////
@implementation MVCImageView

MVC_INIT

MVC_INIT_WITH_CODER

MVC_DEALLOC

MVC_MODEL_WILL_UPDATE

MVC_MODEL_DID_UPDATE

MVC_INTERESTED_MODELS

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
-(id)initWithImage:(UIImage *)image {
	if ((self=[super initWithImage:image])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
-(id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
	if ((self =[super initWithImage:image highlightedImage:highlightedImage])) {
		MVC_ADD_CONTROLLER
	}
	return self;
}
#pragma mark -
@end
