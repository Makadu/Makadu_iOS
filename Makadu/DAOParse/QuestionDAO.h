//
//  QuestionDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "Question.h"

@interface QuestionDAO : NSObject

+(void)createOrUpdate:(NSArray *)speakers operation:(NSString *)operation;
+(BOOL)existRegisterInDatabase:(Question *)speaker;

+(NSArray *)retrieveAll;
+(NSArray *)retrieveAll:(NSString *)whereCondicional;

@end
