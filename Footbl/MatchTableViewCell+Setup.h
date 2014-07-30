//
//  MatchTableViewCell+Setup.h
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "MatchTableViewCell.h"

@class Bet;
@class Match;

@interface MatchTableViewCell (Setup)

- (void)setMatch:(Match *)match bet:(Bet *)bet viewController:(UIViewController *)viewController selectionBlock:(void (^)(NSInteger index))selectionBlock;

@end
