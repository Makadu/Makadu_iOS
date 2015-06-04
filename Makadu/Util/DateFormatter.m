//
//  DateFormatter.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "DateFormatter.h"

@implementation DateFormatter

+(NSString *)formateDateBrazilian:(NSString *)date withZone:(BOOL)zone
{
    NSString *dateStr = [NSString stringWithFormat:@"%@", date];
    
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = zone ? @"yyyy-MM-dd HH:mm:ss +0000" : @"yyyy-MM-dd";
    
    [dateFormatter setDateFormat:dateFormat];
    NSDate *aDate = [dateFormatter dateFromString:dateStr];
    
    // Convert date object to desired output format
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    dateStr = [dateFormatter stringFromDate:aDate];
    
    return dateStr;
}

+(NSString *)formateDateBrazilianWhithDate:(NSDate *)date withZone:(BOOL)zone {
    
    NSString *dateStr = [NSString stringWithFormat:@"%@", date];
    
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = zone ? @"yyyy-MM-dd HH:mm:ss +0000" : @"yyyy-MM-dd";
    
    [dateFormatter setDateFormat:dateFormat];
    NSDate *aDate = [dateFormatter dateFromString:dateStr];
    
    // Convert date object to desired output format
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    dateStr = [dateFormatter stringFromDate:aDate];
    
    return dateStr;
}

+(NSString *)formateDateBrazilianDateByTimeZone:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return dateStr;
}

@end
