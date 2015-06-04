//
//  TalkViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkViewController.h"

#import "DateFormatter.h"
#import "Connection.h"
#import "Cloud.h"
#import "Schedule.h"
#import "Analitcs.h"
#import "Messages.h"
#import "Rating.h"

#import "QuestionDAO.h"
#import "TalkDAO.h"
#import "RatingDAO.h"

#import "TalkDescriptionTableViewCell.h"
#import "TalkSpeakerTableViewCell.h"
#import "TalkQuestionTableViewCell.h"
#import "QuestionViewController.h"


@interface TalkViewController ()

@property (nonatomic, strong) NSArray *listQuestions;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (strong, nonatomic) NSNumber *ratingNote;
@property (strong, nonatomic) Rating *ratingSelf;

@end

@implementation TalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.talk.title;
    self.localLabel.text = [NSString stringWithFormat:@"%@ - %@ %@", self.talk.local, [DateFormatter formateDateBrazilianWhithDate:self.talk.date withZone:YES], self.talk.startHour];
    
    self.questionButton.hidden = !self.talk.allowQuestion;
    self.downloadButton.hidden = !self.talk.allowFile;
    
    self.ratingSelf = [RatingDAO fetchRatingByUserAndTalk:[PFUser currentUser] talk:self.talkObject];
    
    // Setup control using iOS7 tint Color
    self.starRating.backgroundColor  = [UIColor whiteColor];
    self.starRating.starImage = [UIImage imageNamed:@"star.png"];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    self.starRating.maxRating = 5.0;
    self.starRating.delegate = self;
    self.starRating.horizontalMargin = 12;
    self.starRating.editable = YES;
    self.starRating.rating = [self.ratingSelf.note floatValue];
    self.starRating.displayMode=EDStarRatingDisplayFull;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    if (self.talkObject != nil) {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Detalhes da Palestra" description:@"O usuário acessou os detalhes da palestra" event:self.eventObject talk:[TalkDAO fetchTalkByTalkId:self.talk]];
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Detalhe da Palestras" description:@"Usuário sem acesso a conexão de dados."];
    }
    
    [self fetchQuestions];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self.talk.speakers count];
        case 2:
            return [self.listQuestions count];
        default:
            return 0;
            break;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        static NSString * scheduleDetailTableCell = @"talkCell";
        TalkDescriptionTableViewCell *cell = (TalkDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
    
        cell.descriptionTextView.text = self.talk.talkDescription;
        return cell;
    
    } else if (indexPath.section == 1) {
        static NSString * scheduleDetailTableCell = @"talkSpeakerCell";
        TalkSpeakerTableViewCell *cell = (TalkSpeakerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
        
        cell.speakerNameLabel.text = [self.talk.speakers objectAtIndex:indexPath.row][@"full_name"];
        cell.aboutSpeakerTextView.text = [self.talk.speakers objectAtIndex:indexPath.row][@"about_speaker"];
        return cell;
    } else if (indexPath.section == 2) {
        static NSString * scheduleDetailTableCell = @"talkQuestionCell";
        TalkQuestionTableViewCell *cell = (TalkQuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
        
        Question *question = [self.listQuestions objectAtIndex:indexPath.row];
        
        cell.questionLabel.text = question.question;
        
        NSString * questioning = question.questioning;
        if (!questioning)
            questioning = @"";
        cell.questionigLabel.text = [NSString stringWithFormat:@"%@ %@", questioning, question.date];
        
        return cell;
    }
    return nil;
}

#pragma mark - Other methods Table View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * header = [[UIView alloc] init];
    UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, [UIScreen mainScreen].bounds.size.width, 13)];
    
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [header addSubview:lblHeader];
    
    header.backgroundColor = [UIColor colorWithRed:(33.0/255.0) green:(145.0/255.0) blue:(114.0/255.0) alpha:1];
    
    switch (section) {
        case 0:
            lblHeader.text = @"Sobre a Ativedade";
            break;
        case 1:
            lblHeader.text = @"Sobre o Palestrante";
            break;
        case 2:
            lblHeader.text = @"Perguntas";
        default:
            break;
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 140;
    } else if (indexPath.section == 1) {
        return 166;
    } else {
        Question * question = [self.listQuestions objectAtIndex:indexPath.row];
        CGFloat height = [TalkQuestionTableViewCell calculateCellHeightWithQuestion:question.question questioning:[NSString stringWithFormat:@"%@ %@", question.questioning, question.date] width:290];
        return height + 52;
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([Connection existConnection]) {
        if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
            QuestionViewController *questionViewController = [segue destinationViewController];
            [questionViewController setTalk:self.talk];
            [questionViewController setTalkObject:self.talkObject];
            [questionViewController setEventObject:self.eventObject];
            
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Detalhes da Palestra" description:@"O usuário clicou em perguntar da palestra" event:self.eventObject talk:[TalkDAO fetchTalkByTalkId:self.talk]];
        }
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Detalhes da palestra" description:[NSString stringWithFormat:@"O usuário clicou em perguntar da palestra %@, mas ocorreu um erro - usuário sem acesso a internet.", self.talk.title]];
        [Messages failMessageWithTitle:nil andMessage:@"Sem internet no momento, tente novamente mais tarde"];
    }
}


#pragma mark - fetch

-(void)fetchQuestions {
    PFObject * talkObject = [TalkDAO fetchTalkByTalkId:self.talk];
    if (talkObject == nil) {
        self.listQuestions = nil;
        [self.tableView reloadData];
    } else {
        [QuestionDAO fetchQuestionByTalk:talkObject questions:^(NSArray * objects) {
            self.listQuestions = objects;
            [self.tableView reloadData];
        } failure:^(NSString * error) {
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - Action

- (IBAction)tapDownload:(id)sender {
    
    if([Connection existConnection]) {
        if(self.talk.file) {
            NSString * urlFile = self.talk.file.url;
            [Cloud sendMail:[[PFUser currentUser] email] url:urlFile talkName:self.talk.title];
        } else {
            [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"O material será enviado para %@ quando disponível", [[PFUser currentUser] email]]];
            [Schedule saveDataScheduleWithUser:[PFUser currentUser] talk:self.talk];
        }
    } else {
        [Messages failMessageWithTitle:nil andMessage:@"Sem internet no momento, tente novamente mais tarde"];
    }
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    self.ratingNote = [NSNumber numberWithFloat:rating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Avaliação de %@", [PFUser currentUser][@"full_name"]]
                                                   delegate:self
                                          cancelButtonTitle:@"Enviar"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@", [alertView textFieldAtIndex:0].text);
    
    Rating *rating = [Rating new];
    rating.user = [PFUser currentUser];
    rating.note = self.ratingNote;
    rating.talk = self.talkObject;
    rating.ratingDescription = [alertView textFieldAtIndex:0].text;
    
    [RatingDAO saveRating:rating];
}
@end
