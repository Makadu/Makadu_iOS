//
//  Rating.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/3/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Rating.h"
#import "MakaduService.h"
#import "User.h"

@implementation Rating

- (instancetype)initWithAttributesAndEventId:(NSDictionary *)attributes eventId:(NSString *)eventId talkId:(NSString *)talkId{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID                = [attributes valueForKeyPath:@"id"];
    self.talkID            = talkId;
    self.userID            = [User currentUser].ID;
    self.ratingDescription = [attributes valueForKeyPath:@"commentary"];
    self.note              = [attributes valueForKeyPath:@"value"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.talkID forKey:@"talkId"];
    [coder encodeObject:self.userID forKey:@"userId"];
    [coder encodeObject:self.ratingDescription forKey:@"ratingDescription"];
    [coder encodeObject:self.note forKey:@"note"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.talkID = [coder decodeObjectForKey:@"talkId"];
        self.userID = [coder decodeObjectForKey:@"userId"];
        self.ratingDescription = [coder decodeObjectForKey:@"ratingDescription"];
        self.note = [coder decodeObjectForKey:@"note"];

    }
    return self;
}

+(void)save:(NSArray *)rantings {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"ratings";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[rantings count]];
    
    for (Rating* rating in rantings) {
        NSData* ratingOBJ = [NSKeyedArchiver archivedDataWithRootObject:rating];
        [archiveArray addObject:ratingOBJ];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
    
}

+(Rating *)getRating:(NSString *)talkId {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * listRatings = [NSMutableArray new];
    NSString* savedItems = @"ratings";
    
    NSMutableArray *archiveArray = [preferences objectForKey:savedItems];
    for (NSData* ratingObj in archiveArray) {
        Rating *rating = [NSKeyedUnarchiver unarchiveObjectWithData: ratingObj];
        if ([rating.talkID intValue] == [talkId intValue] && [rating.userID intValue] == [[User currentUser].ID intValue]) {
            [listRatings addObject:rating];
        }
    }
    return [listRatings lastObject];
}

#pragma mark - WebService
+(NSURLSessionDataTask *)getRatingByEvent:(NSString *)eventId talkId:(NSString *)talkId block:(void (^)(NSArray *ratings, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/talks/%@/ratings?username=%@", eventId, talkId, [User currentUser].userName] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableRatings = [[NSMutableArray alloc] init];
        NSDictionary * attr = JSON;
        
        if ([attr isEqual:@"sem registros"]) {
            return;
        }
        
        Rating *rating = [[Rating alloc] initWithAttributesAndEventId:attr eventId:eventId talkId:talkId];
        [mutableRatings addObject:rating];
        
        if (block) {
            [Rating save:mutableRatings];
            block([NSArray arrayWithArray:mutableRatings], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+ (void)createNewRating:(NSString *)eventId talkId:(NSString *)talkId value:(NSString *)value commentary:(NSString *)commentary
            withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                     andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username":[User currentUser].userName, @"value":value, @"commentary":commentary};
    
    [manager POST:[NSString stringWithFormat:@"http://api.makadu.net/events/%@/talks/%@/ratings/add_edit", eventId, talkId] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end
