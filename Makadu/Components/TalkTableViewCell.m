//
//  TalkTableViewCell.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkTableViewCell.h"

@implementation TalkTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)calculateCellHeightWithTitle:(NSString *)hourAndTitle localAndDuration:(NSString *)localAndDuration speakers:(NSString *)speakers width:(CGFloat)width {
    
    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:hourAndTitle attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
    
    CGRect nameRect = [attributedName boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize nameSize = nameRect.size;
    
    
    NSAttributedString *attributedCity = [[NSAttributedString alloc] initWithString:localAndDuration attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect cityRect = [attributedCity boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize citySize = cityRect.size;
    
    
    NSAttributedString *attributedDate = [[NSAttributedString alloc] initWithString:speakers attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect dateRect = [attributedDate boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize dateSize = dateRect.size;
    
    
    return nameSize.height + citySize.height + dateSize.height;
}


+ (CGFloat)calculateCellHeightWithTitleLabel:(UILabel *)hourAndTitle localAndDuration:(UILabel *)localAndDuration speakers:(UILabel *)speakers width:(CGFloat)width {
    
    
    //Calculate Height of the label Hour and Title
    CGSize constraintHourAndTitle = CGSizeMake(hourAndTitle.frame.size.width, 2000.0f);
    CGSize sizeHourAndTitle;
    
    NSStringDrawingContext *contextHourAndTitle = [[NSStringDrawingContext alloc] init];
    
    CGSize boundingBoxHourAndTitle = [hourAndTitle.text boundingRectWithSize:constraintHourAndTitle
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:hourAndTitle.font}
                                                  context:contextHourAndTitle].size;
    
    sizeHourAndTitle = CGSizeMake(ceil(boundingBoxHourAndTitle.width), ceil(boundingBoxHourAndTitle.height));
    
    
    
    CGSize constraintLocalAndDuration = CGSizeMake(localAndDuration.frame.size.width, 2000.0f);
    CGSize sizeLocalAndDuration;
    
    //Calculate Height of the label local and duration
    NSStringDrawingContext *contextLocalAndDuration = [[NSStringDrawingContext alloc] init];
    CGSize boundingBoxLocalAndDuration = [localAndDuration.text boundingRectWithSize:constraintLocalAndDuration
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:localAndDuration.font}
                                                  context:contextLocalAndDuration].size;
    
    sizeLocalAndDuration = CGSizeMake(ceil(boundingBoxLocalAndDuration.width), ceil(boundingBoxLocalAndDuration.height));
    
    
    
    //Calculate Height of the label Speakers
    CGSize constraintSpeakers = CGSizeMake(speakers.frame.size.width, 2000.0f);
    CGSize sizeSpeakers;
    
    NSStringDrawingContext *contextSpeakers = [[NSStringDrawingContext alloc] init];
    CGSize boundingBoxSpeakers = [speakers.text boundingRectWithSize:constraintSpeakers
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:speakers.font}
                                                  context:contextSpeakers].size;
    
    sizeSpeakers = CGSizeMake(ceil(boundingBoxSpeakers.width), ceil(boundingBoxSpeakers.height));
    
    
    
    return sizeHourAndTitle.height + sizeLocalAndDuration.height + sizeSpeakers.height;
}

@end
