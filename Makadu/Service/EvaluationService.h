//
//  EvaluationService.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworking.h>

@interface EvaluationService : NSObject

+(NSURLSessionDataTask *)getEvaluationssWithEventId:(NSString *)eventId block:(void (^)(NSArray *evolutions, NSError *error))block;
+(void)sendFeedbacks:(NSString *)eventId feedbacks:(NSArray *)feedbacks withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
        andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;
@end
