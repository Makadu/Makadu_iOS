//
//  EventTableViewCell.h
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/7/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *namelabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet PFImageView *patronageImage;


+ (CGFloat)calculateHeightText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;
+ (CGFloat)calculateCellHeightWithName:(NSString *)name city:(NSString *)city date:(NSString *)date width:(CGFloat)width;

@end
