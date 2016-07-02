//
//  Poll.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/31/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "Poll.h"

@implementation Poll

- (instancetype)initWithAttributes:(NSDictionary *)attributes answers:(NSArray *)aAnswers {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.talkID = [attributes valueForKeyPath:@"talk_id"];
    self.startTime = [attributes valueForKeyPath:@"start_time"];
    self.endTime = [attributes valueForKeyPath:@"end_time"];
    self.question = [attributes valueForKeyPath:@"answer"];
    self.answers = aAnswers;
    
    return self;
}

@end
