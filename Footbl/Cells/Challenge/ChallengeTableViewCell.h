//
//  ChallengeTableViewCell.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TeamImageView.h"
#import "UserImageView.h"

@interface ChallengeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UserImageView *userImageView;
@property (nonatomic, weak) IBOutlet TeamImageView *hostTeamImageView;
@property (nonatomic, weak) IBOutlet TeamImageView *guestTeamImageView;
@property (nonatomic, weak) IBOutlet UILabel *vsLabel;
@property (nonatomic, weak) IBOutlet UILabel *stakeLabel;
@property (nonatomic, weak) IBOutlet UILabel *profitLabel;

@end
