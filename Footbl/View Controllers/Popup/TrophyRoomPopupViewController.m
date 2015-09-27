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
	
	NSRange range = [self.trophy.subtitle rangeOfString:@"\n"];
	if (range.location != NSNotFound) {
		range.length = self.trophy.subtitle.length - range.location;
		UIFont *font = [self.descriptionLabel.font fontWithSize:(0.8 * self.descriptionLabel.font.pointSize)];
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.trophy.subtitle];
		[string addAttribute:NSFontAttributeName value:font range:range];
		self.descriptionLabel.attributedText = string;
	} else {
		self.descriptionLabel.text = self.trophy.subtitle;
	}
	
	if (self.trophy.isProgressive) {
		self.progressLabel.text = [NSString stringWithFormat:@"%ld%% completed", (long)(self.trophy.progress.floatValue * 100)];
		self.progressView.progress = self.trophy.progress.floatValue;
	} else {
		[self.progressLabel removeFromSuperview];
		[self.progressView removeFromSuperview];
	}
}

@end
