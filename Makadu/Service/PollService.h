//
//  PollService.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/30/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworking.h>

@interface PollService : NSObject

+(NSURLSessionDataTask *)getQuestionWithTalkId:(NSString *)talkId block:(void (^)(NSArray *talks, NSError *error))block;

+(void)sendAnswerInteractive:(NSString *)talkId questionId:(NSString *)questionId aswerId:(NSString *)answerId withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;
@end
