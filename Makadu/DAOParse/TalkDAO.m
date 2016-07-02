//
//  TalkDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkDAO.h"

#import "Speaker.h"
#import "Connection.h"
#import "SpeakerDAO.h"


@implementation TalkDAO

+(void)createOrUpdate:(NSArray *)talks eventId:(NSString *)eventId operation:(NSString *)operation {
    
    [TalkDAO deleteTalks:eventId];
    for (Talk *talk in talks) {
        [TalkDAO create:talk];
    }
}

+(BOOL)existRegisterInDatabase:(Talk *)talk eventId:(NSString *)eventId {
    
    int countTalks = 0;
    
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT COUNT(*) FROM Talk Where eventId = %@", eventId];
        
        if (talk != nil) {
            [query appendString:@" And id = "];
            [query appendFormat:@"%@", talk.ID];
        }
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                countTalks = sqlite3_column_int(statement, 0);
            }
            
            sqlite3_finalize(statement);
        } else {
            return NO;
        }
        
        sqlite3_close(dbMakadu);
    } else {
        return NO;
    }
    
    if (countTalks > 0) {
        return YES;
    } else {
        return NO;
    }
}

+(void)create:(Talk *)talk {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"INSERT INTO Talk (id, title, room, speakers, start_time, end_time, questions, downloads, updated_at, eventId, description, favorite, interactive) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_int(statement,  1,  [talk.ID intValue]);
            sqlite3_bind_text(statement, 2,  [talk.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [talk.room UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [talk.speakers UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [talk.startTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6,  [talk.endTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement,  7,  talk.questions);
            sqlite3_bind_int(statement,  8,  talk.downloads);
            sqlite3_bind_text(statement, 9,  [talk.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 10, [talk.eventId intValue]);
            sqlite3_bind_text(statement,11,  [talk.talkDescription UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 12,  talk.favorite);
            sqlite3_bind_int(statement, 13,  talk.interactive);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)update:(Talk *)talk {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"UPDATE Talk Set title = ?, room = ?, speakers = ?, start_time = ?, end_time = ?, questions = ?, downloads = ?, updated_at = ?, description = ?, interactive = ? where id = ?"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_text(statement, 1,  [talk.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2,  [talk.room UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [talk.speakers UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [talk.startTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [talk.endTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement,  6,  talk.questions);
            sqlite3_bind_int(statement,  7,  talk.downloads);
            sqlite3_bind_text(statement, 8,  [talk.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9,  [talk.talkDescription UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement,  10,  talk.interactive);
            sqlite3_bind_int(statement, 11, [talk.eventId intValue]);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)deleteTalks:(NSString *)eventId {
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    NSString *sql_str=[NSString stringWithFormat:@"DELETE FROM Talk Where eventId = %d",[eventId intValue]];
    const char *sql = [sql_str UTF8String];
    
    sqlite3 *database;
    
    if(sqlite3_open(fileName, &database) == SQLITE_OK)
    {
        sqlite3_stmt *deleteStmt;
        if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) == SQLITE_OK)
        {
            
            if(sqlite3_step(deleteStmt) != SQLITE_DONE )
            {
                NSLog( @"Error: %s", sqlite3_errmsg(database) );
            }
            else
            {
                NSLog(@"No Error");
            }
        }
        sqlite3_finalize(deleteStmt);
    }
    sqlite3_close(database);
}

+(NSArray *)retrieveAll {
    return [self retrieveAll:nil];
}

+(NSArray *)retrieveAll:(NSString *)whereCondicional {
    
    NSMutableArray *dataDB = [[NSMutableArray alloc] init];
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT title, room, speakers, start_time, end_time, questions, downloads, id, eventId, description, favorite, interactive FROM Talk"];
        
        if (whereCondicional != nil) {
            [query appendString:@" WHERE "];
            [query appendString:whereCondicional];
        }
        [query appendFormat:@" ORDER BY datetime(start_time) ASC "];
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Talk *talk = [[Talk alloc] init];
                
                talk.title = sqlite3_column_text(statement, 0) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] : @"";
                
                talk.room = sqlite3_column_text(statement, 1) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] : @"";
                
                talk.speakers = sqlite3_column_text(statement, 2) != nil ? [[NSString alloc] initWithUTF8String:
                                                                          (const char *) sqlite3_column_text(statement, 2)] : @"";
                
                talk.startTime = sqlite3_column_text(statement, 3) != nil ? [[NSString alloc] initWithUTF8String:
                                                                            (const char *) sqlite3_column_text(statement, 3)] : @"";
                
                talk.endTime = sqlite3_column_text(statement, 4) != nil ? [[NSString alloc] initWithUTF8String:
                                                                         (const char *) sqlite3_column_text(statement, 4)] : @"";
                
                talk.questions = sqlite3_column_int(statement, 5);

                talk.downloads = sqlite3_column_int(statement, 6);
                
                talk.ID = sqlite3_column_text(statement, 7) != nil ? [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)]: @"";
                talk.eventId = sqlite3_column_text(statement, 8) != nil ? [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)]: @"";
                
                talk.talkDescription = sqlite3_column_text(statement, 9) != nil ? [[NSString alloc] initWithUTF8String:
                                                                           (const char *) sqlite3_column_text(statement, 9)] : @"";
                talk.favorite = sqlite3_column_int(statement, 10);
                
                talk.interactive = sqlite3_column_int(statement, 11);
                
                [dataDB addObject:talk];
            }
            
            sqlite3_finalize(statement);
        } else {
            return nil;
        }
        sqlite3_close(dbMakadu);
    } else {
        return nil;
    }
    
    return dataDB;
}

+(void)linkSpeakerATalk:(NSString *)talkId speakers:(NSArray *)speakers {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"INSERT INTO TalkSpeaker (talkId, speakerId) VALUES "];
        
        for (int i = 0; i < speakers.count; i++) {
            [querySQL appendFormat:@"(%@,%@)", talkId, ((Speaker *)[speakers objectAtIndex:i]).ID];
            
            if (i < speakers.count - 1) {
                [querySQL appendFormat:@","];
            }
        }
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}


#pragma mark - Favorities
+ (NSArray *)sortedTalkArray:(NSArray *)talks {
    return [talks sortedArrayUsingComparator:[[self class] _orderByTimeThenRoomComparator]];
}

+ (NSComparator)_orderByTimeThenRoomComparator {
    return ^NSComparisonResult(Talk *talk1, Talk *talk2) {
        NSComparisonResult timeResult = [talk1.startTime compare:talk2.startTime];
        if (timeResult != NSOrderedSame) {
            return timeResult;
        }
        return [talk1.startTime compare:talk2.startTime];
    };
}

+(void)saveFavorities:(NSArray *)talks {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"favorities_talks";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[talks count]];
    
    for (Talk* talk in talks) {
        NSData* talkObj = [NSKeyedArchiver archivedDataWithRootObject:talk];
        [archiveArray addObject:talkObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

+(void)removeFavorite:(NSArray *)talks eventId:(NSString *)eventId {
    
    Talk * talk = [Talk new];
    NSMutableArray *favorites = [[NSMutableArray alloc] initWithArray:[talk loadFavoritiesTalks:eventId]];
    
    for (int i = 0; i < favorites.count; i++) {
        if ([((Talk *)talks[0]).ID intValue] == [((Talk *)favorites[i]).ID intValue]) {
            [favorites removeObject:favorites[i]];
        }
    }
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"favorities_talks";
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:[talks count]];
    
    for (Talk* talk in favorites) {
        NSData* talkObj = [NSKeyedArchiver archivedDataWithRootObject:talk];
        [archiveArray addObject:talkObj];
    }
    
    [preferences setObject:archiveArray forKey: savedItems];
    [preferences synchronize];
}

@end