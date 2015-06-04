//
//  Rating.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/3/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Rating : NSObject

@property(nonatomic, strong) NSString *ratingID;
@property(nonatomic, strong) NSString *ratingDescription;
@property(nonatomic, strong) NSNumber *note;
@property(nonatomic, strong) PFObject *talk;
@property(nonatomic, strong) PFObject *user;


@end
