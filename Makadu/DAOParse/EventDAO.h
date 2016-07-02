//
//  EventDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "AppHelper.h"
#import <sqlite3.h>

@interface EventDAO : NSObject

@property(nonatomic, strong) NSArray * listEvents;

+(void)createOrUpdate:(NSArray *)events operation:(NSString *)operation;
+(void)saveImageLogo:(NSData *)data eventId:(NSString *)eventId;
+(void)saveImageLogoMedium:(NSData *)data eventId:(NSString *)eventId;
+(BOOL)existRegisterInDatabase:(Event *)event;

+(NSArray *)retrieveAll;
+(NSArray *)retrieveAll:(NSString *)whereCondicional;

@end
