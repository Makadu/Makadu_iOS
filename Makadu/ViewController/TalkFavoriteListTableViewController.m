//
//  TalkFavoriteListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkFavoriteListTableViewController.h"

#import "Connection.h"
#import "Cloud.h"
#import "Schedule.h"
#import "Messages.h"
#import "Localytics.h"

#import "TalkTableViewCell.h"
#import "TalkViewController.h"
#import "QuestionViewController.h"

#import "TalkFavoriteDAO.h"
#import "TalkDAO.h"

@interface TalkFavoriteListTableViewController ()

@property (nonatomic, strong) NSArray * listTalk;
@property (nonatomic, strong) NSArray * listDateTalk;
@property (nonatomic, strong) Event * event;

@property (nonatomic, strong) NSIndexPath *indexPathSelected;

@end

@implementation TalkFavoriteListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    self.event = self.showEventViewController.event;
    
    self.navigationController.navigationBar.topItem.title = @"Favoritos";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestTalks) forControlEvents:UIControlEventValueChanged];
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Carregando a programação..." mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    self.indexPathSelected = nil;
    
    [self fetchTalks];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [Localytics tagScreen:@"List Favorities"];
    
    [self fetchTalks];
    
    self.indexPathSelected = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.listDateTalk count] > 0) {
        return [self.listDateTalk count];
    } else {
        if (![Connection existConnection]) {
            UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageLabel.text = @"Não foi possível carregar os dados.";
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
            messageLabel.tag = 3000;
            [messageLabel sizeToFit];
            
            self.tableView.backgroundView = messageLabel;
        }
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.listTalk objectAtIndex:section][@"group"] count] > 0)
        return [[self.listTalk objectAtIndex:section][@"group"] count];
    return 0;
}

#pragma mark - Table view delagate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * cellEvent = @"listTalkCell";
    TalkTableViewCell *cell = (TalkTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
    
    [cell.btnFavorite setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];
    [cell.btnFavorite setImage:[UIImage imageNamed:@"star_empty.png"] forState:UIControlStateSelected];
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setTintColor:[UIColor blackColor]];
    
    if (cell == nil) {
        cell = [[TalkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEvent];
    }
    
    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    Talk * talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    
    cell.btnFavorite.backgroundColor = cell.backgroundColor;
    cell.btnDownload.backgroundColor = cell.backgroundColor;
    cell.btnQuestion.backgroundColor = cell.backgroundColor;
    
    cell.titleAndHourlabel.text = [NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title];
    [cell.titleAndHourlabel sizeToFit];
    cell.localAndDuration.text = [NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour];
    [cell.localAndDuration sizeToFit];
    cell.speakers.text = [self showSpeakers:talk.speakers];
    [cell.speakers sizeToFit];
    
    cell.btnDownload.hidden = !talk.allowFile;
    cell.btnQuestion.hidden = !talk.allowQuestion;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Talk * talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    
    CGFloat height = [TalkTableViewCell calculateCellHeightWithTitle:[NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title] localAndDuration:[NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour] speakers:[self showSpeakers:talk.speakers] width:[[UIScreen mainScreen] bounds].size.width - 40];
    
    height += 85;
    
    if (!talk.allowFile && !talk.allowQuestion)
        height -= 24;
    
    if ([talk.speakers count] == 0)
        height -= 40;
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[UIView alloc] init];
    UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, [UIScreen mainScreen].bounds.size.width, 13)];
    lblHeader.text = [self.listDateTalk objectAtIndex:section][@"date"];
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [header addSubview:lblHeader];
    
    header.backgroundColor = [UIColor colorWithRed:(33.0/255.0) green:(145.0/255.0) blue:(114.0/255.0) alpha:1];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 17;
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"talkSegue"]) {
        NSIndexPath *indexPath;
        if (self.indexPathSelected != nil) {
            indexPath = self.indexPathSelected;
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        TalkViewController *talkViewController = [segue destinationViewController];
        
        Talk * talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
        
//        PFObject * talkObject = [TalkDAO fetchTalkByTalkId:talk];
        
        [talkViewController setTalk:talk];
//        [talkViewController setTalkObject:talkObject];
        [talkViewController setEventObject:self.showEventViewController.eventObject];
        
    } else if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        QuestionViewController *questionViewController = [segue destinationViewController];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        Talk * talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
//        PFObject * talkObject = [TalkDAO fetchTalkByTalkId:talk];
        
        [questionViewController setEventObject:self.showEventViewController.eventObject];
//        [questionViewController setTalkObject:talkObject];
        [questionViewController setTalk:talk];
    }
}


#pragma mark - fetch

-(void)fetchTalks {
    
    if (self.showEventViewController.eventObject == nil) {
        self.listTalk = nil;
        self.listDateTalk = nil;
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    } else {
        [TalkFavoriteDAO fetchTalkFavoriteByEvent:self.showEventViewController.eventObject talks:^(NSArray * talks){
            self.listTalk = talks;
            NSArray *talkDatas = [self sortedDataWithDictionary:[self groupedTalk]];
            self.listTalk = talkDatas;
            self.listDateTalk = talkDatas;
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        } failure:^(NSString * error) {
            NSLog(@"%@", error);
        }];
    }
}



#pragma mark - Grouped Talks by date

-(NSDictionary *)groupedTalk {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    // Sparse dictionary, containing keys for "days with posts"
    NSMutableDictionary *daysWithTalks = [NSMutableDictionary dictionary];
    [self.listTalk enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *dateString = [formatter stringFromDate:((Talk *)obj).date]; // EDIT 1
        // Check to see if we have a day already.
        NSMutableArray *talks = [daysWithTalks objectForKey: dateString /*uniqueDay*/];
        // If not, create it
        if (talks == nil || (id)talks == [NSNull null])
        {
            talks = [NSMutableArray arrayWithCapacity:1];
            [daysWithTalks setObject:talks forKey: dateString /*uniqueDay*/];
        }
        // add post to day
        [talks addObject:obj];
    }];
    
    return daysWithTalks;
}

-(NSArray *)sortedDataWithDictionary:(NSDictionary *)data {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    // Sort Dictionary Keys by Date
    NSArray *unsortedSectionTitles = [data allKeys];
    NSArray *sortedSectionTitles = [unsortedSectionTitles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [formatter dateFromString:obj1];
        NSDate *date2 = [formatter dateFromString:obj2];
        return [date1 compare:date2];
    }];
        
    NSMutableArray *sortedData = [NSMutableArray arrayWithCapacity:sortedSectionTitles.count];
        
    // Put Data into correct format:
    [sortedSectionTitles enumerateObjectsUsingBlock:^(NSString *dateString, NSUInteger idx, BOOL *stop) {
        NSArray *group = data[dateString];
        NSDictionary *dictionary = @{ @"date":dateString,
                                          @"group":group };
        [sortedData addObject:dictionary];
    }];
        
    return sortedData;
   
}

#pragma mark - Extraction speaker

-(NSString *)showSpeakers:(NSArray *)aSpeakers
{
    NSMutableString *speakers = [NSMutableString new];
    if ([aSpeakers count] == 1) {
        speakers = [NSMutableString stringWithFormat:@" - %@", aSpeakers[0][@"full_name"]];
    } else {
        for (PFObject * speaker in aSpeakers) {
            [speakers appendString:[NSString stringWithFormat:@" - %@", speaker[@"full_name"]]];
        }
    }
    return speakers;
}

#pragma mark - Action tap button

- (IBAction)tapDownload:(id)sender {
    
    if([Connection existConnection]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        Talk * talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
        
        if(talk.file) {
            NSString * urlFile = talk.file.url;
            [Cloud sendMail:[[PFUser currentUser] email] url:urlFile talkName:talk.title];
        } else {
            [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"O material será enviado para %@ quando disponível", [[PFUser currentUser] email]]];
        }
    } else {
        [self showMessageError];
    }
}

- (IBAction)tapQuestion:(id)sender {
    if ([Connection existConnection]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        [self performSegueWithIdentifier:@"addQuestionSegue" sender:sender];
        [self performSegueWithIdentifier:@"talkSegue" sender:nil];
    } else {
        [self showMessageError];
    }
}

- (IBAction)tapFavorite:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Talk * talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
    [talk toggleFavorite:NO];
    [self fetchTalks];
}

#pragma mark - Update Talks

- (void)getLatestTalks
{
    [self fetchTalks];
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictonary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictonary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - other methods
-(void)showMessageError {
    [Messages failMessageWithTitle:nil andMessage:@"Sem conexão com a internet, tente novamente mais tarde"];
}
@end