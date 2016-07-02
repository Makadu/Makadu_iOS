//
//  Rating.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/3/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import <AFNetworking/AFNetworking.h>

@interface Rating : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *talkID;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *ratingDescription;
@property(nonatomic, strong) NSNumber *note;

- (instancetype)initWithAttributesAndEventId:(NSDictionary *)attributes eventId:(NSString *)eventId talkId:(NSString *)talkId;

+(void)save:(NSArray *)rantings;
+(Rating *)getRating:(NSString *)talkId;

#pragma mark - WebService
+(NSURLSessionDataTask *)getRatingByEvent:(NSString *)eventId talkId:(NSString *)talkId block:(void (^)(NSArray *ratings, NSError *error))block;
+ (void)createNewRating:(NSString *)eventId talkId:(NSString *)talkId value:(NSString *)value commentary:(NSString *)commentary
  withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
           andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

@end
