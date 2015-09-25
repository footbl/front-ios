//
//  TrophyRoomPopupViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "TrophyRoomPopupViewController.h"
#import "FTBTrophy.h"

@interface TrophyRoomPopupViewController ()

@end

@implementation TrophyRoomPopupViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.titleLabel.text = self.trophy.title;
	self.imageView.image = [UIImage imageNamed:self.trophy.imageName];
	self.descriptionLabel.text = self.trophy.subtitle;
	self.progressLabel.text = [NSString stringWithFormat:@"%ld%% completed", (long)(self.trophy.progress.floatValue * 100)];
	self.progressLabel.hidden = !self.trophy.isProgressive;
	self.progressView.progress = self.trophy.progress.floatValue;
	self.progressView.hidden = !self.trophy.isProgressive;
}

@end
