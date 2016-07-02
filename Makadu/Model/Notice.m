//
//  Notice.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Notice.h"

#import "MakaduService.h"

@implementation Notice

- (instancetype)initWithAttributesAndEventId:(NSDictionary *)attributes eventId:(NSString *)eventId{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID           = [attributes valueForKeyPath:@"id"];
    self.notice       = [attributes valueForKeyPath:@"title"];
    self.noticeDetail = [attributes valueForKeyPath:@"description"];
    self.visualized   = [[attributes valueForKeyPath:@"visualized"] boolValue];
    self.eventID      = [attributes valueForKeyPath:@"eventID"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.notice forKey:@"notice"];
    [coder encodeObject:self.noticeDetail forKey:@"noticeDetail"];
    [coder encodeBool:self.visualized forKey:@"visualized"];
    [coder encodeObject:self.eventID forKey:@"eventID"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.notice = [coder decodeObjectForKey:@"notice"];
        self.noticeDetail = [coder decodeObjectForKey:@"noticeDetail"];
        self.visualized   = [coder decodeBoolForKey:@"visualized"];
        self.eventID      = [coder decodeObjectForKey:@"eventID"];
    }
    return self;
}

+(void)save:(NSArray *)listNotice {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"notices";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[listNotice count]];
    
    for (Notice* notice in listNotice) {
        NSData* noticeObj = [NSKeyedArchiver archivedDataWithRootObject:notice];
        [archiveArray addObject:noticeObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(NSArray *)getNotices:(NSString *)eventId {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * listNotice = [NSMutableArray new];
    NSString* savedItems = @"notices";
    
    NSMutableArray *archiveArray = [preferences objectForKey: savedItems];
    for (NSData* noticeObj in archiveArray) {
        Notice *notice = [NSKeyedUnarchiver unarchiveObjectWithData: noticeObj];
        if ([notice.eventID intValue] == [eventId intValue]) {
            [listNotice addObject:notice];
        }
    }
    return listNotice;
}

+(int)getNoticesNotVisualizedByEventId:(NSString *)eventId {
    
    NSArray * listNotices = [Notice getNotices:eventId];
    int numberNotice = 0;
    
    for (Notice * notice in listNotices) {
        if (!notice.visualized) {
            numberNotice++;
        }
    }
    
    return numberNotice;
}

+(void)updateNoticeVisualized:(NSArray *)listNotice andEventId:(NSString *)eventId {
    
    NSMutableArray *notices = [[NSMutableArray alloc] initWithArray:[Notice getNotices:eventId]];
    
    for (int i = 0; i < notices.count; i++) {
        if ([eventId intValue] == [((Notice *)notices[i]).ID intValue]) {
            [notices removeObject:notices[i]];
        }
    }
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"notices";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[notices count]];
    
    for (Notice* notice in notices) {
        notice.visualized = YES;
        NSData* noticeObj = [NSKeyedArchiver archivedDataWithRootObject:notice];
        [archiveArray addObject:noticeObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
    
}

#pragma mark - WebService

+(NSURLSessionDataTask *)getNoticesByEvent:(NSString *)eventId block:(void (^)(NSArray *notices, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/notices", eventId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableNotices = [[NSMutableArray alloc] init];
        
        for (NSDictionary *attributes in JSON) {
            NSMutableDictionary * attr = [[NSMutableDictionary alloc] initWithDictionary:attributes];
            [attr setObject:eventId forKey:@"eventID"];
            
            Notice * noticeRetrieve = [Notice getNoticeById:[attr objectForKey:@"id"]];
            
            if (noticeRetrieve.visualized) {
                [attr setObject:[NSNumber numberWithBool:YES] forKey:@"visualized"];
            } else {
                [attr setObject:[NSNumber numberWithBool:NO] forKey:@"visualized"];
            }
            
            Notice *notice = [[Notice alloc] initWithAttributesAndEventId:attr eventId:eventId];
        
            [mutableNotices addObject:notice];
        }
        
        NSMutableSet * set = [NSMutableSet setWithArray:[Notice getNotices:eventId]];
        [set intersectSet:[NSSet setWithArray:mutableNotices]];
        [set unionSet:[NSSet setWithArray:mutableNotices]];
        
        if (block) {
            [Notice save:mutableNotices];
            block([NSArray arrayWithArray:mutableNotices], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(Notice *)getNoticeById:(NSString *)noticeId {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"notices";
    
    NSMutableArray *archiveArray = [preferences objectForKey: savedItems];
    for (NSData* noticeObj in archiveArray) {
        Notice *notice = [NSKeyedUnarchiver unarchiveObjectWithData: noticeObj];
        if ([notice.ID intValue] == [noticeId intValue]) {
            return notice;
        }
    }
    return nil;
}

+(void)reloadNotices:(NSDictionary *)userInfo {
    
    [Notice getNoticesByEvent:[userInfo objectForKey:@"event_id"] block:^(NSArray * notices, NSError * error){
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotices" object:[userInfo objectForKey:@"event_id"] userInfo:userInfo];
            [Notice save:notices];
        }
    }];
}
@end
