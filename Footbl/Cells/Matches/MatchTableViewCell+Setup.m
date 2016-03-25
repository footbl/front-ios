//
//  MatchTableViewCell+Setup.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "FTBMatch+Sharing.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "TeamImageView.h"
#import "UIFont+MaxFontSize.h"

#import "FTBMatch.h"
#import "FTBBet.h"
#import "FTBUser.h"
#import "FTBTeam.h"

#pragma mark MatchTableViewCell (Setup)

@implementation MatchTableViewCell (Setup)

#pragma mark - Instance Methods

- (void)setMatch:(FTBMatch *)match bet:(FTBBet *)bet viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock {
    self.selectionBlock = selectionBlock;
	
    BOOL isMe = (bet.user.isMe || !bet);
    
    self.hostNameLabel.text = match.host.name;
    self.guestNameLabel.text = match.guest.name;
    
    self.hostScoreLabel.text = match.hostScore.stringValue;
    self.guestScoreLabel.text = match.guestScore.stringValue;
	
    [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.hostDisabledImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.guestDisabledImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    
    if (isMe && !match.isBetSyncing) {
        self.hostPotLabel.text = match.earningsPerBetForHost.potStringValue;
        self.drawPotLabel.text = match.earningsPerBetForDraw.potStringValue;
        self.guestPotLabel.text = match.earningsPerBetForGuest.potStringValue;
    }
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.hostNameLabel, self.guestNameLabel, self.drawLabel]];
    
    [self setDateText:match.dateString];
    
    FTBMatchResult result = bet.result;
    if (isMe) {
        result = match.myBet.result;
    }
    
    switch (result) {
        case FTBMatchResultHost:
            self.layout = MatchTableViewCellLayoutHost;
            break;
        case FTBMatchResultGuest:
            self.layout = MatchTableViewCellLayoutGuest;
            break;
        case FTBMatchResultDraw:
            self.layout = MatchTableViewCellLayoutDraw;
            break;
        default:
            self.layout = MatchTableViewCellLayoutNoBet;
            break;
    }
    
    if (isMe) {
        if (!match.isBetSyncing) {
            self.stakeValueLabel.text = match.myBetValueString;
            self.returnValueLabel.text = match.myBetReturnString;
            self.profitValueLabel.text = match.myBetProfitString;
        }
    } else if (bet) {
        self.stakeValueLabel.text = bet.valueString;
        self.returnValueLabel.text = bet.toReturnString;
        self.profitValueLabel.text = bet.rewardString;
    }
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.stakeValueLabel, self.returnValueLabel, self.profitValueLabel]];
    
    if (match.status == FTBMatchStatusFinished) {
        if (bet.reward.floatValue > 0) {
            self.colorScheme = MatchTableViewCellColorSchemeHighlightProfit;
        } else {
            self.colorScheme = MatchTableViewCellColorSchemeGray;
        }
    } else {
        self.colorScheme = MatchTableViewCellColorSchemeDefault;
    }
    
    if (match.jackpot.integerValue > 0) {
        [self setFooterText:[NSLocalizedString(@"$", @"") stringByAppendingString:match.jackpot.shortStringValue]];
        self.footerLabel.hidden = NO;
    } else {
        [self setFooterText:@""];
        self.footerLabel.hidden = YES;
    }
    
    switch (match.status) {
        case FTBMatchStatusWaiting:
            self.liveLabel.text = @"";
            self.stateLayout = MatchTableViewCellStateLayoutWaiting;
            break;
        case FTBMatchStatusLive:
            self.liveLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Live - %.0lf'", @"Live - {time elapsed}'"), match.elapsed];
            self.stateLayout = MatchTableViewCellStateLayoutLive;
            break;
        case FTBMatchStatusFinished:
            self.liveLabel.text = NSLocalizedString(@"Final", @"");
            self.stateLayout = MatchTableViewCellStateLayoutDone;
            break;
    }
    
    if (isMe && match.myBet.bid.integerValue > 0) {
        self.shareButton.alpha = 1;
    } else {
        self.shareButton.alpha = 0;
    }
	
	self.cardContentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardContentView.layer.bounds cornerRadius:4].CGPath;
	
    self.shareBlock = ^(MatchTableViewCell *matchBlockCell) {
        [match shareUsingMatchCell:matchBlockCell viewController:viewController];
    };
}

@end
