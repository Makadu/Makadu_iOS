//
//  PollTableViewCell.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/15/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PollTableViewCell.h"

@implementation PollTableViewCell

- (id)debugQuickLookObject
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:self.responseLabel.attributedText];
    
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.responseLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.responseLabel.frame);
}

/*
 Calculates the height of a cell with a given title, details, cancel button and max width.
 */
+ (CGFloat)calculateHeightText:(NSString *)text width:(CGFloat)width {
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    
    return size.height;
}
@end
