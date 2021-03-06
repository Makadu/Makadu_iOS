//
//  DateFormatter.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatter : NSObject

+(NSString *)formateUniversalDate:(NSString *)date withZone:(BOOL)zone;
+(NSString *)formateDateBrazilianWithDiferentFormat:(NSString *)date;
+(NSString *)formateHourBrazilian:(NSString *)date;

+(NSString *)currentDate:(NSString *) date;
@end
