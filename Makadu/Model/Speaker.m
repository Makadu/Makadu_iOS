//
//  Speaker.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/1/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import "Speaker.h"
#import "MakaduService.h"
#import "SpeakerDAO.h"

@implementation Speaker

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }

    self.ID   = [attributes valueForKeyPath:@"id"];
    self.name = [attributes valueForKeyPath:@"name"];
    self.about = [attributes[@"about"] isKindOfClass:[NSNull class]] ? @"" : [attributes valueForKeyPath:@"about"];
    self.createdAt = [attributes valueForKeyPath:@"created_at"];
    self.updatedAt = [attributes valueForKeyPath:@"updated_at"];
    
    return self;
}

+(NSArray *)retrieveByTalkId:(NSString *)talkId {
    return [SpeakerDAO retrieveAll:[NSString stringWithFormat:@" talkId = %@", talkId]];
}

+(BOOL)existSpeakerForTalk:(NSString *)talkId {
    
    NSArray * speakers = [SpeakerDAO retrieveAll:[NSString stringWithFormat:@" talkId = %@", talkId]];
    
    if (speakers.count > 0) {
        return YES;
    }
    
    return NO;
}

@end
