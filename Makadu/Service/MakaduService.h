//
//  MakaduService.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 10/25/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#import <AFNetworking/AFNetworking.h>


@interface MakaduService : AFHTTPSessionManager

+(instancetype) sharedInstance;

@end
