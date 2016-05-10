//
//  ChallengeStatusTableViewCell.h
//  Footbl
//
//  Created by Leonardo Formaggio on 5/10/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeStatusTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *substatusLabel;

+ (UINib *)nib;

@end
