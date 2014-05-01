//
//  MatchTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "MatchTableViewCell.h"
#import "TeamImageView.h"
#import "UIView+Frame.h"

#pragma mark MatchTableViewCell

@implementation MatchTableViewCell

static NSInteger kFirstSeparatorTag = 5138;
static NSInteger kSecondSeparatorTag = 5139;
static CGFloat kDisabledAlpha = 0.4;

#pragma mark - Getters/Setters

- (void)setLayout:(MatchTableViewCellLayout)layout {
    _layout = layout;
    
    if (!self.hostNameLabel) {
        return;
    }
    
    void(^setAlphaToViews)(NSArray *views, CGFloat alpha) = ^(NSArray *views, CGFloat alpha) {
        [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if (view.alpha != alpha) {
                view.alpha = alpha;
            }
        }];
    };
    void(^setAlphaToHost)(CGFloat alpha) = ^(CGFloat alpha) {
        setAlphaToViews(@[self.hostNameLabel, self.hostPotLabel], alpha);
        if (alpha == kDisabledAlpha) {
            self.hostImageView.alpha = 0;
        } else {
            self.hostImageView.alpha = 1;
        }
    };
    void(^setAlphaToDraw)(CGFloat alpha) = ^(CGFloat alpha) {
        setAlphaToViews(@[self.drawLabel, self.drawPotLabel, self.versusLabel], alpha);
    };
    void(^setAlphaToGuest)(CGFloat alpha) = ^(CGFloat alpha) {
        setAlphaToViews(@[self.guestNameLabel, self.guestPotLabel], alpha);
        if (alpha == kDisabledAlpha) {
            self.guestImageView.alpha = 0;
        } else {
            self.guestImageView.alpha = 1;
        }
    };
    
    switch (self.layout) {
        case MatchTableViewCellLayoutNoBet:
            setAlphaToHost(1);
            setAlphaToDraw(1);
            setAlphaToGuest(1);
            break;
        case MatchTableViewCellLayoutHost:
            setAlphaToHost(1);
            setAlphaToDraw(kDisabledAlpha);
            setAlphaToGuest(kDisabledAlpha);
            break;
        case MatchTableViewCellLayoutDraw:
            setAlphaToHost(kDisabledAlpha);
            setAlphaToDraw(1);
            setAlphaToGuest(kDisabledAlpha);
            break;
        case MatchTableViewCellLayoutGuest:
            setAlphaToHost(kDisabledAlpha);
            setAlphaToDraw(kDisabledAlpha);
            setAlphaToGuest(1);
            break;
    }
}

- (void)setStateLayout:(MatchTableViewCellStateLayout)stateLayout {
    _stateLayout = stateLayout;
    
    switch (self.stateLayout) {
        case MatchTableViewCellStateLayoutWaiting:
            self.cardContentView.frameHeight = 319;
            self.liveHeaderView.alpha = 0;
            self.cardContentView.layer.borderWidth = 0;
            
            [self setFirstSeparatorPosition:62];
            [self setSecondSeparatorPosition:256];
            
            // Bets
            self.stakeValueLabel.frameY = 12;
            self.returnValueLabel.frameY = self.stakeValueLabel.frameY;
            self.profitValueLabel.frameY = self.stakeValueLabel.frameY;
            self.stakeTitleLabel.frameY = 36;
            self.returnTitleLabel.frameY = self.stakeTitleLabel.frameY;
            self.profitTitleLabel.frameY = self.stakeTitleLabel.frameY;
            
            // Teams & Pots
            self.hostScoreLabel.alpha = 0;
            self.guestScoreLabel.alpha = 0;
            
            self.hostPotLabel.frameY = 99;
            self.drawPotLabel.frameY = self.hostPotLabel.frameY;
            self.guestPotLabel.frameY = self.hostPotLabel.frameY;
            
            self.hostNameLabel.frameY = 75;
            self.drawLabel.frameY = self.hostNameLabel.frameY;
            self.guestNameLabel.frameY = self.hostNameLabel.frameY;
            
            // Images
            self.versusLabel.frameY = 130;
            self.hostImageView.frameY = self.versusLabel.frameY;
            self.hostDisabledImageView.frameY = self.versusLabel.frameY;
            self.guestImageView.frameY = self.versusLabel.frameY;
            self.guestDisabledImageView.frameY = self.versusLabel.frameY;
            
            // Footer
            self.footerLabel.frameY = 256;
            break;
        case MatchTableViewCellStateLayoutLive:
            self.cardContentView.frameHeight = 372;
            self.cardContentView.layer.borderWidth = 1;
            self.liveHeaderView.alpha = 1;
            
            CGFloat increment = 23;
            [self setFirstSeparatorPosition:62 + increment];
            [self setSecondSeparatorPosition:256 + increment + increment + 7];
            
            // Bets
            self.stakeValueLabel.frameY = 12 + increment;
            self.returnValueLabel.frameY = self.stakeValueLabel.frameY;
            self.profitValueLabel.frameY = self.stakeValueLabel.frameY;
            self.stakeTitleLabel.frameY = 36 + increment;
            self.returnTitleLabel.frameY = self.stakeTitleLabel.frameY;
            self.profitTitleLabel.frameY = self.stakeTitleLabel.frameY;
            
            // Teams & Pots
            self.hostScoreLabel.alpha = 1;
            self.guestScoreLabel.alpha = 1;
            self.hostScoreLabel.frameY = 101;
            self.guestScoreLabel.frameY = self.hostScoreLabel.frameY;
            
            increment += 30;
            
            self.hostPotLabel.frameY = 99 + increment;
            self.drawPotLabel.frameY = self.hostPotLabel.frameY;
            self.guestPotLabel.frameY = self.hostPotLabel.frameY;
            
            self.hostNameLabel.frameY = 75 + increment;
            self.drawLabel.frameY = self.hostNameLabel.frameY;
            self.guestNameLabel.frameY = self.hostNameLabel.frameY;
            
            // Images
            self.versusLabel.frameY = 130 + increment;
            self.hostImageView.frameY = self.versusLabel.frameY;
            self.hostDisabledImageView.frameY = self.versusLabel.frameY;
            self.guestImageView.frameY = self.versusLabel.frameY;
            self.guestDisabledImageView.frameY = self.versusLabel.frameY;
            
            // Footer
            self.footerLabel.frameY = 256 + increment;
            break;
        case MatchTableViewCellStateLayoutDone: {
            self.cardContentView.frameHeight = 345;
            self.liveHeaderView.alpha = 0;
            self.cardContentView.layer.borderWidth = 0;
            
            CGFloat increment = 30;
            [self setFirstSeparatorPosition:62];
            [self setSecondSeparatorPosition:256 + increment];
            
            // Bets
            self.stakeValueLabel.frameY = 12;
            self.returnValueLabel.frameY = self.stakeValueLabel.frameY;
            self.profitValueLabel.frameY = self.stakeValueLabel.frameY;
            self.stakeTitleLabel.frameY = 36;
            self.returnTitleLabel.frameY = self.stakeTitleLabel.frameY;
            self.profitTitleLabel.frameY = self.stakeTitleLabel.frameY;
            
            // Teams & Pots
            self.hostScoreLabel.alpha = 1;
            self.guestScoreLabel.alpha = 1;
            self.hostScoreLabel.frameY = 77;
            self.guestScoreLabel.frameY = self.hostScoreLabel.frameY;
            
            self.hostPotLabel.frameY = 103 + increment;
            self.drawPotLabel.frameY = self.hostPotLabel.frameY;
            self.guestPotLabel.frameY = self.hostPotLabel.frameY;
            
            self.hostNameLabel.frameY = 77 + increment;
            self.drawLabel.frameY = self.hostNameLabel.frameY;
            self.guestNameLabel.frameY = self.hostNameLabel.frameY;
            
            // Images
            self.versusLabel.frameY = 136 + increment;
            self.hostImageView.frameY = self.versusLabel.frameY;
            self.hostDisabledImageView.frameY = self.versusLabel.frameY;
            self.guestImageView.frameY = self.versusLabel.frameY;
            self.guestDisabledImageView.frameY = self.versusLabel.frameY;
            
            // Footer
            self.footerLabel.frameY = 256 + increment;
            break;
        }
    }
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [FootblAppearance colorForView:FootblColorCellMatchBackground];
        self.backgroundColor = self.contentView.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.layout = MatchTableViewCellLayoutNoBet;
        self.stateLayout = MatchTableViewCellStateLayoutWaiting;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.contentView.frame), 20)];
        self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dateLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.dateLabel.textColor = [UIColor colorWithRed:57/255.f green:73/255.f blue:61/255.f alpha:0.80];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:self.dateLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetMidY(self.dateLabel.frame), CGRectGetWidth(self.contentView.frame) - 24, 0.5)];
        line.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator];
        [self.contentView insertSubview:line belowSubview:self.dateLabel];
        
        self.cardContentView = [[UIView alloc] initWithFrame:CGRectMake(10, 35, 300, 319)];
        self.cardContentView.backgroundColor = [UIColor whiteColor];
        self.cardContentView.layer.cornerRadius = 4;
        self.cardContentView.layer.shadowColor = [[FootblAppearance colorForView:FootblColorCellSeparator] colorWithAlphaComponent:1.0].CGColor;
        self.cardContentView.layer.shadowOpacity = 0.2;
        self.cardContentView.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.cardContentView.layer.shadowRadius = 1;
        self.cardContentView.layer.borderColor = [UIColor ftGreenLiveColor].CGColor;
        self.cardContentView.layer.borderWidth = 0;
        [self.contentView addSubview:self.cardContentView];
        
        UIView *headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardContentView.frameWidth, 40)];
        headerContentView.layer.cornerRadius = self.cardContentView.layer.cornerRadius;
        headerContentView.clipsToBounds = YES;
        [self.cardContentView addSubview:headerContentView];
        
        self.liveHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardContentView.frameWidth, 27)];
        self.liveHeaderView.backgroundColor = [UIColor ftGreenLiveColor];
        [headerContentView addSubview:self.liveHeaderView];
        
        self.liveLabel = [[UILabel alloc] initWithFrame:self.liveHeaderView.bounds];
        self.liveLabel.textAlignment = NSTextAlignmentCenter;
        self.liveLabel.textColor = [UIColor whiteColor];
        self.liveLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        [self.liveHeaderView addSubview:self.liveLabel];
        
        [@[@62, @256] enumerateObjectsUsingBlock:^(NSNumber *offsetY, NSUInteger idx, BOOL *stop) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY.floatValue, CGRectGetWidth(self.cardContentView.frame), 0.5)];
            separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator];
            separatorView.tag = (idx == 0 ? kFirstSeparatorTag : kSecondSeparatorTag);
            [self.cardContentView addSubview:separatorView];
        }];
        
        UILabel * (^label)(CGRect frame, UIColor *color) = ^(CGRect frame, UIColor *color) {
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.textColor = color;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:kFontNameMedium size:24];
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [self.cardContentView addSubview:label];
            return label;
        };
        
        UILabel * (^potLabel)(CGRect frame) = ^(CGRect frame) {
            UILabel *potLabel = label(frame, [FootblAppearance colorForView:FootblColorCellMatchPot]);
            potLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
            return potLabel;
        };
        
        UILabel * (^subtitleLabel)(CGRect frame, NSString *text) = ^(CGRect frame, NSString *text) {
            static NSDictionary *subtitleAttributes;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                paragraphStyle.alignment = NSTextAlignmentCenter;
                subtitleAttributes = @{NSForegroundColorAttributeName : [UIColor ftSubtitleColor],
                                       NSParagraphStyleAttributeName : paragraphStyle,
                                       NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:12],
                                       NSKernAttributeName : @(-0.15)};
            });
            
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:frame];
            subtitleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:subtitleAttributes];
            [self.cardContentView addSubview:subtitleLabel];
            return subtitleLabel;
        };
        
        TeamImageView * (^teamImageView)(CGRect frame) = ^(CGRect frame) {
            TeamImageView *teamImageView = [[TeamImageView alloc] initWithFrame:frame];
            teamImageView.contentMode = UIViewContentModeScaleAspectFit;
            teamImageView.userInteractionEnabled = YES;
            [self.cardContentView addSubview:teamImageView];
            return teamImageView;
        };
        
        // Bets
        self.stakeValueLabel = label(CGRectMake(12, 12, 89, 26), [UIColor ftRedStakeColor]);
        self.returnValueLabel = label(CGRectMake(104, 12, 89, 26), [UIColor ftBlueReturnColor]);
        self.profitValueLabel = label(CGRectMake(197, 12, 89, 26), [UIColor ftGreenMoneyColor]);
        self.stakeTitleLabel = subtitleLabel(CGRectMake(10, 36, 89, 14), NSLocalizedString(@"Stake", @"").lowercaseString);
        self.returnTitleLabel = subtitleLabel(CGRectMake(104, 36, 89, 14), NSLocalizedString(@"To return", @"").lowercaseString);
        self.profitTitleLabel = subtitleLabel(CGRectMake(197, 36, 89, 14), NSLocalizedString(@"Profit", @"").lowercaseString);
        
        // Teams & Pots
        self.hostPotLabel = potLabel(CGRectMake(17, 99, 86, 18));
        self.drawPotLabel = potLabel(CGRectMake(113, 99, 74, 18));
        self.guestPotLabel = potLabel(CGRectMake(197, 99, 86, 18));
        
        self.hostScoreLabel = label(CGRectMake(12, 101, 96, 24), [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0]);
        self.hostScoreLabel.font = [UIFont fontWithName:kFontNameLight size:30];
        self.hostScoreLabel.text = @"4";
        
        self.guestScoreLabel = label(CGRectMake(192, 101, 96, 24), [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0]);
        self.guestScoreLabel.font = [UIFont fontWithName:kFontNameLight size:30];
        self.guestScoreLabel.text = @"1";
        
        self.hostNameLabel = label(CGRectMake(17, 75, 86, 28), [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0]);
        self.hostNameLabel.font = [UIFont fontWithName:kFontNameBlack size:self.defaultTeamNameFontSize];
        [self.cardContentView addSubview:self.hostNameLabel];
        
        self.drawLabel = label(CGRectMake(113, 75, 74, 28), self.hostNameLabel.textColor);
        self.drawLabel.font = self.hostNameLabel.font;
        self.drawLabel.text = NSLocalizedString(@"Draw", @"");
        [self.cardContentView addSubview:self.drawLabel];
        
        self.guestNameLabel = label(CGRectMake(197, 75, 86, 28), self.hostNameLabel.textColor);
        self.guestNameLabel.font = self.hostNameLabel.font;
        [self.cardContentView addSubview:self.guestNameLabel];
        
        // Images
        self.hostDisabledImageView = teamImageView(CGRectMake(12, 130, 96, 96));
        self.hostDisabledImageView.tintColor = [UIColor grayColor];
        self.hostDisabledImageView.alpha = kDisabledAlpha;
        [self.hostDisabledImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)]];
        self.hostImageView = teamImageView(CGRectMake(12, 130, 96, 96));
        [self.hostImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)]];
        self.guestDisabledImageView = teamImageView(CGRectMake(192, 130, 96, 96));
        self.guestDisabledImageView.tintColor = [UIColor grayColor];
        self.guestDisabledImageView.alpha = kDisabledAlpha;
        [self.guestDisabledImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)]];
        self.guestImageView = teamImageView(CGRectMake(192, 130, 96, 96));
        [self.guestImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)]];
        
        self.versusLabel = label(CGRectMake(108, 130, 84, 96), [UIColor colorWithRed:110/255.f green:130/255.f blue:119/255.f alpha:1]);
        self.versusLabel.font = [UIFont fontWithName:kFontNameLight size:55];
        self.versusLabel.text = @"X";
        self.versusLabel.userInteractionEnabled = YES;
        [self.versusLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)]];
        
        // Footer
        self.footerLabel = potLabel(CGRectMake(0, 256, 300, 63));
    }
    return self;
}

- (void)gestureRecognizerHandler:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.selectionBlock) {
        return;
    }
    
    if (gestureRecognizer.view == self.hostImageView || gestureRecognizer.view == self.hostDisabledImageView) {
        self.selectionBlock(0);
    } else if (gestureRecognizer.view == self.guestImageView || gestureRecognizer.view == self.guestDisabledImageView) {
        self.selectionBlock(2);
    } else if (gestureRecognizer.view == self.versusLabel) {
        self.selectionBlock(1);
    }
}

- (CGFloat)defaultTeamNameFontSize {
    return 16.0;
}

- (void)setFirstSeparatorPosition:(CGFloat)position {
    [self.cardContentView viewWithTag:kFirstSeparatorTag].frameY = position;
}

- (void)setSecondSeparatorPosition:(CGFloat)position {
    [self.cardContentView viewWithTag:kSecondSeparatorTag].frameY = position;
}

- (void)setStakesCount:(NSNumber *)stakesCount commentsCount:(NSNumber *)commentsCount {
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%i stakes and %i comments", @"{number of stakes} stakes and {number of comments} comments"), stakesCount.integerValue, commentsCount.integerValue];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *attributes = [@{NSForegroundColorAttributeName : [FootblAppearance colorForView:FootblColorCellMatchPot],
                                         NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:15],
                                         NSParagraphStyleAttributeName : paragraphStyle} mutableCopy];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    attributes[NSForegroundColorAttributeName] = [attributes[NSForegroundColorAttributeName] colorWithAlphaComponent:1.00];
    [attributedString setAttributes:attributes range:[text rangeOfString:[NSString stringWithFormat:@"%li", stakesCount.unsignedLongValue]]];
    [attributedString setAttributes:attributes range:[text rangeOfString:[NSString stringWithFormat:@"%li", commentsCount.unsignedLongValue]]];
    
    self.footerLabel.attributedText = attributedString;
}

- (void)setDateText:(NSString *)dateText {
    static NSDictionary *attributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        attributes = @{NSFontAttributeName : self.dateLabel.font,
                       NSForegroundColorAttributeName : self.dateLabel.textColor,
                       NSParagraphStyleAttributeName : paragraphStyle};
    });
    
    self.dateLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", dateText] attributes:attributes];
    CGSize size = [dateText boundingRectWithSize:CGSizeMake(INT_MAX, INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:[NSStringDrawingContext new]].size;
    CGRect frame = self.dateLabel.frame;
    frame.size.width = roundf(size.width) + 30;
    CGPoint center = self.dateLabel.center;
    
    [UIView performWithoutAnimation:^{
        self.dateLabel.frame = frame;
        self.dateLabel.center = center;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
