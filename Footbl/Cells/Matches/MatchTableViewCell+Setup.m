//
//  MatchTableViewCell+Setup.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "MatchTableViewCell+Setup.h"
#import "FTBBet.h"
#import "FTBChallenge.h"
#import "FTBMatch+Sharing.h"
#import "FTBMatch.h"
#import "FTBTeam.h"
#import "FTBUser.h"
#import "NSNumber+Formatter.h"
#import "UIFont+MaxFontSize.h"
#import "UserImageView.h"

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
    
    if (isMe) {
        self.hostPotLabel.text = match.earningsPerBetForHost.potStringValue;
        self.drawPotLabel.text = match.earningsPerBetForDraw.potStringValue;
        self.guestPotLabel.text = match.earningsPerBetForGuest.potStringValue;
    }
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.hostNameLabel, self.guestNameLabel, self.drawLabel]];
    
    [self setDateText:match.dateString];
    
    FTBMatchResult result = (match.myBet.bid.integerValue != 0) ? match.myBet.result : match.result;
    
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

    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder_escudo"];

    if (result == FTBMatchResultHost) {
        [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.grayscalePictureURL placeholderImage:placeholderImage];
    } else if (result == FTBMatchResultGuest) {
        [self.hostImageView sd_setImageWithURL:match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:placeholderImage];
    } else if (result == FTBMatchResultDraw) {
        [self.hostImageView sd_setImageWithURL:match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.grayscalePictureURL placeholderImage:placeholderImage];
    } else {
        [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:placeholderImage];
    }
    
    if (isMe) {
        self.stakeValueLabel.text = match.myBetValueString;
        self.returnValueLabel.text = match.myBetReturnString;
        self.profitValueLabel.text = match.myBetProfitString;
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
        NSString *text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"$", @""), match.jackpot.shortStringValue];
        [self setFooterText:text];
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
    
    self.shareButton.hidden = !(isMe && match.myBet.bid.integerValue > 0);
	
    self.shareBlock = ^(MatchTableViewCell *matchBlockCell) {
        [match shareUsingMatchCell:matchBlockCell viewController:viewController];
    };
}

- (void)setMatch:(FTBMatch *)match challenge:(FTBChallenge *)challenge viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock {
    self.selectionBlock = selectionBlock;

    self.hostUserImageView.user = nil;
    self.drawUserImageView.user = nil;
    self.guestUserImageView.user = nil;

    if (challenge.challengerResult == FTBMatchResultGuest) {
        self.guestUserImageView.user = challenge.challengerUser;
        self.guestUserImageView.ringVisible = YES;
    } else if (challenge.challengerResult == FTBMatchResultDraw) {
        self.drawUserImageView.user = challenge.challengerUser;
        self.drawUserImageView.ringVisible = YES;
    } else if (challenge.challengerResult == FTBMatchResultHost) {
        self.hostUserImageView.user = challenge.challengerUser;
        self.hostUserImageView.ringVisible = YES;
    }

    if (challenge.challengedResult == FTBMatchResultGuest) {
        self.guestUserImageView.user = challenge.challengedUser;
        self.guestUserImageView.ringVisible = YES;
    } else if (challenge.challengedResult == FTBMatchResultDraw) {
        self.drawUserImageView.user = challenge.challengedUser;
        self.drawUserImageView.ringVisible = YES;
    } else if (challenge.challengedResult == FTBMatchResultHost) {
        self.hostUserImageView.user = challenge.challengedUser;
        self.hostUserImageView.ringVisible = YES;
    }

    self.hostNameLabel.text = match.host.name;
    self.guestNameLabel.text = match.guest.name;
    
    self.hostScoreLabel.text = match.hostScore.stringValue;
    self.guestScoreLabel.text = match.guestScore.stringValue;
    
    self.hostPotLabel.text = [@2 potStringValue];
    self.drawPotLabel.text = [@2 potStringValue];
    self.guestPotLabel.text = [@2 potStringValue];
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.hostNameLabel, self.guestNameLabel, self.drawLabel]];
    
    [self setDateText:match.dateString];
    
    FTBMatchResult result = (challenge.bid.integerValue != 0) ? challenge.challengerResult : match.result;
    
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

    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder_escudo"];

    if (result == FTBMatchResultHost) {
        [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.grayscalePictureURL placeholderImage:placeholderImage];
        self.hostImageView.alpha = 1;
        self.guestImageView.alpha = 0.4;
        self.versusLabel.alpha = 0.4;
    } else if (result == FTBMatchResultGuest) {
        [self.hostImageView sd_setImageWithURL:match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:placeholderImage];
        self.hostImageView.alpha = 0.4;
        self.guestImageView.alpha = 1;
        self.versusLabel.alpha = 0.4;
    } else if (result == FTBMatchResultDraw) {
        [self.hostImageView sd_setImageWithURL:match.host.grayscalePictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.grayscalePictureURL placeholderImage:placeholderImage];
        self.hostImageView.alpha = 0.4;
        self.guestImageView.alpha = 0.4;
        self.versusLabel.alpha = 1;
    } else {
        [self.hostImageView sd_setImageWithURL:match.host.pictureURL placeholderImage:placeholderImage];
        [self.guestImageView sd_setImageWithURL:match.guest.pictureURL placeholderImage:placeholderImage];
        self.hostImageView.alpha = 1;
        self.guestImageView.alpha = 1;
        self.versusLabel.alpha = 1;
    }
    
    self.stakeValueLabel.text = challenge.valueString;
    self.returnValueLabel.text = challenge.toReturnString;
    self.profitValueLabel.text = challenge.rewardString;
    
    [UIFont setMaxFontSizeToFitBoundsInLabels:@[self.stakeValueLabel, self.returnValueLabel, self.profitValueLabel]];
    
    self.colorScheme = MatchTableViewCellColorSchemeDefault;
    
    if (challenge.bid.integerValue > 0) {
        NSString *text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"$", @""), challenge.bid.shortStringValue];
        [self setFooterText:text];
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
    
    self.shareButton.hidden = YES;
    
    self.cardContentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardContentView.layer.bounds cornerRadius:4].CGPath;
}

@end
