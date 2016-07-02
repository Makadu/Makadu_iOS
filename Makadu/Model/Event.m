//
//  Event.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Event.h"

#import "EventDAO.h"
#import "MakaduService.h"
#import "User.h"

@implementation Event

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.title = [attributes valueForKeyPath:@"title"];
    self.eventDescription = [attributes valueForKeyPath:@"description"];
    self.venue = [attributes valueForKeyPath:@"venue"];
    self.address = [attributes valueForKeyPath:@"address"];
    self.state = [attributes valueForKeyPath:@"state"];
    self.startDate = [attributes valueForKeyPath:@"start_date"];
    self.endDate = [attributes valueForKeyPath:@"end_date"];
    self.logo = [attributes valueForKeyPath:@"logo"];
    self.logoMedium = [attributes valueForKeyPath:@"logo_medium"];
    self.city = [attributes valueForKeyPath:@"city"];
    self.updatedAt = [attributes valueForKeyPath:@"updated_at"];
    self.eventType = [attributes valueForKeyPath:@"event_type"];
    self.password = [attributes[@"password"] isKindOfClass:[NSNull class]] ? @"" : [attributes valueForKeyPath:@"password"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.eventDescription forKey:@"description"];
    [coder encodeObject:self.venue forKey:@"venue"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.state forKey:@"state"];
    [coder encodeObject:self.startDate forKey:@"startDate"];
    [coder encodeObject:self.endDate forKey:@"endDate"];
    [coder encodeObject:self.logo forKey:@"logo"];
    [coder encodeObject:self.logoMedium forKey:@"logoMedium"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.updatedAt forKey:@"updatedAt"];
    [coder encodeObject:self.imgLogo forKey:@"imgLogo"];
    [coder encodeObject:self.imgLogoMedium forKey:@"imgLogoMedium"];
    [coder encodeObject:self.eventType forKey:@"eventType"];
    [coder encodeObject:self.password forKey:@"password"];
    
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.eventDescription = [coder decodeObjectForKey:@"description"];
        self.venue = [coder decodeObjectForKey:@"venue"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.state = [coder decodeObjectForKey:@"state"];
        self.startDate = [coder decodeObjectForKey:@"startDate"];
        self.endDate = [coder decodeObjectForKey:@"endDate"];
        self.logo = [coder decodeObjectForKey:@"logo"];
        self.logoMedium = [coder decodeObjectForKey:@"logoMedium"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.updatedAt = [coder decodeObjectForKey:@"updatedAt"];
        self.imgLogo = [coder decodeObjectForKey:@"imgLogo"];
        self.imgLogoMedium = [coder decodeObjectForKey:@"imgLogoMedium"];
        self.eventType = [coder decodeObjectForKey:@"event_type"];
        self.password = [coder decodeObjectForKey:@"password"];
    }
    return self;
}

+(BOOL)existDataInDataBase:(Event *)event {
    return [EventDAO existRegisterInDatabase:event];
}

+(NSArray *)retrieveEventAll {
    return [EventDAO retrieveAll];
}

+(void)saveImageLogo:(UIImage *)image eventId:(NSString *)eventID {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [EventDAO saveImageLogo:data eventId:eventID];
}

+(void)saveImageLogoMedium:(UIImage *)image eventId:(NSString *)eventID {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [EventDAO saveImageLogoMedium:data eventId:eventID];
}

+(NSURLSessionDataTask *)getEvents:(void (^)(NSArray *events, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:@"/events" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableEvents = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            NSMutableDictionary * attr = [[NSMutableDictionary alloc] initWithDictionary:attributes];
            
            if ([[attr objectForKey:@"event_type"] isEqualToString:@"Publico"] || [[attr objectForKey:@"event_type"] isEqualToString:@"Oculto"]) {
                [attr setValue:nil forKey:@"password"];
            } else {
                [attr setObject:@"private" forKey:@"event_type"];
            }
            
            Event *event = [[Event alloc] initWithAttributes:attr];
            [mutableEvents addObject:event];
        }
        
        if (block) {
            [EventDAO createOrUpdate:mutableEvents operation:nil];
            block([NSArray arrayWithArray:mutableEvents], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

#pragma mark - Favorities

+ (void)addNewEventFavorite:(NSString *)eventId username:(NSString *)userName withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
               andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = [NSString stringWithFormat:@"http://api.makadu.net/users/%@/favorites/event/%@", [User currentUser].ID, eventId];
    
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}


+ (void)removeEventFavorite:(NSString *)eventId username:(NSString *)userName withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
               andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = [NSString stringWithFormat:@"http://api.makadu.net/users/%@/favorites/event/%@", [User currentUser].ID, eventId];
    
    [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}


+(NSURLSessionDataTask *)getEventsFavorities:(void (^)(NSArray *events, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/users/%@/favorites/event", [User currentUser].ID] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutableEvents = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            NSArray * events = [EventDAO retrieveAll:[NSString stringWithFormat:@" id = %@", [attributes objectForKey:@"id"]]];
            [mutableEvents addObjectsFromArray:events];
        }
        
        if (block) {
            [Event saveMyEvents:mutableEvents];
            block([NSArray arrayWithArray:mutableEvents], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(@[], error);
        }
    }];
}

- (void)toggleFavorite:(BOOL)isFavorite {
    Event * event = [Event new];
    NSArray *favorites = [event loadFavoritiesEvents];
    if (isFavorite) {
        if (favorites.count == 0)
            favorites = @[ self ];
        else
            favorites = [favorites arrayByAddingObject:self];
        [Event saveMyEvents:favorites];
    } else {
        [Event removeFavorite:@[self]];
    }
}

+(void)saveMyEvents:(NSArray *)events {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"my_events";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[events count]];
    
    for (Event* event in events) {
        NSData* eventObj = [NSKeyedArchiver archivedDataWithRootObject:event];
        [archiveArray addObject:eventObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(void)removeFavorite:(NSArray *)events {
    
    Event * event = [Event new];
    NSMutableArray *favorites = [[NSMutableArray alloc] initWithArray:[event loadFavoritiesEvents]];
    
    for (int i = 0; i < favorites.count; i++) {
        if ([((Event *)events[0]).ID intValue] == [((Event *)favorites[i]).ID intValue]) {
            [favorites removeObject:favorites[i]];
        }
    }
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"my_events";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[events count]];
    
    for (Event* event in favorites) {
        NSData* talkObj = [NSKeyedArchiver archivedDataWithRootObject:event];
        [archiveArray addObject:talkObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

-(NSArray *)loadFavoritiesEvents {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * listEvents = [NSMutableArray new];
    NSString* savedItems = @"my_events";
    
    NSMutableArray *archiveArray = [preferences objectForKey:savedItems];
    for (NSData* eventObj in archiveArray) {
        Event *event = [NSKeyedUnarchiver unarchiveObjectWithData: eventObj];
        [listEvents addObject:event];
    }
    return listEvents;
}

- (BOOL)isFavorite {
    NSArray * favorities = [self loadFavoritiesEvents];
    for (Event * object in favorities) {
        if ([object.ID intValue] == [self.ID intValue]) {
            return YES;
        }
    }
    return NO;
}

+(void)savePasswordEvent:(NSArray *)events {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"password_event";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[events count]];
    
    for (Event* event in events) {
        NSData* eventObj = [NSKeyedArchiver archivedDataWithRootObject:event];
        [archiveArray addObject:eventObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(BOOL)eventSavePassword:(Event *)event {
    
    NSArray * eventsWithPasswordSaved = [event loadEventsWithPassword];
    for (Event * eventWithPassword in eventsWithPasswordSaved) {
        if([eventWithPassword.ID intValue] == [event.ID intValue])
            return YES;
    }
    
    return NO;
}

-(NSArray *)loadEventsWithPassword {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSMutableArray * listEvents = [NSMutableArray new];
    NSString* savedItems = @"password_event";
    
    NSMutableArray *archiveArray = [preferences objectForKey:savedItems];
    for (NSData* eventObj in archiveArray) {
        Event *event = [NSKeyedUnarchiver unarchiveObjectWithData: eventObj];
        [listEvents addObject:event];
    }
    return listEvents;
}

@end