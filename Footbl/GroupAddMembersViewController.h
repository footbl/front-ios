//
//  GroupAddMembersViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class Championship;

@interface GroupAddMembersViewController : TemplateViewController

@property (strong, nonatomic) Championship *championship;
@property (copy, nonatomic) NSString *groupName;

@end
