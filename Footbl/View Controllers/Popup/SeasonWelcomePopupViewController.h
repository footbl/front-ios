//
//  SeasonWelcomePopupViewController.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/27/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "NewPopupViewController.h"

@class FTBSeason;

@interface SeasonWelcomePopupViewController : NewPopupViewController

@property (nonatomic, strong) FTBSeason *season;

@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, weak) IBOutlet UILabel *seasonLabel;
@property (nonatomic, weak) IBOutlet UILabel *offeredLabel;
@property (nonatomic, weak) IBOutlet UILabel *walletMessageLabel;
@property (nonatomic, weak) IBOutlet UIButton *okButton;

@end
