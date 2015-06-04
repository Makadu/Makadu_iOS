//
//  EventDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventDAO.h"
#import "Connection.h"
#import "Event.h"
#import "DateFormatter.h"

@implementation EventDAO


+(void)fetchAllEvents:(void(^)(NSArray* events))success failure:(void(^)(NSString *errorMessage))failure
{
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"start_date"];
    
    if (![Connection existConnection]) {
        [query setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray * listEvent = [NSMutableArray new];
            for (PFObject *object in objects) {
                Event * event = [Event new];
                event.eventID = object.objectId;
                event.name = [object objectForKey:@"event_name"];
                event.eventDescription = [object objectForKey:@"event_description"];
                event.local = [object objectForKey:@"local"];
                event.address = [object objectForKey:@"address"];
                event.city = [object objectForKey:@"city"];
                event.state = [object objectForKey:@"state"];
                event.startDate = [DateFormatter formateDateBrazilian:[object objectForKey:@"start_date"] withZone:YES];
                event.endDate = [DateFormatter formateDateBrazilian:[object objectForKey:@"end_date"] withZone:YES];
                event.fileImgEvent = [object objectForKey:@"logo"];
                event.fileImgPatronage = [object objectForKey:@"patronage"];
                
                [listEvent addObject:event];
            }
            success(listEvent);
        } else {
            failure(error.description);
        }
    }];
}

+(PFObject *)fetchEventByEventId:(Event *)event {
    
    PFQuery * queryEvent = [PFQuery queryWithClassName:@"Events"];
    if (![Connection existConnection]) {
        [queryEvent setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        if (queryEvent.hasCachedResult) {
            [queryEvent setCachePolicy:kPFCachePolicyCacheOnly];
            [queryEvent setMaxCacheAge:600];
        } else {
            [queryEvent setCachePolicy:kPFCachePolicyCacheElseNetwork];
            [queryEvent setMaxCacheAge:600];
        }
    }
    
    PFObject * eventObject = [queryEvent getObjectWithId:event.eventID];
    return eventObject;
}

@end
