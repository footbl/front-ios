//
//  Match+Sharing.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "Bet.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell.h"
#import "Team.h"
#import "WhatsAppActivity.h"

#import "FTBTeam.h"
#import "FTBBet.h"

@interface Match () <UIDocumentInteractionControllerDelegate>

@end

#pragma mark Match (Sharing)

@implementation Match (Sharing)

#pragma mark - Instance Methods

- (void)shareUsingMatchCell:(MatchTableViewCell *)cell viewController:(UIViewController *)viewController {
    UIImage *screenshot = cell.imageRepresentation;
    
    NSString *text = @"";
    BOOL hasBet = self.myBetValue;
    NSNumber *value = self.myBetValue;
    MatchResult result = (MatchResult)self.myBetResult;
    Team *team;
    Team *againstTeam;
    if (hasBet && result == MatchResultHost) {
        team = self.host;
        againstTeam = self.guest;
    } else if (hasBet && result == MatchResultGuest) {
        team = self.guest;
        againstTeam = self.host;
    }
    
    switch (cell.stateLayout) {
        case MatchTableViewCellStateLayoutWaiting:
            if (hasBet) {
                if (team) {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting with bet", @"{bet team} {against team} {bet value}"), team.displayName, againstTeam.displayName, value.stringValue];
                } else {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting with bet (draw)", @"{home team} {away team} {bet value}"), self.host.displayName, self.guest.displayName, value.stringValue];
                }
            } else {
                text = [NSString stringWithFormat:NSLocalizedString(@"Share match: waiting without bet", @"{home team} {away team}"), self.host.displayName, self.guest.displayName];
            }
            break;
        case MatchTableViewCellStateLayoutLive:
            if (hasBet) {
                if (team) {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live with bet", @"{bet team} {against team} {bet value}"), team.displayName, againstTeam.displayName, value.stringValue];
                } else {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live with bet (draw)", @"{home team} {away team} {bet value}"), self.host.displayName, self.guest.displayName, value.stringValue];
                }
            } else {
                text = [NSString stringWithFormat:NSLocalizedString(@"Share match: live without bet", @"{home team} {away team}"), self.host.displayName, self.guest.displayName];
            }
            break;
        case MatchTableViewCellStateLayoutDone:
            if (hasBet) {
                if (team) {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished with bet", @"{bet team} {against team} {bet value} {bet profit}"), team.displayName, againstTeam.displayName, value.stringValue, self.myBet.reward.stringValue];
                } else {
                    text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished with bet (draw)", @"{home team} {away team} {bet value} {bet profit}"), self.host.displayName, self.guest.displayName, value.stringValue, self.myBet.reward.stringValue];
                }
            } else {
                text = [NSString stringWithFormat:NSLocalizedString(@"Share match: finished without bet", @"{home team} {away team}"), self.host.displayName, self.guest.displayName];
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

@implementation FTBMatch (Sharing)

- (void)shareUsingMatchCell:(MatchTableViewCell *)cell viewController:(UIViewController *)viewController {
	UIImage *screenshot = cell.imageRepresentation;
	
	NSString *text = @"";
	BOOL hasBet = self.myBetValue;
	NSNumber *value = self.myBetValue;
	FTBMatchResult result = self.myBetResult;
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
