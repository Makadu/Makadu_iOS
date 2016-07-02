//
//  EvaluationTableViewCell.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/13/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "EvaluationTableViewCell.h"
#import "Feedback.h"

@implementation EvaluationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    
    [self saveFeedback];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return TRUE;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    [self saveFeedback];
}

-(void)saveFeedback {
    
    Feedback *feedback = [Feedback new];
    feedback.question = self.question.text;
    feedback.evaluationId = self.evaluationId;
    feedback.commentary = self.commentary.text;
    feedback.eventId = self.eventId;
    feedback.value = [NSString stringWithFormat:@"%f", self.stars.rating];
    
    [Feedback save:@[feedback]];
}

-(void)keyboardWasShown:(NSNotification *)theNotification{
    
    NSDictionary *info = [theNotification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //set the insets to account for the keyboard height

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);

    self.tableview.contentInset = contentInsets;

    self.tableview.scrollIndicatorInsets = contentInsets;
    
    EvaluationTableViewCell *cell = (EvaluationTableViewCell *)[[self.tableview superview] superview];

    [self.tableview scrollToRowAtIndexPath:[self.tableview indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)keyboardWillBeHidden:(NSNotification *)theNotification{
    
    //reset the content insets
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.tableview.contentInset = contentInsets;
    
    self.tableview.scrollIndicatorInsets = contentInsets;
}


@end
