//
//  LIVWordSetTableViewController.m
//  TestAppLivit
//
//  Created by Dmitry Malakhov on 27.06.16.
//  Copyright © 2016 Dmytro Malakhov. All rights reserved.
//

#import "LIVWordSetTableViewController.h"
#import "LITWordCell.h"
#import "LIVTextFile.h"


@interface LIVWordSetTableViewController ()

@end

@implementation LIVWordSetTableViewController{
    BOOL isLoading;
    NSString *status;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.searchResults = [[NSMutableArray alloc] init];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    self.textFile = [LIVTextFile sharedInstance];
    status = @"Loading";
    isLoading = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:@"wordCounterUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noFilebyUrl:) name:@"noFileByUrl" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observer notification selectors

- (void)updateTable:(NSNotification *)note {
    isLoading = NO;
    if ([self.textFile.sortedWordOccurrencesArray count] == 0) {
        status = @"No words in file";
    } else {
        status = @"";
    }
    self.displayedItems = self.textFile.sortedWordOccurrencesArray;
    [self.tableView reloadData];
}

- (void)noFilebyUrl:(NSNotification *)notification {
    isLoading = NO;
    status = @"No file with Url";
    [self.tableView reloadData];
    NSString *fileUrl = [notification.userInfo valueForKey:@"url"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error: No File"
                                                                   message:[NSString stringWithFormat:@"%@%@",@"There is no file with url: \n",fileUrl]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1,[self.displayedItems count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LITWordCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"wordCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LITWordCell alloc] init];
    }
    cell.word.text = @"";
    cell.occurrences.text = @"";
    cell.status.text = @"";
    
    if (isLoading) {
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [spinner startAnimating];
        [cell addSubview:spinner];
    } else if ([self.displayedItems count] == 0) {
        cell.status.text = status;
    } else {
        cell.word.text = [self.displayedItems objectAtIndex:indexPath.row][@"object"];
        NSUInteger occurrences = [[self.displayedItems objectAtIndex:indexPath.row][@"count"] integerValue];
        cell.occurrences.text = [NSString stringWithFormat:@"%lu",(unsigned long)occurrences];
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    [sectionHeader setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:0.8]];
    
    UILabel *labelWord = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width/2, 18)];
    [labelWord setFont:[UIFont boldSystemFontOfSize:12]];
    labelWord.text = @"Word";
    labelWord.textAlignment = NSTextAlignmentLeft;
    
    UILabel *labelOccurancy = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2, 5, tableView.frame.size.width/2 - 10, 18)];
    [labelOccurancy setFont:[UIFont boldSystemFontOfSize:12]];
    labelOccurancy.text = @"Occurancy";
    labelOccurancy.textAlignment = NSTextAlignmentRight;

    [sectionHeader addSubview:labelWord];
    [sectionHeader addSubview:labelOccurancy];
    
    return sectionHeader;
}

#pragma mark - Search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText isEqualToString:@""]) {
        [self.searchResults removeAllObjects];
        
        for (NSDictionary *dict in self.textFile.sortedWordOccurrencesArray) {
            if ([searchText isEqualToString:@""] || [dict[@"object"] localizedCaseInsensitiveContainsString:searchText] == YES) {
                [self.searchResults addObject:dict];
            }
        }
        self.displayedItems = self.searchResults;
        if ([status isEqualToString:@""] && [self.displayedItems count] == 0) {
            status = @"Words not found";
        }
    }
    else {
        self.displayedItems = self.textFile.sortedWordOccurrencesArray;
    }
    [self.tableView reloadData];
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
