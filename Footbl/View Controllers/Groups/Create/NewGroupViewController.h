//
//  NewGroupViewController.h
//  Footbl
//
//  Created by Fernando Saragoça on 5/3/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "GroupInfoBaseViewController.h"

@interface NewGroupViewController : GroupInfoBaseViewController

@property (assign, nonatomic, getter = isInvitationMode) BOOL invitationMode;
@property (strong, nonatomic) UIButton *invitationModeButton;

@end
