//
//  GroupChatViewController.h
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "TemplateViewController.h"

@class FTBGroup;

@interface GroupChatViewController : TemplateViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) FTBGroup *group;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIView *footerBackgroundView;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITextView *messageTextView;
@property (strong, nonatomic) UIImageView *messageImageView;
@property (strong, nonatomic) UIView *messageBorderView;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) NSMutableArray *messages;

@end
