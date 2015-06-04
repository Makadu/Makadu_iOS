//
//  NoticeDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "NoticeDAO.h"
#import "Connection.h"
#import "Notice.h"

@implementation NoticeDAO

+(void)fetchNoticeByEvent:(PFObject *)event notices:(void(^)(NSArray* notices))success failure:(void(^)(NSString *errorMessage))failure {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notices"];
    [query whereKey:@"event" equalTo:event];
    [query orderByAscending:@"createdAt"];
    
    if (![Connection existConnection]) {
        [query setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        if ([query hasCachedResult]) {
            [query setCachePolicy:kPFCachePolicyCacheOnly];
            [query setMaxCacheAge:600];
        } else {
            [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
            [query setMaxCacheAge:600];
        }
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray * listNotice = [NSMutableArray new];
            for (PFObject *object in objects) {
                Notice * notice = [Notice new];
                notice.noticeID = object.objectId;
                notice.notice = [object objectForKey:@"notice"];
                notice.noticeDetail = [object objectForKey:@"detail"];
                
                [listNotice addObject:notice];
            }
            success(listNotice);
        } else {
            failure(error.localizedDescription);
        }
    }];
}

@end
