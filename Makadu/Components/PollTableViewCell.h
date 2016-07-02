//
//  PollTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/15/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PollTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

+ (CGFloat)calculateHeightText:(NSString *)text width:(CGFloat)width;
@end
