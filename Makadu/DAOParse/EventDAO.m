//
//  EventDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventDAO.h"
#import "DateFormatter.h"

@implementation EventDAO


+(void)createOrUpdate:(NSArray *)events operation:(NSString *)operation {
    
    [EventDAO deleteEvents];
    for (Event *event in events) {
        [EventDAO create:event];
    }
}

+(BOOL)existRegisterInDatabase:(Event *)event {
    
    int countEvents = 0;
    
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT COUNT(*) FROM Event "];
        
        if (event != nil) {
            [query appendString:@" WHERE id = "];
            [query appendFormat:@"%@", @"18"];
            [query appendFormat:@"And id = %@", @"30"];
        }
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                countEvents = sqlite3_column_int(statement, 0);
            }
            
            sqlite3_finalize(statement);
        } else {
            return NO;
        }
        
        sqlite3_close(dbMakadu);
    } else {
        return NO;
    }
    
    if (countEvents > 0) {
        return YES;
    } else {
        return NO;
    }
}

+(void)create:(Event *)event {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"INSERT INTO Event (id, title, description, venue, address, city, state, start_date, end_date, updated_at, logo, logo_medium, type, password) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_int(statement,  1,  [event.ID intValue]);
            sqlite3_bind_text(statement, 2,  [event.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [event.eventDescription UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [event.venue UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [event.address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6,  [event.city UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7,  [event.state UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8,  [event.startDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9,  [event.endDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 10, [event.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 11, [event.logo UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 12, [event.logoMedium UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 13, [event.eventType UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 14, [event.password UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)update:(Event *)event {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"UPDATE Event Set title = ?, description = ?, venue = ?, address = ?, city = ?, state = ?, start_date = ?, end_date = ?, updated_at = ?, logo = ?, logo_medium = ?, type = ?, password = ? where id = ?"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_text(statement, 1,  [event.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2,  [event.eventDescription UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,  [event.venue UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,  [event.address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,  [event.city UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6,  [event.state UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7,  [event.startDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8,  [event.endDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9, [event.updatedAt UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,10, [event.logo UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,11, [event.logoMedium UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 12, [event.ID intValue]);
            sqlite3_bind_text(statement,13, [event.eventType UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,14, [event.password UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}


+ (NSArray *)retrieveAll
{
    return [self retrieveAll:nil];
}

+ (NSArray *)retrieveAll:(NSString *)whereCondicional {
    
    NSMutableArray *dataDB = [[NSMutableArray alloc] init];
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT distinct title, description, venue, address, city, state, start_date, end_date, id, img_logo, img_logo_medium, type, password FROM Event"];
        
        if (whereCondicional != nil) {
            [query appendString:@" WHERE "];
            [query appendString:whereCondicional];
        }
        
        [query appendFormat:@" ORDER BY date(start_date) DESC "];
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Event *event = [[Event alloc] init];
                
                
                event.title = sqlite3_column_text(statement, 0) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] : @"";
                
                event.eventDescription = sqlite3_column_text(statement, 1) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] : @"";
                
                event.venue = sqlite3_column_text(statement, 2) != nil ? [[NSString alloc] initWithUTF8String:
                                                                          (const char *) sqlite3_column_text(statement, 2)] : @"";
                
                event.address = sqlite3_column_text(statement, 3) != nil ? [[NSString alloc] initWithUTF8String:
                                                                            (const char *) sqlite3_column_text(statement, 3)] : @"";
                
                event.city = sqlite3_column_text(statement, 4) != nil ? [[NSString alloc] initWithUTF8String:
                                                                         (const char *) sqlite3_column_text(statement, 4)] : @"";
                
                event.state = sqlite3_column_text(statement, 5) != nil ? [[NSString alloc] initWithUTF8String:
                                                                          (const char *) sqlite3_column_text(statement, 5)] : @"";
                
                event.startDate = sqlite3_column_text(statement, 6) != nil ? [[NSString alloc]
                                                                              initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)] : @"";
                
                event.endDate = sqlite3_column_text(statement, 7) != nil ? [[NSString alloc]
                                                                            initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)] : @"";
                event.ID = sqlite3_column_text(statement, 8) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)] : @"";
                
                
                const void *ptr = sqlite3_column_blob(statement, 9);
                int size = sqlite3_column_bytes(statement, 9);
                event.imgLogo = [[NSData alloc] initWithBytes:ptr length:size];
                
                const void *ptrMedium = sqlite3_column_blob(statement, 10);
                int sizeMedium = sqlite3_column_bytes(statement, 10);
                event.imgLogoMedium = [[NSData alloc] initWithBytes:ptrMedium length:sizeMedium];
                
                event.eventType = sqlite3_column_text(statement, 11) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)] : @"";
                
                event.password = sqlite3_column_text(statement, 12) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)] : @"";
                
                [dataDB addObject:event];
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

+(void)saveImageLogo:(NSData *)data eventId:(NSString *)eventId {
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"UPDATE Event Set img_logo = ? where id = ?"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            
            sqlite3_bind_blob(statement, 1, [data bytes], (int)[data length], SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, [eventId intValue]);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)saveImageLogoMedium:(NSData *)data eventId:(NSString *)eventId {
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"UPDATE Event Set img_logo_medium = ? where id = ?"];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            
            sqlite3_bind_blob(statement, 1, [data bytes], (int)[data length], SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, [eventId intValue]);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

+(void)deleteEvents {
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    NSString *sql_str=[NSString stringWithFormat:@"DELETE FROM Event"];
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
@end
