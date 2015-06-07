//
//  TalkFavoriteDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkFavoriteDAO.h"
#import "Talk.h"
#import "Connection.h"

@implementation TalkFavoriteDAO

+(void)fetchTalkFavoriteByEvent:(PFObject *)event talks:(void(^)(NSArray* talks))success failure:(void(^)(NSString *errorMessage))failure {
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [userQuery includeKey:@"favorities_talks"];
    [userQuery setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [userQuery setMaxCacheAge:100];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *user = [objects lastObject];
            NSArray *talks = user[@"favorities_talks"];
            NSMutableArray * listTalk = [NSMutableArray new];
            for (PFObject *object in talks) {
                if ([((PFObject *)object[@"event"]).objectId isEqualToString:event.objectId]) {
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
                        [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
                        [query setMaxCacheAge:600];
                    }
                    [query findObjectsInBackgroundWithBlock:^(NSArray *speakers, NSError *error) {
                        talk.speakers = speakers;
                    }];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:talk forKey:@"favoritiesTalks"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [listTalk addObject:talk];
                }
                success(listTalk);
            }
        } else {
            failure(error.localizedDescription);
        }
    }];
}


+(void)saveFavorities:(PFObject *)talk {
    
    PFUser *user = [PFUser currentUser];
    [user setObject:@[talk] forKey:@"favorities_talks"];
    [user saveInBackground];
}
@end
