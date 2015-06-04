//
//  Event.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/24/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Event : NSObject

@property(nonatomic, strong) NSString *eventID;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *eventDescription;
@property(nonatomic, strong) NSString *local;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *startDate;
@property(nonatomic, strong) NSString *endDate;
@property(nonatomic, strong) PFFile *fileImgEvent;
@property(nonatomic, strong) PFFile *fileImgPatronage;


@end
