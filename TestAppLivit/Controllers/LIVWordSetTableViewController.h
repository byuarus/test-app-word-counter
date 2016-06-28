//
//  LIVWordSetTableViewController.h
//  TestAppLivit
//
//  Created by Dmitry Malakhov on 27.06.16.
//  Copyright © 2016 Dmytro Malakhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIVTextFile.h"

@interface LIVWordSetTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) LIVTextFile *textFile;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, weak) NSArray *displayedItems;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
