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
    
    [userQuery orderByAscending:@"start_hour"];
    
    if (![Connection existConnection]) {
        [userQuery setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        [userQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *user = [objects lastObject];
            NSArray *talks = user[@"favorities_talks"];
            NSMutableArray * listTalk = [NSMutableArray new];
            if (talks != nil && [talks count] > 0) {
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
                        talk.allowFavorite = [[object objectForKey:@"allow_favorite"] boolValue];
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
                    
                        [listTalk addObject:talk];
                    }
                }
                success([[self class] sortedTalkArray:listTalk]);
            } else {
                success(@[]);
            }
        } else {
            failure(error.localizedDescription);
        }
    }];
}

+ (NSArray *)sortedTalkArray:(NSArray *)talks {
    return [talks sortedArrayUsingComparator:[[self class] _orderByTimeThenRoomComparator]];
}

+ (NSComparator)_orderByTimeThenRoomComparator {
    return ^NSComparisonResult(Talk *talk1, Talk *talk2) {
        NSComparisonResult timeResult = [talk1.startHour compare:talk2.startHour];
        if (timeResult != NSOrderedSame) {
            return timeResult;
        }
        return [talk1.startHour compare:talk2.startHour];
    };
}


+(void)saveFavorities:(NSArray *)talks {
    
    NSMutableArray *favorites = [PFUser currentUser][@"favorities_talks"];
    [favorites addObjectsFromArray:talks];
    
    PFUser *user = [PFUser currentUser];
    [user setObject:favorites forKey:@"favorities_talks"];
    [user saveInBackground];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)removeFavorite:(NSArray *)talks {
    
    NSMutableArray *favorites = [PFUser currentUser][@"favorities_talks"];
    for (int i = 0; i < favorites.count; i++) {
        if ([((PFObject *)talks[0]).objectId isEqualToString:((PFObject *)favorites[i]).objectId]) {
            [favorites removeObject:favorites[i]];
        }
    }
    PFUser *user = [PFUser currentUser];
    [user setObject:favorites forKey:@"favorities_talks"];
    [user saveInBackground];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
