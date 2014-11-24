//
//  GroupChatViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "TemplateViewController.h"

@class Group;

@interface GroupChatViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIView *footerBackgroundView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITextView *messageTextView;
@property (strong, nonatomic) UIView *messageBorderView;

@end
