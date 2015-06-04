//
//  Question.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property(nonatomic, strong) NSString *questionID;
@property(nonatomic, strong) NSString *question;
@property(nonatomic, strong) NSString *questioning;
@property(nonatomic, strong) NSString *date;

@end
