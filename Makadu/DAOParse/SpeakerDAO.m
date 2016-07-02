//
//  SpeakerDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/1/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import "SpeakerDAO.h"
#import "AppHelper.h"

@implementation SpeakerDAO

+(void)createOrUpdate:(NSArray *)speakers operation:(NSString *)operation {
    for (Speaker *speaker in speakers) {
        if ([SpeakerDAO existRegisterInDatabase:speaker]) {
            [SpeakerDAO update:speaker];
        } else {
            [SpeakerDAO create:speaker];
        }
    }
}

+(BOOL)existRegisterInDatabase:(Speaker *)speaker {
    
    int countTalks = 0;
    
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT COUNT(*) FROM Speaker"];
        
        if (speaker != nil) {
            [query appendString:@" WHERE id = "];
            [query appendFormat:@"%@", speaker.ID];
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

+(NSArray *)retrieveAll {
    return [self retrieveAll:nil];
}

+(NSArray *)retrieveAll:(NSString *)whereCondicional {
    
    NSMutableArray *dataDB = [[NSMutableArray alloc] init];
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT s.name, s.about FROM TalkSpeaker ts left join speaker s on ts.speakerId = s.id left join talk t on ts.talkId = t.id"];
        
        if (whereCondicional != nil) {
            [query appendString:@" WHERE "];
            [query appendString:whereCondicional];
        }
        [query appendFormat:@" ORDER BY date(start_time) Desc "];
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Speaker *speaker = [[Speaker alloc] init];
                
                speaker.name = sqlite3_column_text(statement, 0) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] : @"";
                
                speaker.about = sqlite3_column_text(statement, 1) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] : @"";
                
                [dataDB addObject:speaker];
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

+(void)create:(Speaker *)speaker {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"INSERT INTO Speaker (id, name, about, created_at, updated_at) VALUES (?,?,?,?,?)"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            
            NSString * speakerAbout = [speaker.about isKindOfClass:[NSNull class]] ? @"" : speaker.about;
            
            sqlite3_bind_int(statement,  1,  [speaker.ID intValue]);
            sqlite3_bind_text(statement, 2,  [speaker.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [speakerAbout UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [speaker.createdAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [speaker.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)update:(Speaker *)speaker {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"UPDATE Speaker Set name = ?, about = ?, created_at = ?, updated_at = ? where id = ?"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_text(statement, 2,  [speaker.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [speaker.about UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [speaker.createdAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [speaker.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 6,  [speaker.ID intValue]);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)delete:(NSString *)eventId {
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    NSString *sql_str=[NSString stringWithFormat:@"DELETE FROM TalkSpeaker where talkid in (Select id from talk where eventid = %d)",[eventId intValue]];
    const char *sql = [sql_str UTF8String];
    
    sqlite3 *database;
    
    if(sqlite3_open(fileName, &database) == SQLITE_OK) {
        sqlite3_stmt *deleteStmt;
        if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(deleteStmt) != SQLITE_DONE ) {
                NSLog( @"Error: %s", sqlite3_errmsg(database) );
            } else {
                NSLog(@"No Error");
            }
        }
        sqlite3_finalize(deleteStmt);
    }
    sqlite3_close(database);
}

@end
