//
//  TalkDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkDAO.h"
#import "Connection.h"

@implementation TalkDAO

+(void)fetchTalkByEvent:(PFObject *)event talks:(void(^)(NSArray* talks))success failure:(void(^)(NSString *errorMessage))failure {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Talks"];
    
    [query whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"event" equalTo:event];
    [query orderByAscending:@"start_hour"];
    
    if (![Connection existConnection]) {
        [query setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray * listTalk = [NSMutableArray new];
            for (PFObject *object in objects) {
                Talk * talk = [Talk new];
                talk.talkID = object.objectId;
                talk.title = [object objectForKey:@"title"];
                talk.talkDescription = [object objectForKey:@"description"];
                talk.startHour = [object objectForKey:@"start_hour"];
                talk.endHour = [object objectForKey:@"end_hour"];
                talk.local = [object objectForKey:@"local"];
                talk.url = [object objectForKey:@"link"];
                talk.date = [object objectForKey:@"date_talk"];
                talk.photo = [object objectForKey:@"photo"];
                
                talk.allowFile = [[object objectForKey:@"allow_file"] boolValue];
                talk.allowQuestion = [[object objectForKey:@"allow_question"] boolValue];
                talk.file = [object objectForKey:@"file"];
                
                PFRelation *relationSpeaker = [object relationForKey:@"speakers"];
                PFQuery * query = [relationSpeaker query];
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
                talk.speakers = [query findObjects];
                
                [listTalk addObject:talk];
            }
            success(listTalk);
        } else {
            failure(error.localizedDescription);
        }
    }];
}

+(PFObject *)fetchTalkByTalkId:(Talk *)talk {
    PFQuery * queryTalk = [PFQuery queryWithClassName:@"Talks"];
    if (![Connection existConnection]) {
        [queryTalk setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        if ([queryTalk hasCachedResult]) {
            [queryTalk setCachePolicy:kPFCachePolicyCacheOnly];
            [queryTalk setMaxCacheAge:600];
        } else {
            [queryTalk setCachePolicy:kPFCachePolicyCacheElseNetwork];
            [queryTalk setMaxCacheAge:600];
        }
    }
    PFObject * talkObject = [queryTalk getObjectWithId:talk.talkID];
    return talkObject;
}

@end
