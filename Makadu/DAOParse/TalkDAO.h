//
//  TalkDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Talk.h"
#import "AppHelper.h"
#import <sqlite3.h>


@interface TalkDAO : NSObject

+(void)createOrUpdate:(NSArray *)talks eventId:(NSString *)eventId operation:(NSString *)operation;
+(void)linkSpeakerATalk:(NSString *)talkId speakers:(NSArray *)speakers;

+(BOOL)existRegisterInDatabase:(Talk *)talk eventId:(NSString *)eventId;

+(NSArray *)retrieveAll;
+(NSArray *)retrieveAll:(NSString *)whereCondicional;

#pragma mark - Favorities

+(void)saveFavorities:(NSArray *)talks;
+(void)removeFavorite:(NSArray *)talks eventId:(NSString *)eventId;

@end
