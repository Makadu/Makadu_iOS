//
//  SpeakerDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/1/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Speaker.h"

@interface SpeakerDAO : NSObject

+(void)createOrUpdate:(NSArray *)speakers operation:(NSString *)operation;
+(BOOL)existRegisterInDatabase:(Speaker *)speaker;

+(NSArray *)retrieveAll;
+(NSArray *)retrieveAll:(NSString *)whereCondicional;

+(void)delete:(NSString *)eventId;
@end
