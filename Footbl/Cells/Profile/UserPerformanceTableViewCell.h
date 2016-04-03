//
//  UserPerformanceTableViewCell.h
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPerformanceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *seasonLabel;
@property (nonatomic, weak) IBOutlet UILabel *walletLabel;
@property (nonatomic, weak) IBOutlet UILabel *xpLabel;
@property (nonatomic, weak) IBOutlet UILabel *levelLabel;

@end
