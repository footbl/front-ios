//
//  MatchTableViewCell+Setup.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "Bet.h"
#import "Match.h"
#import "Match+Sharing.h"
#import "MatchTableViewCell+Setup.h"
#import "NSNumber+Formatter.h"
#import "Team.h"
#import "TeamImageView.h"
#import "UIFont+MaxFontSize.h"
#import "User.h"

#pragma mark MatchTableViewCell (Setup)

@implementation MatchTableViewCell (Setup)

#pragma mark - Instance Methods

- (void)setMatch:(Match *)match bet:(Bet *)bet viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock {
    self.selectionBlock = selectionBlock;
    
    BOOL isMe = (bet.user.isMeValue || !bet);
    
    self.hostNameLabel.text = match.host.displayName;
    self.guestNameLabel.text = match.guest.displayName;
    
    self.hostScoreLabel.text = match.hostScore.stringValue;
    self.guestScoreLabel.text = match.guestScore.stringValue;
    
#if FT_PREPARE_FOR_SCREENSHOTS
    self.hostImageView.image = [UIImage imageNamed:@"placeholder_escudo"];
    self.hostDisabledImageView.image = [UIImage imageNamed:@"placeholder_escudo"];
    self.guestImageView.image = [UIImage imageNamed:@"placeholder_escudo"];
    self.guestDisabledImageView.image = [UIImage imageNamed:@"placeholder_escudo"];
#else
    [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.hostDisabledImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
    [self.guestDisabledImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:[UIImage imageNamed:@"placeholder_escudo"]];
#endif
    
    if (isMe && !match.editableObject.isBetSyncing) {
        self.hostPotLabel.text = match.earningsPerBetForHost.potStringValue;
        self.drawPotLabel.text = match.earningsPerBetForDraw.potStringValue;
        self.guestPotLabel.text = match.earningsPerBetForGuest.potStringValue;
    }
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.hostNameLabel, self.guestNameLabel, self.drawLabel]];
    
    [self setDateText:match.dateString];
    
    MatchResult result = bet.resultValue;
    if (isMe) {
        result = match.myBetResult;
    }
    
    switch (result) {
        case MatchResultHost:
            self.layout = MatchTableViewCellLayoutHost;
            break;
        case MatchResultGuest:
            self.layout = MatchTableViewCellLayoutGuest;
            break;
        case MatchResultDraw:
            self.layout = MatchTableViewCellLayoutDraw;
            break;
        default:
            self.layout = MatchTableViewCellLayoutNoBet;
            break;
    }
    
    if (isMe) {
        if (!match.editableObject.isBetSyncing) {
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
    
    if (match.status == MatchStatusFinished) {
        if (bet.reward.floatValue > 0) {
            self.colorScheme = MatchTableViewCellColorSchemeHighlightProfit;
        } else {
            self.colorScheme = MatchTableViewCellColorSchemeGray;
        }
    } else {
        self.colorScheme = MatchTableViewCellColorSchemeDefault;
    }
    
    if ((isMe && !match.isBetSyncing) || !isMe) {
        if (match.localJackpot.integerValue > 0) {
            [self setFooterText:[NSLocalizedString(@"$", @"") stringByAppendingString:match.localJackpot.shortStringValue]];
            self.footerLabel.hidden = NO;
        } else {
            [self setFooterText:@""];
            self.footerLabel.hidden = YES;
        }
    }
    
    switch (match.status) {
        case MatchStatusWaiting:
            self.liveLabel.text = @"";
            self.stateLayout = MatchTableViewCellStateLayoutWaiting;
            break;
        case MatchStatusLive:
            self.liveLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Live - %i'", @"Live - {time elapsed}'"), match.elapsed.integerValue];
            self.stateLayout = MatchTableViewCellStateLayoutLive;
            break;
        case MatchStatusFinished:
            self.liveLabel.text = NSLocalizedString(@"Final", @"");
            self.stateLayout = MatchTableViewCellStateLayoutDone;
            break;
    }
    
    if (isMe && match.myBetValue && match.myBetValue.integerValue > 0) {
        self.shareButton.alpha = 1;
    } else {
        self.shareButton.alpha = 0;
    }
    
    self.shareBlock = ^(MatchTableViewCell *matchBlockCell) {
        [match shareUsingMatchCell:matchBlockCell viewController:viewController];
    };
}

@end
