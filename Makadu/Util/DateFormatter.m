//
//  DateFormatter.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "DateFormatter.h"

@implementation DateFormatter

+(NSString *)formateUniversalDate:(NSString *)date withZone:(BOOL)zone {
    
    NSString *dateStr = [NSString stringWithFormat:@"%@", date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    NSString *dateFormat = nil;
    
    if (zone) {
        dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSZZZ";
    } else {
        dateFormat = @"yyyy-MM-dd";
    }
    
    [dateFormatter setDateFormat:dateFormat];

    NSDate *aDate = [dateFormatter dateFromString:dateStr];
    
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    dateStr = [dateFormatter stringFromDate:aDate];
    
    return dateStr;
}


+(NSString *)formateDateBrazilianWithDiferentFormat:(NSString *)date {
    
    NSString *dateStr = [NSString stringWithFormat:@"%@", date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    [dateFormatter setLenient:YES];
    NSDate *aDate = [dateFormatter dateFromString:dateStr];
    
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    dateStr = [dateFormatter stringFromDate:aDate];
    
    return dateStr;

}

+(NSString *)formateHourBrazilian:(NSString *)date {
    
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    [dateformat setLenient:YES];
    
    
    NSDate *datefor=[dateformat dateFromString:date];
    [dateformat setDateFormat:@"HH:mm"];
    
    NSString *dateStr=[dateformat stringFromDate:datefor];
    
    return dateStr;
}

+(NSString *)currentDate:(NSString *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    NSDate * currentDate = [dateFormatter dateFromString:date];
    return [dateFormatter stringFromDate:currentDate];
}

@end
