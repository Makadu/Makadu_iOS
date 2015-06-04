//
//  QuestionDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "QuestionDAO.h"
#import "Connection.h"
#import "Question.h"
#import "DateFormatter.h"

@implementation QuestionDAO

+(void)fetchQuestionByTalk:(PFObject *)talk questions:(void(^)(NSArray* questions))success failure:(void(^)(NSString *errorMessage))failure {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Questions"];
    [query whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"talk" equalTo:talk];
    [query orderByAscending:@"createdAt"];
    
    if (![Connection existConnection]) {
        [query setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        if ([query hasCachedResult]) {
            [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
//            [query setMaxCacheAge:600];
        } else {
            [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        }
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray * listQuestion = [NSMutableArray new];
            for (PFObject *object in objects) {
                Question * question = [Question new];
                question.questionID = object.objectId;
                question.question = [object objectForKey:@"question"];
                question.date = [DateFormatter formateDateBrazilianDateByTimeZone:object.createdAt];
                
                PFUser * user = [object objectForKey:@"questioning"];
                PFUser *queryUser = [PFQuery getUserObjectWithId:user.objectId];
                question.questioning = queryUser[@"full_name"];
                
                [listQuestion addObject:question];
            }
            success(listQuestion);
        } else {
            failure(error.localizedDescription);
        }
    }];
}
@end
