//
//  Talk.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Talk : NSObject

@property(nonatomic, strong) NSString *talkID;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *talkDescription;
@property(nonatomic, strong) NSString *startHour;
@property(nonatomic, strong) NSString *endHour;
@property(nonatomic, strong) NSString *local;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSArray *speakers;
@property(nonatomic, strong) NSArray *questions;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) PFFile *photo;
@property(nonatomic, strong) PFFile *file;

@property BOOL allowFile;
@property BOOL allowQuestion;


@end
