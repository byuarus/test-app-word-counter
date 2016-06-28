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

@implementation LIVWordSetTableViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:@"wordCounterUpdated" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1,[self.displayedItems count]);
}

- (void)updateTable:(NSNotification *)note {
    self.displayedItems = self.textFile.sortedWordOccurrencesArray;
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LITWordCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"wordCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LITWordCell alloc] init];
    }
    cell.word.text = @"";
    cell.occurrences.text = @"";
    
    if (indexPath.row > 0) {
        [cell.spinner setHidden:YES];
    } else {
        [cell.spinner startAnimating];
    }
    
    if ([self.displayedItems count] > 0) {
        [cell.spinner stopAnimating];
        [cell.spinner setHidden:YES];
        cell.word.text = [self.displayedItems objectAtIndex:indexPath.row][@"object"];
        NSUInteger occurrences = [[self.displayedItems objectAtIndex:indexPath.row][@"count"] integerValue];
        cell.occurrences.text = [NSString stringWithFormat:@"%lu",(unsigned long)occurrences];
    }
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText isEqualToString:@""]) {
        [self.searchResults removeAllObjects];
        
        for (NSDictionary *dict in self.textFile.sortedWordOccurrencesArray) {
            if ([searchText isEqualToString:@""] || [dict[@"object"] localizedCaseInsensitiveContainsString:searchText] == YES) {
                [self.searchResults addObject:dict];
            }
        }
        self.displayedItems = self.searchResults;
    }
    else {
        self.displayedItems = self.textFile.sortedWordOccurrencesArray;
    }
    [self.tableView reloadData];
}

@end
