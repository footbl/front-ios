//
//  AskFriendsViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblPopupViewController.h"

@interface AskFriendsViewController : FootblPopupViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;

@end
