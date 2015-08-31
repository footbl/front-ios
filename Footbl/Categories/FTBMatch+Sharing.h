//
//  Match+Sharing.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "FTBMatch.h"

@class MatchTableViewCell;

@interface FTBMatch (Sharing)

- (void)shareUsingMatchCell:(MatchTableViewCell *)cell viewController:(UIViewController *)viewController;

@end
