//
//  QuestionDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "QuestionDAO.h"
#import "Connection.h"
#import "Question.h"
#import "DateFormatter.h"
#import "AppHelper.h"

@implementation QuestionDAO

+(void)createOrUpdate:(NSArray *)questions operation:(NSString *)operation {
    for (Question *question in questions) {
        [QuestionDAO create:question];
    }
}

+(BOOL)existRegisterInDatabase:(Question *)question {
    
    int countTalks = 0;
    
    sqlite3 *dbMakadu;
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if (sqlite3_open(fileName, &dbMakadu) == SQLITE_OK) {
        sqlite3_stmt *statement;
        
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT COUNT(*) FROM Question"];
        
        if (question != nil) {
            [query appendString:@" WHERE id = "];
            [query appendFormat:@"%@", question.ID];
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
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT question, username From Question"];
        
        if (whereCondicional != nil) {
            [query appendString:@" WHERE "];
            [query appendString:whereCondicional];
        }
        [query appendFormat:@" ORDER BY date(start_time) Desc "];
        
        const char *query_stmt = [query UTF8String];
        
        if (sqlite3_prepare(dbMakadu, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Question *question = [[Question alloc] init];
                
                question.question = sqlite3_column_text(statement, 0) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] : @"";
                
                question.questioning = sqlite3_column_text(statement, 1) != nil ? [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)] : @"";
                
                [dataDB addObject:question];
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

+(void)create:(Question *)question {
    
    sqlite3_stmt *statement = nil;
    sqlite3 *dbMakadu;
    
    const char *fileName = [[AppHelper pathNameDatabase] UTF8String];
    
    if(!(sqlite3_open(fileName, &dbMakadu) == SQLITE_OK))
    {
        return;
    } else {
        sqlite3_exec(dbMakadu, "BEGIN", 0, 0, 0);
        
        NSMutableString *querySQL = [[NSMutableString alloc] initWithFormat:@"INSERT INTO Question insert into question(id, talkId, question, username) values (?,?,?,?); "];
        
        const char *query_stmt = [querySQL UTF8String];
        if(sqlite3_prepare_v2(dbMakadu, query_stmt, -1, &statement, NULL) != SQLITE_OK) {
            return;
        } else {
            sqlite3_bind_int(statement,  1, [question.ID intValue]);
            sqlite3_bind_int(statement,  2, [question.talkID intValue]);
            sqlite3_bind_text(statement, 3, [question.question UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [question.questioning UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_exec(dbMakadu, "COMMIT", 0, 0, 0);
    sqlite3_close(dbMakadu);
}

@end
