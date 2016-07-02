//
//  EvaluationService.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "EvaluationService.h"
#import "MakaduService.h"
#import "Evaluation.h"

#import "User.h"
#import "Feedback.h"

@implementation EvaluationService

+(NSURLSessionDataTask *)getEvaluationssWithEventId:(NSString *)eventId block:(void (^)(NSArray *evolutions, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/evaluation", eventId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableEvaluation = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            NSMutableDictionary *attr = [[NSMutableDictionary alloc] initWithDictionary:attributes];
            [attr setObject:eventId forKey:@"eventId"];
            Evaluation *evaluation = [[Evaluation alloc] initWithAttributes:attr];
            [mutableEvaluation addObject:evaluation];
        }
        
        if (block) {
            [Evaluation save:mutableEvaluation];
            block([NSArray arrayWithArray:mutableEvaluation], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(void)sendFeedbacks:(NSString *)eventId feedbacks:(NSArray *)feedbacks withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = [NSString stringWithFormat:@"http://api.makadu.net/events/%@/feedback", eventId];
    
    
    NSMutableArray *listfeedbacks = [[NSMutableArray alloc] init];
    
    for (Feedback *feedback in feedbacks) {
        NSMutableDictionary * feeds = [[NSMutableDictionary alloc] init];
        [feeds setObject:feedback.evaluationId forKey:@"evaluation_question_id"];
        [feeds setObject:feedback.value forKey:@"value"];
        [feeds setObject:feedback.commentary forKey:@"commentary"];
        
        [listfeedbacks addObject:feeds];
    }
    
    NSDictionary *parameters = @{@"user_id":[User currentUser].ID, @"feedbacks":listfeedbacks};
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}


@end
