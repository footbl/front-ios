//
//  ChallengesViewController.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@interface ChallengesViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
