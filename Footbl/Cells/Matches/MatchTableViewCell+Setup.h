//
//  MatchTableViewCell+Setup.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "MatchTableViewCell.h"

@class FTBBet;
@class FTBMatch;
@class FTBChallenge;

@interface MatchTableViewCell (Setup)

- (void)setMatch:(FTBMatch *)match bet:(FTBBet *)bet viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock;
- (void)setMatch:(FTBMatch *)match challenge:(FTBChallenge *)challenge viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock;

@end
