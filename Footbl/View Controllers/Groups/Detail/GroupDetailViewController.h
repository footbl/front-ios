//
//  GroupDetailViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/2/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBGroup;

@interface GroupDetailViewController : TemplateViewController

typedef NS_ENUM(NSUInteger, GroupDetailContext) {
    GroupDetailContextRanking = 0,
    GroupDetailContextChat = 1,
    GroupDetailContextAroundMe = 2,
};

@property (strong, nonatomic) FTBGroup *group;
@property (strong, nonatomic) UIButton *rightNavigationBarButton;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@end
