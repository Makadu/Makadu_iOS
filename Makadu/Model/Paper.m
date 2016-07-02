//
//  Paper.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "Paper.h"

@implementation Paper

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.title = [attributes valueForKeyPath:@"title"];
    self.abstract = [attributes valueForKeyPath:@"abstract"];
    self.authors = [attributes valueForKeyPath:@"authors"];
    self.eventId = [attributes valueForKeyPath:@"event_id"];
    self.reference = [attributes valueForKeyPath:@"reference"];
    self.createdAt = [attributes valueForKeyPath:@"created_at"];
    self.updatedAt = [attributes valueForKeyPath:@"updated_at"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.abstract forKey:@"abstract"];
    [coder encodeObject:self.authors forKey:@"authors"];
    [coder encodeObject:self.eventId forKey:@"event_id"];
    [coder encodeObject:self.reference forKey:@"reference"];
    [coder encodeObject:self.createdAt forKey:@"created_at"];
    [coder encodeObject:self.updatedAt forKey:@"created_at"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.abstract = [coder decodeObjectForKey:@"abstract"];
        self.authors = [coder decodeObjectForKey:@"authors"];
        self.eventId = [coder decodeObjectForKey:@"event_id"];
        self.reference = [coder decodeObjectForKey:@"reference"];
        self.createdAt = [coder decodeObjectForKey:@"created_at"];
        self.updatedAt = [coder decodeObjectForKey:@"created_at"];
    }
    return self;
}

+(void)save:(NSArray *)papers {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"papers";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[papers count]];
    
    for (Paper* paper in papers) {
        NSData* paperObj = [NSKeyedArchiver archivedDataWithRootObject:paper];
        [archiveArray addObject:paperObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(NSArray *)retrivePapers:(NSString *)eventId {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * papers = [NSMutableArray new];
    NSString* savedItems = @"papers";
    
    NSMutableArray *archiveArray = [preferences objectForKey: savedItems];
    for (NSData* paperObj in archiveArray) {
        Paper *paper = [NSKeyedUnarchiver unarchiveObjectWithData: paperObj];
        if ([paper.eventId intValue] == [eventId intValue]) {
            [papers addObject:paper];
        }
    }
    return papers;
}

@end
