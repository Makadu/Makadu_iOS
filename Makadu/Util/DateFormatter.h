//
//  DateFormatter.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatter : NSObject

+(NSString *)formateDateBrazilian:(NSString *)date withZone:(BOOL)zone;
+(NSString *)formateDateBrazilianWhithDate:(NSDate *)date withZone:(BOOL)zone;
+(NSString *)formateDateBrazilianDateByTimeZone:(NSDate *)date;

@end
