//
//  ChallengeViewController.h
//  Footbl
//
//  Created by Leonardo Formaggio on 5/2/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBMatch;
@class FTBUser;
@class FTBChallenge;
@class MatchesNavigationBarView;

@interface ChallengeViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MatchesNavigationBarView *navigationBarTitleView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *declineButton;
@property (nonatomic, strong) UIButton *acceptButton;

@property (nonatomic, strong) FTBMatch *match;
@property (nonatomic, strong) FTBUser *challengedUser;
@property (nonatomic, strong) FTBChallenge *challenge;

@end
