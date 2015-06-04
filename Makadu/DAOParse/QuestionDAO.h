//
//  QuestionDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Talk.h"

@interface QuestionDAO : NSObject

+(void)fetchQuestionByTalk:(PFObject *)talk questions:(void(^)(NSArray* questions))success failure:(void(^)(NSString *errorMessage))failure;

@end
