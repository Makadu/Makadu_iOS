//
//  TalkQuestionTableViewCell.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkQuestionTableViewCell.h"

@implementation TalkQuestionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)calculateCellHeightWithQuestion:(NSString *)question questioning:(NSString *)questioning width:(CGFloat)width {
    
    NSAttributedString *attributedQuestion = [[NSAttributedString alloc] initWithString:question attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
    
    CGRect questionRect = [attributedQuestion boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize questionSize = questionRect.size;
    
    
    NSAttributedString *attributedQuestioning = [[NSAttributedString alloc] initWithString:questioning attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect questioningRect = [attributedQuestioning boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    CGSize questioningSize = questioningRect.size;
    
    
    return questionSize.height + questioningSize.height;
}

@end
