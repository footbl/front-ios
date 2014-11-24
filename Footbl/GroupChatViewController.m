//
//  GroupChatViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/UIView+Frame.h>
#import "ChatTableViewCell.h"
#import "Group.h"
#import "GroupChatViewController.h"
#import "ErrorHandler.h"
#import "Message.h"
#import "ProfileViewController.h"
#import "User.h"

@interface GroupChatViewController ()

@property (assign, nonatomic, getter=isKeyboardVisible) BOOL keyboardVisible;
@property (assign, nonatomic) CGSize keyboardSize;
@property (assign, nonatomic, getter=hasCreatedMessage) BOOL createdMessage;
@property (strong, nonatomic) NSNumber *nextPage;
@property (assign, nonatomic) BOOL shouldScrollToBottom;

@end

#pragma mark GroupChatViewController

@implementation GroupChatViewController

static NSUInteger const kChatSectionMaximumTimeInterval = 60 * 30;

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController && self.group) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@", self.group];
        fetchRequest.includesSubentities = YES;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[FTCoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            SPLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}

- (void)setKeyboardVisible:(BOOL)keyboardVisible {
    if (_keyboardVisible == keyboardVisible) {
        return;
    }
    
    _keyboardVisible = keyboardVisible;
    
    [self reloadViewsAnimated:YES];
}

- (void)setNextPage:(NSNumber *)nextPage {
    _nextPage = nextPage;
    
    CGFloat contentOffsetAdjust = 0;
    if (self.tableView.tableHeaderView && !_nextPage) {
        self.tableView.tableHeaderView = nil;
        [self.tableView reloadData];
        return;
    } else if (!self.tableView.tableHeaderView && _nextPage) {
        contentOffsetAdjust = self.headerView.frameHeight;
    }
    
    if (self.nextPage) {
        self.tableView.tableHeaderView = self.headerView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
    
    if (contentOffsetAdjust != 0) {
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + contentOffsetAdjust);
    }
}

#pragma mark - Instance Methods

- (IBAction)sendAction:(id)sender {
    NSString *text = [self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        return;
    }
    self.messageTextView.text = @"";
    self.createdMessage = YES;
    [self reloadViewsAnimated:YES];
    
    [Message createWithParameters:@{kFTRequestParamResourcePathObject : self.group.editableObject, @"message" : text} success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (IBAction)loadNextPage:(UIButton *)sender {
    if (!self.nextPage) {
        return;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = sender.center;
    activityIndicatorView.alpha = 0;
    [activityIndicatorView startAnimating];
    [sender.superview addSubview:activityIndicatorView];
    
    [UIView animateWithDuration:0.3 animations:^{
        activityIndicatorView.alpha = 1;
        sender.alpha = 0;
    }];
    
    [Message getWithGroup:self.group.editableObject page:self.nextPage.integerValue shouldDeleteUntouchedObjects:NO success:^(NSNumber *nextPage) {
        self.nextPage = nextPage;
        [UIView animateWithDuration:0.3 animations:^{
            activityIndicatorView.alpha = 0;
            sender.alpha = 1;
        } completion:^(BOOL finished) {
            [activityIndicatorView removeFromSuperview];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
        [UIView animateWithDuration:0.3 animations:^{
            activityIndicatorView.alpha = 0;
            sender.alpha = 1;
        } completion:^(BOOL finished) {
            [activityIndicatorView removeFromSuperview];
        }];
    }];
}

- (void)configureCell:(ChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Message *previousMessage;
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        previousMessage = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
    }
    
    cell.contentView.frameWidth = self.tableView.frameWidth;

    if (previousMessage && [previousMessage.user.slug isEqualToString:message.user.slug] && fabs([message.createdAt timeIntervalSinceDate:previousMessage.createdAt] < kChatSectionMaximumTimeInterval)) {
        [cell setProfileName:nil message:message.message pictureURL:nil date:nil shouldUseRightAlignment:message.user.isMeValue];
    } else {
        [cell setProfileName:message.user.name message:message.message pictureURL:[NSURL URLWithString:message.user.picture] date:message.createdAt shouldUseRightAlignment:message.user.isMeValue];
    }
}

- (void)reloadData {
    [super reloadData];
    
    NSUInteger count = self.fetchedResultsController.fetchedObjects.count;
    if (count == 0) {
        self.createdMessage = YES;
    }
    [Message getWithGroup:self.group.editableObject page:0 shouldDeleteUntouchedObjects:YES success:^(NSNumber *nextPage) {
        self.nextPage = nextPage;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ErrorHandler sharedInstance] displayError:error];
    }];
}

- (void)reloadViewsAnimated:(BOOL)animated {
    NSUInteger maxMessageHeight = self.view.frameHeight / 4.45;
    NSUInteger messageHeight = MIN(maxMessageHeight, [self.messageTextView sizeThatFits:CGSizeMake(self.messageTextView.frameWidth, INT_MAX)].height);
    self.footerView.frameHeight = messageHeight + 20;
    
    CGFloat buttonWidth = [self.sendButton sizeThatFits:self.footerView.bounds.size].width + 20;
    self.sendButton.frameX = self.view.frameWidth - buttonWidth;
    self.sendButton.frameWidth = buttonWidth;
    self.messageTextView.frame = CGRectMake(0, -1, self.sendButton.frameX - 10, maxMessageHeight);
    
    if ([self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        self.sendButton.frameHeight = self.footerView.frameHeight;
        self.messageBorderView.frame = CGRectMake(10, 10, self.sendButton.frameX - 10, self.footerView.frameHeight - 20);
        self.footerView.frameY = self.view.frameHeight - 48 - self.keyboardSize.height - self.footerView.frameHeight;
        
        if (self.tableView.frameHeight != self.footerView.frameY - self.tableView.frameY) {
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + self.keyboardSize.height);
        }
        
        self.tableView.frameHeight = self.footerView.frameY - self.tableView.frameY;
    }];
}

- (void)scrollToLastMessageAnimated:(BOOL)animated {
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardSize = CGSizeZero;
    self.keyboardVisible = NO;
}

#pragma mark - Protocols

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Message *previousMessage;
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        previousMessage = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
    }
    
    if (previousMessage && [previousMessage.user.slug isEqualToString:message.user.slug] && fabs([message.createdAt timeIntervalSinceDate:previousMessage.createdAt] < kChatSectionMaximumTimeInterval)) {
        return 25;
    } else {
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Message *previousMessage;
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        previousMessage = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
    }
    
    if (!(previousMessage && [previousMessage.user.slug isEqualToString:message.user.slug] && fabs([message.createdAt timeIntervalSinceDate:previousMessage.createdAt] < kChatSectionMaximumTimeInterval))) {
        ProfileViewController *profileViewController = [ProfileViewController new];
        profileViewController.user = message.user;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendAction:textView];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self reloadViewsAnimated:NO];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.keyboardVisible || self.hasCreatedMessage) {
        return;
    }
    
    CGFloat offset = self.tableView.contentSize.height - self.tableView.contentOffset.y;
    if (offset >= self.view.frameHeight - self.footerView.frameHeight) {
        [self.messageTextView resignFirstResponder];
    }
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    BOOL shouldReload = NO;
    if ([[self valueForKey:@"insertedRowIndexPaths"] count] > 0 || [[self valueForKey:@"deletedRowIndexPaths"] count] > 0) {
        shouldReload = YES;
        if ([[self valueForKey:@"insertedRowIndexPaths"] count] + [[self valueForKey:@"deletedRowIndexPaths"] count] > 5) {
            [self.tableView reloadData];
        } else {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[self valueForKey:@"insertedRowIndexPaths"] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView deleteRowsAtIndexPaths:[self valueForKey:@"deletedRowIndexPaths"] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
    
    [self setValue:nil forKey:@"insertedSectionIndexes"];
    [self setValue:nil forKey:@"deletedSectionIndexes"];
    [self setValue:nil forKey:@"insertedRowIndexPaths"];
    [self setValue:nil forKey:@"deletedRowIndexPaths"];
    [self setValue:nil forKey:@"updatedRowIndexPaths"];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        self.placeholderLabel.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.placeholderLabel.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    NSIndexPath *lastVisibleCellIndexPath = [self.tableView indexPathForCell:self.tableView.visibleCells.lastObject];
    
    if (shouldReload) {
        [Message markAsReadFromGroup:self.group success:nil failure:nil];
    }
    
    if (self.hasCreatedMessage || ([self.tableView numberOfRowsInSection:lastVisibleCellIndexPath.section] - lastVisibleCellIndexPath.row <= 2 && shouldReload)) {
        [self scrollToLastMessageAnimated:YES];
        self.createdMessage = NO;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.shouldScrollToBottom = YES;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = CGRectMake(0, 64, self.view.frameWidth, self.view.frameHeight - 64);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, 5)];
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.view addSubview:self.tableView];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.frameWidth - 40, 200)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placeholderLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    self.placeholderLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderLabel.text = NSLocalizedString(@"Chat placeholder", @"");
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = YES;
    [self.view addSubview:self.placeholderLabel];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frameHeight - 97, self.view.frameWidth, 49)];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.footerView.clipsToBounds = NO;
    [self.view addSubview:self.footerView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.footerView.frameWidth, self.view.frameHeight)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    backgroundView.backgroundColor = [FootblAppearance colorForView:FootblColorTabBarTint];
    [self.footerView addSubview:backgroundView];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.sendButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:18];
    [self.sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.sendButton];
    
    self.messageBorderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.messageBorderView.clipsToBounds = YES;
    self.messageBorderView.layer.cornerRadius = 3;
    [self.footerView addSubview:self.messageBorderView];
    
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.messageTextView.backgroundColor = [UIColor whiteColor];
    self.messageTextView.delegate = self;
    self.messageTextView.returnKeyType = UIReturnKeySend;
    self.messageTextView.enablesReturnKeyAutomatically = YES;
    self.messageTextView.font = [UIFont fontWithName:kFontNameSystemLight size:14.0];
    [self.messageBorderView addSubview:self.messageTextView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, 50)];
    UIButton *nextPageButton = [[UIButton alloc] initWithFrame:self.headerView.bounds];
    nextPageButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
    [nextPageButton setTitle:NSLocalizedString(@"Load more", @"") forState:UIControlStateNormal];
    [nextPageButton addTarget:self action:@selector(loadNextPage:) forControlEvents:UIControlEventTouchUpInside];
    [nextPageButton setTitleColor:[UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00] forState:UIControlStateNormal];
    [nextPageButton setTitleColor:[UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.30] forState:UIControlStateHighlighted];
    [self.headerView addSubview:nextPageButton];
    
    [self reloadViewsAnimated:NO];
    
    [Message markAsReadFromGroup:self.group success:nil failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        self.placeholderLabel.hidden = NO;
        self.tableView.hidden = YES;
    }
    
    if (self.shouldScrollToBottom) {
        [self scrollToLastMessageAnimated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollToLastMessageAnimated:NO];
        });
        self.shouldScrollToBottom = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.navigationController.viewControllers.count == 1) {
        self.fetchedResultsController = nil;
        [Message getWithGroup:self.group.editableObject page:0 shouldDeleteUntouchedObjects:YES success:nil failure:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end