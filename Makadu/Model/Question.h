//
//  Question.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworking.h>


@interface Question : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *talkID;
@property(nonatomic, strong) NSString *question;
@property(nonatomic, strong) NSString *questioning;
@property(nonatomic, strong) NSString *date;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+(NSArray *)retrieveByTalkId:(NSString *)talkId;
+(BOOL)existQuestionForTalk:(NSString *)talkId;


#pragma mark - WebService

+(NSURLSessionDataTask *)getQuestionsByTalkAndEventId:(NSString *)talkId eventId:(NSString *)eventId block:(void (^)(NSArray *events, NSError *error))block;

+ (void)sentQuestionByEventId:(NSString *)eventId talkId:(NSString *)talkId username:(NSString *)userName question:(NSString *)question withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                 andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;
@end
