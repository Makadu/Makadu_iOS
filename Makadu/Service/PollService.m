//
//  PollService.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/30/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PollService.h"
#import "MakaduService.h"
#import "Poll.h"
#import "Answer.h"
#import "User.h"

@implementation PollService

+(NSURLSessionDataTask *)getQuestionWithTalkId:(NSString *)talkId block:(void (^)(NSArray *questions, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/interativas/%@", talkId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSArray *answersFromResponse = [JSON valueForKeyPath:@"answers"];
        NSMutableArray * answers = [[NSMutableArray alloc] initWithCapacity:[answersFromResponse count]];
        for (NSDictionary *attributes in answersFromResponse) {
            Answer * answer = [[Answer alloc] initWithAttributes:attributes];
            [answers addObject:answer];
        }
        
        Poll *poll = [Poll new];
        poll.endTime = [JSON valueForKeyPath:@"end_time"];
        poll.ID = [JSON valueForKeyPath:@"id"];
        poll.question = [JSON valueForKeyPath:@"question_interactive"];
        poll.startTime = [JSON valueForKeyPath:@"start_time"];
        poll.talkID = [JSON valueForKeyPath:@"talk_id"];
        poll.currentTime = [JSON valueForKeyPath:@"current_time"];
        poll.answers = answers;
        
        if (block) {
            block(@[poll], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(void)sendAnswerInteractive:(NSString *)talkId questionId:(NSString *)questionId aswerId:(NSString *)answerId withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
               andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = [NSString stringWithFormat:@"http://api.makadu.net/interativas/%@/question/%@", talkId, questionId];
    
    NSDictionary *parameters = @{@"answer_id":answerId, @"user_id":[User currentUser].ID};
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}
@end
