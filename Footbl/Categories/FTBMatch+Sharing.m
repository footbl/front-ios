//
//  Match+Sharing.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FTBMatch+Sharing.h"
#import "FTBBet.h"
#import "FTBTeam.h"
#import "MatchTableViewCell.h"
#import "WhatsAppActivity.h"

@interface FTBMatch () <UIDocumentInteractionControllerDelegate>

@end

@implementation FTBMatch (Sharing)

- (void)shareUsingMatchCell:(MatchTableViewCell *)cell viewController:(UIViewController *)viewController {
	UIImage *screenshot = cell.imageRepresentation;
	
	NSString *text = @"";
	
	NSNumber *value = self.myBet.bid;
    BOOL hasBet = !!value;
	FTBMatchResult result = self.myBet.result;
	FTBTeam *team;
	FTBTeam *againstTeam;
	if (hasBet && result == FTBMatchResultHost) {
		team = self.host;
		againstTeam = self.guest;
	} else if (hasBet && result == FTBMatchResultGuest) {
		team = self.guest;
		againstTeam = self.host;
	}
	
	switch (cell.stateLayout) {
		case MatchTableViewCellStateLayoutWaiting:
			if (hasBet) {
				if (team) {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting with bet", @"{bet team} {against team} {bet value}"), team.name, againstTeam.name, value.stringValue];
				} else {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting with bet (draw)", @"{home team} {away team} {bet value}"), self.host.name, self.guest.name, value.stringValue];
				}
			} else {
				text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting without bet", @"{home team} {away team}"), self.host.name, self.guest.name];
			}
			break;
		case MatchTableViewCellStateLayoutLive:
			if (hasBet) {
				if (team) {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live with bet", @"{bet team} {against team} {bet value}"), team.name, againstTeam.name, value.stringValue];
				} else {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live with bet (draw)", @"{home team} {away team} {bet value}"), self.host.name, self.guest.name, value.stringValue];
				}
			} else {
				text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live without bet", @"{home team} {away team}"), self.host.name, self.guest.name];
			}
			break;
		case MatchTableViewCellStateLayoutDone:
			if (hasBet) {
				if (team) {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished with bet", @"{bet team} {against team} {bet value} {bet profit}"), team.name, againstTeam.name, value.stringValue, self.myBet.reward.stringValue];
				} else {
					text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished with bet (draw)", @"{home team} {away team} {bet value} {bet profit}"), self.host.name, self.guest.name, value.stringValue, self.myBet.reward.stringValue];
				}
			} else {
				text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished without bet", @"{home team} {away team}"), self.host.name, self.guest.name];
			}
			break;
		default:
			break;
	}
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[screenshot, text] applicationActivities:@[[WhatsAppActivity new]]];
	activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint];
	[viewController presentViewController:activityViewController animated:YES completion:nil];
}

@end
