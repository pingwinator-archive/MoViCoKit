/*
 *  MVCMacros.h
 *  MoViCo
 *
 *  Created by Igor Fedorov on 8/12/11.
 *   Copyright 2011. All rights reserved.
 *
 */
#define MVC_ADD_CONTROLLER [MoViCo addController:self];
#define MVC_REMOVE_CONTROLLER [MoViCo removeController:self];

#define MVC_INIT \
- (id)init {\
	if ((self = [super init])) {\
		MVC_ADD_CONTROLLER\
	}\
	return self;}

#define MVC_DEALLOC \
- (void)dealloc {\
	NSString *msg = [NSString stringWithFormat:@"Models must be nil %@",[self interestedModels]];\
	NSAssert([[self interestedModels] count] == 0, msg);\
	MVC_REMOVE_CONTROLLER}

#define MVC_INIT_WITH_CODER \
- (id)initWithCoder:(NSCoder *)aDecoder {\
	self = [super initWithCoder:aDecoder];\
	MVC_ADD_CONTROLLER\
	return self;}

#define MVC_CHECK_MODEL(aModel) \
{\
	BOOL isInterested = NO;\
	for (id objID in [self interestedModels]) {\
		if ([objID isEqual:aModel]) {\
			isInterested = YES;\
			break;\
		}\
	}\
	if (!isInterested) {\
		NSString *msg = [NSString stringWithFormat:@"wrong model in controller \n id:%@\nneeds:%@",aModel, [self interestedModels]];\
		NSAssert(isInterested, msg);\
		msg = nil;}}

#ifdef MVC_DEBUG
#define MVC_MODEL_DID_UPDATE \
- (void)modelDidUpdate:(id)aModel {\
	MVC_CHECK_MODEL(aModel)}
#else
#define MVC_MODEL_DID_UPDATE \
- (void)modelDidUpdate:(id)aModel {}
#endif

#ifdef MVC_DEBUG
#define MVC_MODEL_WILL_UPDATE \
- (void)modelWillUpdate:(id)aModel {\
	MVC_CHECK_MODEL(aModel)}
#else
#define MVC_MODEL_WILL_UPDATE \
- (void)modelWillUpdate:(id)aModel {}
#endif


#define MVC_INTERESTED_MODELS \
- (NSArray*)interestedModels { \
	return [NSArray array];}

#define IF_NOT_NIL_ADD_TO_ARRAY(obj, arr)						\
{																\
	if (obj != nil) {											\
		NSArray *objArr = [NSArray arrayWithObject:obj];		\
		*arr = [objArr arrayByAddingObjectsFromArray:*arr];}}


