//
//  MoViCo.h
//  MoViCoKit
//
//  Created by Igor Fedorov on 8/21/11.
//  Copyright 2011  . All rights reserved.
//

@protocol ModelControllerDelegate <NSObject>

- (NSArray*)interestedModels;
- (void)modelDidUpdate:(id)aModel;
- (void)modelWillUpdate:(id)aModel;

@end

@interface MoViCo : NSObject {
}

+ (void)setMultiThreadingEnable:(BOOL)enable;

+ (void)addController:(id<ModelControllerDelegate>)aController;

+ (void)removeController:(id<ModelControllerDelegate>)aController;

+ (void)beginUpdatesForModel:(id)aModel;

+ (void)updateControllersForModel:(id)aModel;

@end

@interface MVCController : NSObject <ModelControllerDelegate> {
	
}

@end

@interface MVCTableViewController : UITableViewController <ModelControllerDelegate> {
	
}

@end

@interface MVCViewController : UIViewController <ModelControllerDelegate> {
	
}

@end

@interface MVCTableViewCell : UITableViewCell <ModelControllerDelegate> {
	
}

@end

@interface MVCView : UIView <ModelControllerDelegate> {
	
}

@end
@interface MVCImageView : UIImageView <ModelControllerDelegate> {
	
}

@end