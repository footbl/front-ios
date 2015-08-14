//
//  GroupChatViewController.m
//  Footbl
//
//  Created by Fernando Saragoca on 11/21/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SPHipster/UIView+Frame.h>
#import <UIAlertView-Blocks/UIActionSheet+Blocks.h>
#import "ChatTableViewCell.h"
#import "Group.h"
#import "GroupChatViewController.h"
#import "ErrorHandler.h"
#import "FTImageUploader.h"
#import "Message.h"
#import "ProfileBetsViewController.h"
#import "ProfileViewController.h"
#import "User.h"

@interface GroupChatViewController ()

@property (assign, nonatomic, getter=isKeyboardVisible) BOOL keyboardVisible;
@property (assign, nonatomic) CGSize keyboardSize;
@property (assign, nonatomic, getter=hasCreatedMessage) BOOL createdMessage;
@property (strong, nonatomic) NSNumber *nextPage;
@property (assign, nonatomic) BOOL shouldScrollToBottom;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL canDismissKeyboard;

@end

#pragma mark GroupChatViewController

@implementation GroupChatViewController

static NSUInteger const kChatSectionMaximumTimeInterval = 60 * 30;
static NSUInteger const kChatForceUpdateTimeInterval = 30;

#pragma mark - Class Methods

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController && self.group) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group = %@ AND typeString IN %@", self.group, @[@"text", @"image"]];
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

- (void)setContext:(GroupDetailContext)context {
    _context = context;
    
    if (context == GroupDetailContextChat) {
        [self timerReloadData];
    } else {
        [self.messageTextView resignFirstResponder];
    }
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
    if (self.tableView.tableHeaderView.height == self.headerView.height && !_nextPage) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 5)];
        [self.tableView reloadData];
        return;
    } else if (self.tableView.tableHeaderView.height != self.headerView.height && _nextPage) {
        contentOffsetAdjust = self.headerView.height - 5;
    }
    
    if (self.nextPage) {
        self.tableView.tableHeaderView = self.headerView;
    } else {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 5)];
    }
    
    if (contentOffsetAdjust != 0) {
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + contentOffsetAdjust);
    }
}

#pragma mark - Instance Methods

- (IBAction)shareAction:(id)sender {
	ProfileBetsViewController *viewController = [[ProfileBetsViewController alloc] init];
	viewController.user = [User currentUser];
	viewController.simpleSelection = YES;
	viewController.itemSelectionBlock = ^(MatchTableViewCell *cell) {
		CGRect frame = CGRectMake(5, 5, 80, 80);
		UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:frame];
		self.messageTextView.textContainer.exclusionPaths = @[exclusionPath];
		self.messageImageView.image = cell.imageRepresentation;
		self.messageImageView.frame = frame;
		[self reloadViewsAnimated:NO];
		[self.navigationController popViewControllerAnimated:YES];
	};
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)sendAction:(id)sender {
	UIImage *image = self.messageImageView.image;
    NSString *text = [self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0 && !image) {
        return;
    }
	self.messageTextView.textContainer.exclusionPaths = nil;
	self.messageImageView.frame = CGRectZero;
	self.messageImageView.image = nil;
    self.messageTextView.text = @"";
    self.createdMessage = YES;
    self.canDismissKeyboard = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.canDismissKeyboard = YES;
    });
    [self reloadViewsAnimated:YES];
	
	
	void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.tableView reloadData];
		[[ErrorHandler sharedInstance] displayError:error];
	};
	
	if (image && text.length > 0) {
		[FTImageUploader uploadImage:image withCompletion:^(NSString *imagePath, NSError *error) {
			if (!error) {
				NSDictionary *parameters = @{kFTRequestParamResourcePathObject: self.group.editableObject, @"message": imagePath, @"type": @"image"};
				[Message createWithParameters:parameters success:^(id response) {
					NSDictionary *parameters = @{kFTRequestParamResourcePathObject: self.group.editableObject, @"message": text, @"type": @"text"};
					[Message createWithParameters:parameters success:nil failure:failure];
				} failure:failure];
			} else {
				failure(nil, error);
			}
		}];
	} else if (image) {
		[FTImageUploader uploadImage:image withCompletion:^(NSString *imagePath, NSError *error) {
			if (!error) {
				NSDictionary *parameters = @{kFTRequestParamResourcePathObject: self.group.editableObject, @"message": imagePath, @"type": @"image"};
				[Message createWithParameters:parameters success:nil failure:failure];
			} else {
				failure(nil, error);
			}
		}];
	} else if (text.length > 0) {
		NSDictionary *parameters = @{kFTRequestParamResourcePathObject: self.group.editableObject, @"message": text, @"type": @"text"};
		[Message createWithParameters:parameters success:nil failure:failure];
	}
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
    
    cell.contentView.width = self.tableView.width;

	NSString *text = [message.typeString isEqualToString:@"text"] ? message.message : nil;
	NSURL *imageURL = [message.typeString isEqualToString:@"image"] ? [NSURL URLWithString:message.message] : nil;
    if (previousMessage && [previousMessage.user.slug isEqualToString:message.user.slug] && fabs([message.createdAt timeIntervalSinceDate:previousMessage.createdAt] < kChatSectionMaximumTimeInterval)) {
		[cell setProfileName:nil message:text imageURL:imageURL placeholder:nil pictureURL:nil date:nil shouldUseRightAlignment:message.user.isMeValue];
    } else {
		NSURL *pictureURL = [NSURL URLWithString:message.user.picture];
		[cell setProfileName:message.user.name message:text imageURL:imageURL placeholder:nil pictureURL:pictureURL date:message.createdAt shouldUseRightAlignment:message.user.isMeValue];
    }
    
    if (message.deliveryFailedValue) {
        cell.messageLabel.textColor = [UIColor colorWithRed:216/255.f green:80./255.f blue:80./255.f alpha:1.00];
    }
}

- (void)timerReloadData {
    [Message getWithGroup:self.group.editableObject page:0 shouldDeleteUntouchedObjects:NO success:nil failure:nil];
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
    NSUInteger maxMessageHeight = self.view.height / 4.45;
	NSUInteger messageHeight = MAX(self.messageImageView.height, [self.messageTextView sizeThatFits:CGSizeMake(self.messageTextView.width, INT_MAX)].height);
    messageHeight = MIN(maxMessageHeight, messageHeight);
    self.footerView.height = messageHeight + 20;
	
	UIImage *image = [self.shareButton imageForState:UIControlStateNormal];
	CGFloat shareButtonWidth = image.size.width + 20;
	self.shareButton.width = shareButtonWidth;
	
    CGFloat buttonWidth = [self.sendButton sizeThatFits:self.footerView.bounds.size].width + 20;
    self.sendButton.x = self.view.width - buttonWidth;
    self.sendButton.width = buttonWidth;
    self.messageTextView.frame = CGRectMake(0, -1, self.sendButton.x - shareButtonWidth, maxMessageHeight);
	
	NSCharacterSet *charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	BOOL hasText = [self.messageTextView.text stringByTrimmingCharactersInSet:charset].length > 0;
	BOOL hasImage = (self.messageImageView.image != nil);
	self.sendButton.enabled = (hasImage || hasText);
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
		self.shareButton.height = self.footerView.height;
        self.sendButton.height = self.footerView.height;
        self.messageBorderView.frame = CGRectMake(shareButtonWidth, 10, self.sendButton.x - shareButtonWidth, self.footerView.height - 20);
        self.footerView.y = self.view.height - 48 - self.keyboardSize.height - self.footerView.height;
        
        if (self.tableView.height != self.footerView.y - self.tableView.y) {
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + self.keyboardSize.height);
        }
        
        self.tableView.height = self.footerView.y - self.tableView.y;
    }];
}

- (void)scrollToLastMessageAnimated:(BOOL)animated {
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.canDismissKeyboard = NO;
    self.keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardVisible = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (float)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.canDismissKeyboard = YES;
    });
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
    ChatTableViewCell *cell = [(ChatTableViewCell *)[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    [self configureCell:cell atIndexPath:indexPath];
    return [cell sizeThatFits:CGSizeMake(tableView.width, INT_MAX)].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static BOOL iOS8;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iOS8 = [[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)];
    });
    
    if (iOS8) {
        return UITableViewAutomaticDimension;
    }
    
    ChatTableViewCell *cell = [(ChatTableViewCell *)[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    [self configureCell:cell atIndexPath:indexPath];
    return [cell sizeThatFits:CGSizeMake(tableView.width, INT_MAX)].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Message *previousMessage;
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        previousMessage = [self.fetchedResultsController objectAtIndexPath:previousIndexPath];
    }
    
    if (message.deliveryFailedValue) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message.message cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", @"")] destructiveButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Delete", @"") action:^{
            [[FTCoreDataStore privateQueueContext] performBlock:^{
                [[FTCoreDataStore privateQueueContext] deleteObject:message.editableObject];
                [[FTCoreDataStore privateQueueContext] performSave];
            }];
        }] otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"Send", @"") action:^{
            [message.editableObject deliverWithSuccess:^(id response) {
                [self.tableView reloadData];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[ErrorHandler sharedInstance] displayError:error];
            }];
        }], nil];
        [actionSheet showInView:self.view];
        return;
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
	} else if (textView.text.length == 0 && text.length == 0) { // backspace
		self.messageTextView.textContainer.exclusionPaths = nil;
		self.messageImageView.frame = CGRectZero;
		self.messageImageView.image = nil;
		[self reloadViewsAnimated:NO];
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
    if (!self.keyboardVisible || self.hasCreatedMessage || !self.canDismissKeyboard) {
        return;
    }
    
    CGFloat offset = self.tableView.contentSize.height - self.tableView.contentOffset.y;
    if (offset >= self.view.height - self.footerView.height) {
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
    self.tableView.frame = CGRectMake(0, 64, self.view.width, self.view.height - 64);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 5)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 5)];
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"ChatCell"];
    [self.view addSubview:self.tableView];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.width - 40, 200)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placeholderLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:15];
    self.placeholderLabel.textColor = [UIColor colorWithRed:156/255.f green:164/255.f blue:158/255.f alpha:1.00];
    self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
    self.placeholderLabel.text = NSLocalizedString(@"Chat placeholder", @"");
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = YES;
    [self.view addSubview:self.placeholderLabel];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 97, self.view.width, 49)];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.footerView.clipsToBounds = NO;
    [self.view addSubview:self.footerView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.footerView.width, self.view.height)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    backgroundView.backgroundColor = [FootblAppearance colorForView:FootblColorTabBarTint];
    [self.footerView addSubview:backgroundView];
	
	self.shareButton = [[UIButton alloc] initWithFrame:CGRectZero];
	self.shareButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	[self.shareButton setImage:[UIImage imageNamed:@"button-chat-share"] forState:UIControlStateNormal];
	[self.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.footerView addSubview:self.shareButton];
	
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
	
	self.messageImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	self.messageImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self.messageTextView addSubview:self.messageImageView];
	
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 50)];
    UIButton *nextPageButton = [[UIButton alloc] initWithFrame:self.headerView.bounds];
    nextPageButton.titleLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
    [nextPageButton setTitle:NSLocalizedString(@"Load more", @"") forState:UIControlStateNormal];
    [nextPageButton addTarget:self action:@selector(loadNextPage:) forControlEvents:UIControlEventTouchUpInside];
    [nextPageButton setTitleColor:[UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:1.00] forState:UIControlStateNormal];
    [nextPageButton setTitleColor:[UIColor colorWithRed:93./255.f green:107/255.f blue:97./255.f alpha:0.30] forState:UIControlStateHighlighted];
    [self.headerView addSubview:nextPageButton];
    
    [self reloadViewsAnimated:NO];
    
    [Message markAsReadFromGroup:self.group success:nil failure:nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kChatForceUpdateTimeInterval target:self selector:@selector(timerReloadData) userInfo:nil repeats:YES];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerReloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.fetchedResultsController = nil;
    [self.timer invalidate];
    self.timer = nil;
    [Message getWithGroup:self.group.editableObject page:0 shouldDeleteUntouchedObjects:YES success:nil failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
