//
//  Event.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworking.h>


@interface Event : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *eventDescription;
@property(nonatomic, strong) NSString *venue;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *startDate;
@property(nonatomic, strong) NSString *endDate;
@property(nonatomic, strong) NSString *logo;
@property(nonatomic, strong) NSString *logoMedium;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *updatedAt;
@property(nonatomic, strong) NSData *imgLogo;
@property(nonatomic, strong) NSData *imgLogoMedium;
@property(nonatomic, strong) NSString * eventType;
@property(nonatomic, strong) NSString * password;

-(instancetype)initWithAttributes:(NSDictionary *)attributes;
+(BOOL)existDataInDataBase:(Event *)event;
+(NSArray *)retrieveEventAll;
+(void)saveImageLogo:(UIImage *)image eventId:(NSString *)eventID;
+(void)saveImageLogoMedium:(UIImage *)image eventId:(NSString *)eventID;

-(NSArray *)loadFavoritiesEvents;
-(void)toggleFavorite:(BOOL)isFavorite;
-(BOOL)isFavorite;

+(NSURLSessionDataTask *)getEvents:(void (^)(NSArray *events, NSError *error))block;
+(NSURLSessionDataTask *)getEventsFavorities:(void (^)(NSArray *events, NSError *error))block;

+ (void)addNewEventFavorite:(NSString *)eventId username:(NSString *)userName withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
               andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

+ (void)removeEventFavorite:(NSString *)eventId username:(NSString *)userName withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
               andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

+(void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;

+(void)savePasswordEvent:(NSArray *)events;
+(BOOL)eventSavePassword:(Event *)event;
-(NSArray *)loadEventsWithPassword;
@end
