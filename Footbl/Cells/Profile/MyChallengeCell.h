//
//  MyChallengeCell.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/30/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyChallengeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *topLineView;
@property (nonatomic, weak) IBOutlet UIView *bottomLineView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *hostTeamImageView;
@property (nonatomic, weak) IBOutlet UIImageView *guestTeamImageView;
@property (nonatomic, weak) IBOutlet UILabel *vsLabel;
@property (nonatomic, weak) IBOutlet UILabel *stakeLabel;
@property (nonatomic, weak) IBOutlet UILabel *profitLabel;

@end