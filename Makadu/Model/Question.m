//
//  Question.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Question.h"
#import "MakaduService.h"
#import "QuestionDAO.h"

@implementation Question

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.talkID = [attributes valueForKeyPath:@"talk_id"];
    self.question = [attributes valueForKeyPath:@"value"];
    self.questioning = [attributes valueForKeyPath:@"user"];
    self.date        = [attributes valueForKeyPath:@"created_at"];
    
    return self;
}

#pragma mark - WebServce
+(NSURLSessionDataTask *)getQuestionsByTalkAndEventId:(NSString *)talkId eventId:(NSString *)eventId block:(void (^)(NSArray *events, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/talks/%@/questions", eventId, talkId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableQuestions = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            Question *question = [[Question alloc] initWithAttributes:attributes];
            [mutableQuestions addObject:question];
        }
        
        if (block) {
            [QuestionDAO createOrUpdate:mutableQuestions operation:nil];
            block([NSArray arrayWithArray:mutableQuestions], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+ (void)sentQuestionByEventId:(NSString *)eventId talkId:(NSString *)talkId username:(NSString *)userName question:(NSString *)question withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                     andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"question": @{@"username":userName, @"question":question}};
    
    [manager POST:[NSString stringWithFormat:@"http://api.makadu.net/events/%@/talks/%@/questions/add", eventId, talkId] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

#pragma mark - Database

+(NSArray *)retrieveByTalkId:(NSString *)talkId {
    return [QuestionDAO retrieveAll:[NSString stringWithFormat:@" talkId = %@", talkId]];
}

+(BOOL)existQuestionForTalk:(NSString *)talkId {
    
    NSArray * speakers = [QuestionDAO retrieveAll:[NSString stringWithFormat:@" talkId = %@", talkId]];
    
    if (speakers.count > 0) {
        return YES;
    }
    
    return NO;
}

@end
