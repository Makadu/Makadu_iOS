//
//  Evaluation.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "Evaluation.h"

@implementation Evaluation

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.value = [attributes valueForKeyPath:@"value"];
    self.eventId = [attributes valueForKeyPath:@"eventId"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.value forKey:@"value"];
    [coder encodeObject:self.eventId forKey:@"eventId"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.value = [coder decodeObjectForKey:@"value"];
        self.eventId = [coder decodeObjectForKey:@"eventId"];
    }
    return self;
}

+(void)save:(NSArray *)eveluations {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"evolutions";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[eveluations count]];
    
    for (Evaluation *evaluation in eveluations) {
        NSData* evolutionObj = [NSKeyedArchiver archivedDataWithRootObject:evaluation];
        [archiveArray addObject:evolutionObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(NSArray *)retriveEvaluations:(NSString *)eventId {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * evalutions = [NSMutableArray new];
    NSString* savedItems = @"evolutions";
    
    NSMutableArray *archiveArray = [preferences objectForKey: savedItems];
    for (NSData* evaluationObj in archiveArray) {
        Evaluation *evaluation = [NSKeyedUnarchiver unarchiveObjectWithData: evaluationObj];
        if ([evaluation.eventId intValue] == [eventId intValue]) {
            [evalutions addObject:evaluation];
        }
    }
    return evalutions;
}

@end
