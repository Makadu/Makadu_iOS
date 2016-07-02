//
//  Feedback.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "Feedback.h"

@implementation Feedback

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.question forKey:@"question"];
    [coder encodeObject:self.value forKey:@"value"];
    [coder encodeObject:self.evaluationId forKey:@"evaluationId"];
    [coder encodeObject:self.commentary forKey:@"commentary"];
    [coder encodeObject:self.eventId forKey:@"event_id"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.question = [coder decodeObjectForKey:@"question"];
        self.value = [coder decodeObjectForKey:@"value"];
        self.evaluationId = [coder decodeObjectForKey:@"evaluationId"];
        self.commentary = [coder decodeObjectForKey:@"commentary"];
        self.eventId = [coder decodeObjectForKey:@"event_id"];
    }
    return self;
}

+(void)save:(NSArray *)feedbacks {
    
    NSMutableArray *arrayfeeds = [[NSMutableArray alloc] initWithArray:[Feedback retriveFeedbacks]];
    NSMutableArray *feeds = [arrayfeeds copy];
    Feedback *feedback = feedbacks[0];

    for (Feedback *feed in feeds) {
        if ([feed.question isEqualToString:feedback.question]) {
            [arrayfeeds removeObject:feed];
        }
    }
    
    [arrayfeeds addObject:feedback];
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"feedbacks";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[arrayfeeds count]];
    
    for (Feedback* feedback in arrayfeeds) {
        NSData* feedbackObj = [NSKeyedArchiver archivedDataWithRootObject:feedback];
        [archiveArray addObject:feedbackObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}


+(NSArray *)retriveFeedbacks {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * feedbacks = [NSMutableArray new];
    NSString* savedItems = @"feedbacks";
    
    NSMutableArray *archiveArray = [preferences objectForKey: savedItems];
    for (NSData* feedbackObj in archiveArray) {
        Feedback *feedback = [NSKeyedUnarchiver unarchiveObjectWithData: feedbackObj];
        [feedbacks addObject:feedback];
    }
    return feedbacks;
}

+(void)removeAllFeedbacks {

    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:@"feedbacks"]) {
            [defs removeObjectForKey:key];
        }
    }
    [defs synchronize];
}

@end
