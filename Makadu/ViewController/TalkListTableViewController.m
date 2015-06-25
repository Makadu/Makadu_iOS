//
//  TalkListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkListTableViewController.h"

#import "TalkDAO.h"
#import "EventDAO.h"
#import "TalkFavoriteDAO.h"

#import "Event.h"
#import "Talk.h"

#import "TalkTableViewCell.h"
#import "TalkViewController.h"
#import "QuestionViewController.h"


#import "Connection.h"
#import "Cloud.h"
#import "Schedule.h"
#import "Analitcs.h"
#import "Messages.h"

@interface TalkListTableViewController ()

@property (nonatomic, strong) NSArray * listTalk;
@property (nonatomic, strong) NSArray * listDateTalk;
@property (strong, nonatomic) NSMutableArray *talksFiltered;
@property (strong, nonatomic) NSArray *talksNoFiltered;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
@property (nonatomic, strong) PFObject *talkObject;
@property (nonatomic, strong) Event * event;
@property (nonatomic, strong) MRProgressOverlayView *mrProgressOverLayview;

@property IBOutlet UISearchBar *eventSearchBar;

@end

@implementation TalkListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.event = self.showEventViewController.event;
    
    self.navigationController.navigationBar.topItem.title = @"Palestras";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestTalks) forControlEvents:UIControlEventValueChanged];
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Carregando a programação... \n Isso pode demorar até 30 segundos." mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (self.showEventViewController.eventObject != nil) {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Lista de Palestras" description:@"O usuário acessou a lista de palestras do evento" event:self.showEventViewController.eventObject];
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Lista de Palestras" description:@"O usuário sem acesso a conexão de dados"];
    }
    
    
    [self fetchTalks];
    
    self.indexPathSelected = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else  {
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
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.talksFiltered count];
    } else {
        return [[self.listTalk objectAtIndex:section][@"group"] count];
    }
}

#pragma mark - Table view delagate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellEvent = @"listTalkCell";
    TalkTableViewCell *cell = (TalkTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
    
    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    Talk * talk = [Talk new];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        talk = [self.talksFiltered objectAtIndex:indexPath.row];
    } else {
        talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    }
    
    cell.titleAndHourlabel.text = [NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title];
    [cell.titleAndHourlabel sizeToFit];
    cell.localAndDuration.text = [NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour];
    [cell.localAndDuration sizeToFit];
    cell.speakers.text = [self showSpeakers:talk.speakers];
    [cell.speakers sizeToFit];
    
    if ([talk isFavorite])
        cell.btnFavorite.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:133.0/255.0 blue:110.0/255.0 alpha:1];
    else
        cell.btnFavorite.backgroundColor = [UIColor clearColor];
    
    cell.btnFavorite.selected = [talk isFavorite];
    
    cell.btnFavorite.hidden = !talk.allowFavorite;
    cell.btnDownload.hidden = !talk.allowFile;
    cell.btnQuestion.hidden = !talk.allowQuestion;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Talk * talk = [Talk new];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        talk = [self.talksFiltered objectAtIndex:indexPath.row];
    } else {
        talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    }
    
    CGFloat height = [TalkTableViewCell calculateCellHeightWithTitle:[NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title] localAndDuration:[NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour] speakers:[self showSpeakers:talk.speakers] width:[[UIScreen mainScreen] bounds].size.width - 40];
    
    height += 95;

    if (!talk.allowFile && !talk.allowQuestion)
        height -= 20;
    
    if ([talk.speakers count] == 0)
       height -= 30;
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
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
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 17;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = nil;
    
    if ([segue.identifier isEqualToString:@"talkSegue"]) {
        Talk * talk = [Talk new];
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            talk = [self.talksFiltered objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
        }
        
        PFObject * talkObject = [TalkDAO fetchTalkByTalkId:talk];
        
        TalkViewController *talkViewController = [segue destinationViewController];
        [talkViewController setTalk:talk];
        [talkViewController setTalkObject:talkObject];
        [talkViewController setEventObject:self.showEventViewController.eventObject];
        
        if (talkObject != nil) {
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Lista de Palestras" description:@"O usuário clicou na palestra" event:self.showEventViewController.eventObject talk:talkObject];
        } else {
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Lista de Palestras" description:@"Usuário sem acesso a conexão de dados."];
        }
        
    } else if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        QuestionViewController *questionViewController = [segue destinationViewController];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        Talk * talk = [Talk new];
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            talk = [self.talksFiltered objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
        }
    
        PFObject * talkObject = [TalkDAO fetchTalkByTalkId:talk];
        
        if (talkObject != nil) {
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Lista de Palestras" description:@"O usuário clicou no botão de perguntar da palestra" event:self.showEventViewController.eventObject talk:talkObject];
        } else {
            [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Lista de Palestras" description:@"Usuário sem acesso a conexão de dados."];
        }
        
        [questionViewController setEventObject:self.showEventViewController.eventObject];
        [questionViewController setTalkObject:talkObject];
        [questionViewController setTalk:talk];
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    [self.talksFiltered removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.talksFiltered = [NSMutableArray arrayWithArray:[self.talksNoFiltered filteredArrayUsingPredicate:predicate]];
    
    [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Buscou" screenAccess:@"Lista de Palestras" description:[NSString stringWithFormat:@"O usuário realizou uma busca pela seguinte palavra: %@", searchText]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

#pragma mark - fetch

-(void)fetchTalks {
    
    if (self.showEventViewController.eventObject == nil) {
        self.listTalk = nil;
        self.listDateTalk = nil;
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
    } else {
        [TalkDAO fetchTalkByEvent:self.showEventViewController.eventObject talks:^(NSArray * objects) {
            self.listTalk = objects;
            self.talksNoFiltered = objects;
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
        
        Talk *talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
        
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Clicou" screenAccess:@"Lista de Palestras" description:@"O usuário clicou no botão de download da palestra" event:self.showEventViewController.eventObject talk:[TalkDAO fetchTalkByTalkId:talk]];
        
        if(talk.file) {
            NSString * urlFile = talk.file.url;
            [Cloud sendMail:[[PFUser currentUser] email] url:urlFile talkName:talk.title];
        } else {
            [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"O material será enviado para %@ quando disponível", [[PFUser currentUser] email]]];
            [Schedule saveDataScheduleWithUser:[PFUser currentUser] talk:talk];
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
    
    TalkTableViewCell * cell = (TalkTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathSelected];
    
    Talk *talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
    
    cell.btnFavorite.selected = ![talk isFavorite];
    cell.btnFavorite.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:133.0/255.0 blue:110.0/255.0 alpha:1];
    cell.btnFavorite.imageView.image = [cell.btnFavorite.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [talk toggleFavorite:YES];
}

#pragma mark - Update Talks

- (void)getLatestTalks
{
    [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Atualizou" screenAccess:@"Lista de Palestras" description:@"O usuário atualizou o lista de palestras do evento." event:self.showEventViewController.eventObject];

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
