//
//  TalkDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Event.h"
#import "Talk.h"

@interface TalkDAO : NSObject

+(void)fetchTalkByEvent:(PFObject *)event talks:(void(^)(NSArray* talks))success failure:(void(^)(NSString *errorMessage))failure;

+(void)fetchTalkByTalkIdInBackGround:(Talk *)talk talks:(void(^)(PFObject* talkObject))success failure:(void(^)(NSString *errorMessage))failure;

+(PFObject *)fetchTalkByTalkId:(Talk *)talk;
@end
