//
//  EventDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Event.h"

@interface EventDAO : NSObject

@property(nonatomic, strong) NSArray * listEvents;

+(void)fetchAllEvents:(void(^)(NSArray* events))success failure:(void(^)(NSString *errorMessage))failure;

+(PFObject *)fetchEventByEventId:(Event *)event;
@end
