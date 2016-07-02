//
//  Talk.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Talk.h"
#import "TalkDAO.h"
#import "SpeakerDAO.h"

#import "MakaduService.h"

#import "Speaker.h"

@implementation Talk

- (instancetype)initWithAttributesAndEventId:(NSDictionary *)attributes eventId:(NSString *)eventId{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.ID        = [attributes valueForKeyPath:@"id"];
    self.title     = [attributes valueForKeyPath:@"title"];
    self.talkDescription = [attributes valueForKeyPath:@"description"];
    self.eventId   = eventId;
    self.room      = [attributes valueForKeyPath:@"room"];
    self.speakers  = [attributes valueForKeyPath:@"speakers"];
    self.startTime = [attributes valueForKeyPath:@"start_time"];
    self.endTime   = [attributes valueForKeyPath:@"end_time"];
    self.updatedAt = [attributes valueForKeyPath:@"updated_at"];
    self.questions = [[attributes valueForKeyPath:@"allow_question"] boolValue];
    self.downloads = [[attributes valueForKeyPath:@"allow_download"] boolValue];
    self.favorite  = [[attributes valueForKeyPath:@"allow_favorite"] boolValue];
    self.interactive  = [[attributes valueForKeyPath:@"interactive"] boolValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.talkDescription forKey:@"description"];
    [coder encodeObject:self.eventId forKey:@"eventId"];
    [coder encodeObject:self.room forKey:@"room"];
    [coder encodeObject:self.speakers forKey:@"speakers"];
    [coder encodeObject:self.startTime forKey:@"startTime"];
    [coder encodeObject:self.endTime forKey:@"endTime"];
    [coder encodeObject:self.updatedAt forKey:@"updateAt"];
    [coder encodeBool:self.questions forKey:@"allow_question"];
    [coder encodeBool:self.downloads forKey:@"allow_download"];
    [coder encodeBool:self.favorite forKey:@"allow_favorite"];
    [coder encodeBool:self.interactive forKey:@"interactive"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.talkDescription = [coder decodeObjectForKey:@"description"];
        self.eventId = [coder decodeObjectForKey:@"eventId"];
        self.room = [coder decodeObjectForKey:@"room"];
        self.speakers = [coder decodeObjectForKey:@"speakers"];
        self.startTime = [coder decodeObjectForKey:@"startTime"];
        self.endTime = [coder decodeObjectForKey:@"endTime"];
        self.updatedAt = [coder decodeObjectForKey:@"updateAt"];
        self.questions = [coder decodeBoolForKey:@"allow_question"];
        self.downloads = [coder decodeBoolForKey:@"allow_download"];
        self.favorite  = [coder decodeBoolForKey:@"allow_favorite"];
        self.interactive  = [coder decodeBoolForKey:@"interactive"];
    }
    return self;
}

+(BOOL)existDataInDataBase:(NSString *)eventId talkId:(Talk *)talk {
    return [TalkDAO existRegisterInDatabase:talk eventId:eventId];
}

+(NSArray *)retrieveTalkByEvent:(NSString *)eventId {
    return [TalkDAO retrieveAll:[NSString stringWithFormat:@" eventId = %@", eventId]];
}

#pragma mark - Favorities

-(NSArray *)loadFavoritiesTalks:(NSString *)eventID {

    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * listTalks = [NSMutableArray new];
    NSString* savedItems = @"favorities_talks";

    NSMutableArray *archiveArray = [preferences objectForKey:savedItems];
    for (NSData* talkObj in archiveArray) {
        Talk *talk = [NSKeyedUnarchiver unarchiveObjectWithData: talkObj];
        if ([talk.eventId intValue] == [eventID intValue]) {
            [listTalks addObject:talk];
        }
    }
    return listTalks;
}


- (void)toggleFavorite:(BOOL)isFavorite {
    NSArray *favorites = [self loadFavoritiesTalks:self.eventId];
    if (isFavorite) {
        if (favorites == nil)
            favorites = @[ self ];
        else
            favorites = [favorites arrayByAddingObject:self];
        [TalkDAO saveFavorities:favorites];
    } else {
        [TalkDAO removeFavorite:@[self] eventId:self.eventId];
    }
}

- (BOOL)isFavorite {
    NSArray * favorities = [self loadFavoritiesTalks:self.eventId];
    for (Talk * object in favorities) {
        if ([object.ID intValue] == [self.ID intValue]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - WebService Talks

+(NSURLSessionDataTask *)getTalksByEvent:(NSString *)eventId block:(void (^)(NSArray *talks, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/talks", eventId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableTalks = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            Talk *talk = [[Talk alloc] initWithAttributesAndEventId:attributes eventId:eventId];
            [mutableTalks addObject:talk];
        }
        
        if (block) {
            [TalkDAO createOrUpdate:mutableTalks eventId:eventId operation:nil];
            block([NSArray arrayWithArray:mutableTalks], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(NSURLSessionDataTask *)getTalkWithEventId:(NSString *)eventId talkId:(NSString *)talkId block:(void (^)(NSArray *talks, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/talks/%@", eventId, talkId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSArray *speakersFromResponse = [JSON valueForKeyPath:@"speakers"];
        NSMutableArray *mutableSpeakers = [NSMutableArray arrayWithCapacity:[speakersFromResponse count]];
        for (NSDictionary *attributes in speakersFromResponse) {
            Speaker *speaker = [[Speaker alloc] initWithAttributes:attributes];
            [mutableSpeakers addObject:speaker];
        }
        
        if (block) {
            [SpeakerDAO createOrUpdate:mutableSpeakers operation:nil];
            [TalkDAO linkSpeakerATalk:talkId speakers:mutableSpeakers];
            block([NSArray arrayWithArray:mutableSpeakers], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

#pragma mark - WebService Download Material
+ (void)downloadMaterial:(NSString *)userName eventId:(NSString *)eventId talkId:(NSString *)talkId
            withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                     andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username":userName};
    
    [manager POST:[NSString stringWithFormat:@"http://api.makadu.net/events/%@/talks/%@/download", eventId, talkId] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

-(id)objectForKeyedSubscript:(id)key {
    return self[key];
}

@end
