//
//  EventTableViewCell.m
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/7/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import "EventTableViewCell.h"

#define MIN_CELL_HEIGHT 92.f

@implementation EventTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

/*
 Calculates the height of a cell with a given title, details, cancel button and max width.
 */
+ (CGFloat)calculateHeightText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    
    return size.height;
}

/*
 Calculates the height of a cell with a given title, details, cancel button and max width.
 */
+ (CGFloat)calculateCellHeightWithName:(NSString *)name city:(NSString *)city date:(NSString *)date width:(CGFloat)width
{
    
    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]}];
    
    CGRect nameRect = [attributedName boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize nameSize = nameRect.size;
    
    
    NSAttributedString *attributedCity = [[NSAttributedString alloc] initWithString:city attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect cityRect = [attributedCity boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize citySize = cityRect.size;

    
    NSAttributedString *attributedDate = [[NSAttributedString alloc] initWithString:date attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect dateRect = [attributedDate boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize dateSize = dateRect.size;
                                                                                                      
                                                                                                      
    return nameSize.height + citySize.height + dateSize.height;
}


@end






