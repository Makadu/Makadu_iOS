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
    
    
    return nameSize.height + citySize.height + dateSize.height + 44;
}

@end
