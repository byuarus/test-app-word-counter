//
//  LITWordCell.h
//  TestAppLivit
//
//  Created by Dmitry Malakhov on 27.06.16.
//  Copyright © 2016 Dmytro Malakhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LITWordCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *word;
@property (nonatomic, strong) IBOutlet UILabel *occurrences;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

@end
