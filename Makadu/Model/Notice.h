//
//  Notice.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notice : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *notice;
@property(nonatomic, strong) NSString *noticeDetail;
@property(nonatomic, strong) NSString *eventID;
@property BOOL visualized;

+(void)save:(NSArray *)listNotice;
+(NSArray *)getNotices:(NSString *)eventId;
+(void)updateNoticeVisualized:(NSArray *)listNotice andEventId:(NSString *)eventId;
+(void)reloadNotices:(NSDictionary *)userInfo;
+(int)getNoticesNotVisualizedByEventId:(NSString *)eventId;

#pragma mark - WebService
+(NSURLSessionDataTask *)getNoticesByEvent:(NSString *)eventId block:(void (^)(NSArray *notices, NSError *error))block;
@end
