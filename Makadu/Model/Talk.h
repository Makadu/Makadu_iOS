//
//  Talk.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import <AFNetworking/AFNetworking.h>

@interface Talk : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *eventId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *talkDescription;
@property(nonatomic, strong) NSString *room;
@property(nonatomic, strong) NSString *speakers;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *updatedAt;

@property(nonatomic) BOOL questions;
@property(nonatomic) BOOL downloads;
@property(nonatomic) BOOL favorite;
@property(nonatomic) BOOL interactive;

- (instancetype)initWithAttributesAndEventId:(NSDictionary *)attributes eventId:(NSString *)eventId;

#pragma mark - WebService Talks
+(NSURLSessionDataTask *)getTalksByEvent:(NSString *)eventId block:(void (^)(NSArray *events, NSError *error))block;
+(NSURLSessionDataTask *)getTalkWithEventId:(NSString *)eventId talkId:(NSString *)talkId block:(void (^)(NSArray *talks, NSError *error))block;

#pragma mark - WebService Download Material
+ (void)downloadMaterial:(NSString *)userName eventId:(NSString *)eventId talkId:(NSString *)talkId
   withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
            andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

#pragma mark - Database
+(NSArray *)retrieveTalkByEvent:(NSString *)eventId;
+(BOOL)existDataInDataBase:(NSString *)eventId talkId:(Talk *)talk;

#pragma mark - Favorities
-(NSArray *)loadFavoritiesTalks:(NSString *)eventID;
-(void)toggleFavorite:(BOOL)isFavorite;
-(BOOL)isFavorite;


- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;


@end
