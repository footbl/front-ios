//
//  MatchTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import "MatchTableViewCell.h"
#import "UIView+Frame.h"
#import "UserImageView.h"

#pragma mark MatchTableViewCell

CGPoint CGPointTranslate(CGPoint point, CGFloat tx, CGFloat ty) {
    point.x += tx;
    point.y += ty;
    return point;
}

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
        setAlphaToViews(@[self.hostNameLabel, self.hostPotLabel, self.hostImageView], alpha);
    };
    void(^setAlphaToDraw)(CGFloat alpha) = ^(CGFloat alpha) {
        setAlphaToViews(@[self.drawLabel, self.drawPotLabel, self.versusLabel], alpha);
    };
    void(^setAlphaToGuest)(CGFloat alpha) = ^(CGFloat alpha) {
        setAlphaToViews(@[self.guestNameLabel, self.guestPotLabel, self.guestImageView], alpha);
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
            self.cardContentView.height = 289;
            self.liveHeaderView.alpha = 0;
            self.cardContentView.layer.borderWidth = 0;
            
            [self setFirstSeparatorPosition:62];
            [self setSecondSeparatorPosition:236];
            
            // Bets
            self.stakeValueLabel.y = 7;
            self.returnValueLabel.y = self.stakeValueLabel.y;
            self.profitValueLabel.y = self.stakeValueLabel.y;
            self.stakeTitleLabel.y = 36;
            self.returnTitleLabel.y = self.stakeTitleLabel.y;
            self.profitTitleLabel.y = self.stakeTitleLabel.y;
            
            // Teams & Pots
            self.hostScoreLabel.alpha = 0;
            self.guestScoreLabel.alpha = 0;
            
            self.hostPotLabel.y = 99;
            self.drawPotLabel.y = self.hostPotLabel.y;
            self.guestPotLabel.y = self.hostPotLabel.y;
            
            self.hostNameLabel.y = 75;
            self.drawLabel.y = self.hostNameLabel.y;
            self.guestNameLabel.y = self.hostNameLabel.y;
            
            // Images
            self.versusLabel.y = 125;
            self.hostImageView.y = self.versusLabel.y;
            self.guestImageView.y = self.versusLabel.y;
            
            // Footer
            self.footerLabel.center = CGPointMake(self.footerLabel.center.x, 236 + 26);
            self.shareButton.y = 236;
            self.footerLabel.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
            break;
        case MatchTableViewCellStateLayoutLive:
        case MatchTableViewCellStateLayoutDone:
            self.cardContentView.height = 312;
            self.cardContentView.layer.borderWidth = 1;
            self.liveHeaderView.alpha = 1;
            
            CGFloat increment = 23;
            [self setFirstSeparatorPosition:62 + increment];
            [self setSecondSeparatorPosition:236 + increment + 7];
            
            // Bets
            self.stakeValueLabel.y = 7 + increment;
            self.returnValueLabel.y = self.stakeValueLabel.y;
            self.profitValueLabel.y = self.stakeValueLabel.y;
            self.stakeTitleLabel.y = 36 + increment;
            self.returnTitleLabel.y = self.stakeTitleLabel.y;
            self.profitTitleLabel.y = self.stakeTitleLabel.y;
            
            // Teams & Pots
            self.hostScoreLabel.alpha = 1;
            self.guestScoreLabel.alpha = 1;
            
            self.hostPotLabel.y = 99 + increment;
            self.drawPotLabel.y = self.hostPotLabel.y;
            self.guestPotLabel.y = self.hostPotLabel.y;
            
            self.hostNameLabel.y = 75 + increment;
            self.drawLabel.y = self.hostNameLabel.y;
            self.guestNameLabel.y = self.hostNameLabel.y;
            
            // Images
            self.versusLabel.y = 125 + increment;
            self.hostImageView.y = self.versusLabel.y;
            self.guestImageView.y = self.versusLabel.y;
            
            // Footer
            self.footerLabel.center = CGPointMake(self.footerLabel.center.x, 236 + increment + 2 + 26);
            self.footerLabel.backgroundColor = [UIColor clearColor];
            self.shareButton.y = 236 + increment + 2;
            break;
    }
    
    if (self.stateLayout == MatchTableViewCellStateLayoutLive) {
        self.liveHeaderView.backgroundColor = [UIColor ftb_greenLiveColor];
        self.footerLabel.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    } else if (self.stateLayout == MatchTableViewCellStateLayoutDone) {
        self.liveHeaderView.backgroundColor = [UIColor colorWithWhite:FBTweakValue(@"UI", @"Match", @"Border (Gray)", 0.7, 0.55, 0.8) alpha:1.0];
    }
    self.cardContentView.layer.borderColor = self.liveHeaderView.backgroundColor.CGColor;
    
    self.hostStepper.y = self.hostImageView.y;
    self.drawStepper.y = self.versusLabel.y;
    self.guestStepper.y = self.guestImageView.y;
    
    [UIView performWithoutAnimation:^{
        CGPoint footerLabelCenter = self.footerLabel.center;
        [self.footerLabel sizeToFit];
        if ((self.footerLabel.width + 20) < 45) {
            self.footerLabel.width = 45;
        } else {
            self.footerLabel.width += 20;
        }
        self.footerLabel.height += 5;
        self.footerLabel.layer.cornerRadius = self.footerLabel.height / 2;
        self.footerLabel.center = footerLabelCenter;
        
        if (self.footerLabel.text.length == 0 && (self.stateLayout == MatchTableViewCellStateLayoutDone || self.stateLayout == MatchTableViewCellStateLayoutLive)) {
            self.footerLabel.hidden = YES;
            self.shareButton.frame = CGRectMake(0, self.shareButton.y, self.cardContentView.width, self.shareButton.height);
        } else {
            self.footerLabel.hidden = NO;
            self.shareButton.frame = CGRectMake(13, self.shareButton.y, 86, self.shareButton.height);
        }
    }];
}

- (void)setColorScheme:(MatchTableViewCellColorScheme)colorScheme {
    _colorScheme = colorScheme;
    
    if (FBTweakValue(@"UI", @"Match", @"Highlight only profit", FT_ENABLE_HIGHLIGHT_ONLY_PROFIT)) {
        UIColor *grayColor = [UIColor colorWithRed:110/255.f green:130/255.f blue:119/255.f alpha:0.4];
        
        switch (self.colorScheme) {
            case MatchTableViewCellColorSchemeDefault:
                self.stakeValueLabel.textColor = [UIColor ftb_redStakeColor];
                self.returnValueLabel.textColor = [UIColor ftb_blueReturnColor];
                self.profitValueLabel.textColor = [UIColor ftb_greenMoneyColor];
                break;
            case MatchTableViewCellColorSchemeHighlightProfit:
                self.stakeValueLabel.textColor = grayColor;
                self.returnValueLabel.textColor = grayColor;
                self.profitValueLabel.textColor = [UIColor ftb_greenMoneyColor];
                break;
            case MatchTableViewCellColorSchemeGray:
                self.stakeValueLabel.textColor = grayColor;
                self.returnValueLabel.textColor = grayColor;
                self.profitValueLabel.textColor = grayColor;
                break;
        }
    } else {
        self.stakeValueLabel.textColor = [UIColor ftb_redStakeColor];
        self.returnValueLabel.textColor = [UIColor ftb_blueReturnColor];
        self.profitValueLabel.textColor = [UIColor ftb_greenMoneyColor];
    }
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor ftb_cellMatchBackgroundColor];
        self.backgroundColor = self.contentView.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.layout = MatchTableViewCellLayoutNoBet;
        self.stateLayout = MatchTableViewCellStateLayoutWaiting;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.contentView.width, 20)];
        self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dateLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.dateLabel.textColor = [UIColor colorWithRed:57/255.f green:73/255.f blue:61/255.f alpha:0.80];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:self.dateLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, self.dateLabel.midY, self.contentView.width - 24, 0.5)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [UIColor ftb_cellSeparatorColor];
        [self.contentView insertSubview:line belowSubview:self.dateLabel];
        
        self.cardContentView = [[UIView alloc] initWithFrame:CGRectMake(10, 45, self.contentView.width - 20, 319)];
        self.cardContentView.backgroundColor = [UIColor whiteColor];
        self.cardContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.cardContentView.layer.cornerRadius = 4;
        self.cardContentView.layer.shadowColor = [[UIColor ftb_cellSeparatorColor] colorWithAlphaComponent:1.0].CGColor;
        self.cardContentView.layer.shadowOpacity = 0.2;
        self.cardContentView.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.cardContentView.layer.shadowRadius = 1;
        self.cardContentView.layer.borderColor = [UIColor ftb_greenLiveColor].CGColor;
        self.cardContentView.layer.borderWidth = 0;
        [self.contentView addSubview:self.cardContentView];
        
        UIView *headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardContentView.width, 40)];
        headerContentView.layer.cornerRadius = self.cardContentView.layer.cornerRadius;
        headerContentView.clipsToBounds = YES;
        headerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.cardContentView addSubview:headerContentView];
        
        self.liveHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardContentView.width, 27)];
        self.liveHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [headerContentView addSubview:self.liveHeaderView];
        
        self.hostScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 86, self.liveHeaderView.height)];
        self.hostScoreLabel.textAlignment = NSTextAlignmentCenter;
        self.hostScoreLabel.textColor = [UIColor whiteColor];
        self.hostScoreLabel.font = [UIFont fontWithName:kFontNameBlack size:13];
        [self.liveHeaderView addSubview:self.hostScoreLabel];
        
        self.liveLabel = [[UILabel alloc] initWithFrame:self.liveHeaderView.bounds];
        self.liveLabel.textAlignment = NSTextAlignmentCenter;
        self.liveLabel.textColor = [UIColor whiteColor];
        self.liveLabel.font = [UIFont fontWithName:kFontNameBlack size:13];
        self.liveLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.liveHeaderView addSubview:self.liveLabel];
        
        self.guestScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(197, 0, 86, self.liveHeaderView.height)];
        self.guestScoreLabel.textAlignment = NSTextAlignmentCenter;
        self.guestScoreLabel.textColor = [UIColor whiteColor];
        self.guestScoreLabel.font = [UIFont fontWithName:kFontNameBlack size:13];
        self.guestScoreLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.liveHeaderView addSubview:self.guestScoreLabel];
        
        [@[@62, @256] enumerateObjectsUsingBlock:^(NSNumber *offsetY, NSUInteger idx, BOOL *stop) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY.floatValue, self.cardContentView.width, 0.5)];
            separatorView.backgroundColor = [UIColor ftb_cellSeparatorColor];
            separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
            UILabel *potLabel = label(frame, [UIColor ftb_cellMatchPotColor]);
            potLabel.font = [UIFont fontWithName:kFontNameMedium size:16];
            return potLabel;
        };
        
        UILabel * (^subtitleLabel)(CGRect frame, NSString *text) = ^(CGRect frame, NSString *text) {
            static NSDictionary *subtitleAttributes;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                paragraphStyle.alignment = NSTextAlignmentCenter;
                subtitleAttributes = @{NSForegroundColorAttributeName : [UIColor ftb_subtitleColor],
                                       NSParagraphStyleAttributeName : paragraphStyle,
                                       NSFontAttributeName : [UIFont fontWithName:kFontNameMedium size:12],
                                       NSKernAttributeName : @(-0.15)};
            });
            
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:frame];
            subtitleLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:subtitleAttributes];
            [self.cardContentView addSubview:subtitleLabel];
            return subtitleLabel;
        };
        
        UIImageView * (^teamImageView)(CGRect frame) = ^(CGRect frame) {
            UIImageView *teamImageView = [[UIImageView alloc] initWithFrame:frame];
            teamImageView.contentMode = UIViewContentModeScaleAspectFit;
            teamImageView.userInteractionEnabled = YES;
            [self.cardContentView addSubview:teamImageView];
            return teamImageView;
        };
        
        UIStepper * (^stepperBlock)(UIView *baseView) = ^(UIView *baseView) {
            UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(baseView.x - baseView.width, baseView.y, baseView.width * 2, baseView.height)];
            stepper.maximumValue = INT_MAX;
            stepper.tintColor = [UIColor clearColor];
            stepper.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            [stepper addTarget:self action:@selector(stepperAction:) forControlEvents:UIControlEventValueChanged];
            [self.cardContentView addSubview:stepper];
            return stepper;
        };
        
        // Bets
        self.stakeValueLabel = label(CGRectMake(12, 7, 89, 36), [UIColor ftb_redStakeColor]);
        self.returnValueLabel = label(CGRectMake(104, 7, 89, 36), [UIColor ftb_blueReturnColor]);
        self.returnValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.profitValueLabel = label(CGRectMake(197, 7, 89, 36), [UIColor ftb_greenMoneyColor]);
        self.profitValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.stakeTitleLabel = subtitleLabel(CGRectMake(10, 36, 89, 14), NSLocalizedString(@"Stake", @"").lowercaseString);
        self.returnTitleLabel = subtitleLabel(CGRectMake(104, 36, 89, 14), NSLocalizedString(@"To return", @"").lowercaseString);
        self.returnTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.profitTitleLabel = subtitleLabel(CGRectMake(197, 36, 89, 14), NSLocalizedString(@"Profit", @"").lowercaseString);
        self.profitTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        // Teams & Pots
        self.hostPotLabel = potLabel(CGRectMake(17, 99, 86, 18));
        self.drawPotLabel = potLabel(CGRectMake(113, 99, 74, 18));
        self.drawPotLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.guestPotLabel = potLabel(CGRectMake(197, 99, 86, 18));
        self.guestPotLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.hostNameLabel = label(CGRectMake(17, 75, 86, 28), [[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0]);
        self.hostNameLabel.font = [UIFont fontWithName:kFontNameBlack size:self.defaultTeamNameFontSize];
        [self.cardContentView addSubview:self.hostNameLabel];
        
        self.drawLabel = label(CGRectMake(113, 75, 74, 28), self.hostNameLabel.textColor);
        self.drawLabel.font = self.hostNameLabel.font;
        self.drawLabel.text = NSLocalizedString(@"Draw", @"");
        self.drawLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.cardContentView addSubview:self.drawLabel];
        
        self.guestNameLabel = label(CGRectMake(197, 75, 86, 28), self.hostNameLabel.textColor);
        self.guestNameLabel.font = self.hostNameLabel.font;
        self.guestNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.cardContentView addSubview:self.guestNameLabel];
        
        // Images
        self.hostImageView = teamImageView(CGRectMake(12, 130, 96, 96));
		self.hostImageViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
        [self.hostImageView addGestureRecognizer:self.hostImageViewGestureRecognizer];
        
        self.guestImageView = teamImageView(CGRectMake(192, 130, 96, 96));
        self.guestImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		self.guestImageViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
        [self.guestImageView addGestureRecognizer:self.guestImageViewGestureRecognizer];
		
		self.versusLabelGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
        self.versusLabel = label(CGRectMake(108, 130, 84, 96), [UIColor colorWithRed:110/255.f green:130/255.f blue:119/255.f alpha:1]);
        self.versusLabel.font = [UIFont fontWithName:kFontNameLight size:55];
        self.versusLabel.text = @"X";
        self.versusLabel.userInteractionEnabled = YES;
        self.versusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.versusLabel addGestureRecognizer:self.versusLabelGestureRecognizer];

        // Challenge
        self.hostUserImageView = [[UserImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.hostUserImageView.hidden = YES;
        [self.cardContentView addSubview:self.hostUserImageView];

        self.guestUserImageView = [[UserImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.guestUserImageView.hidden = YES;
        [self.cardContentView addSubview:self.guestUserImageView];

        self.drawUserImageView = [[UserImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.drawUserImageView.hidden = YES;
        [self.cardContentView addSubview:self.drawUserImageView];

        // Footer
        self.footerLabel = potLabel(CGRectMake(0, 256, self.cardContentView.width, 53));
        self.footerLabel.font = [UIFont fontWithName:self.footerLabel.font.fontName size:18];
        self.footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.footerLabel.clipsToBounds = YES;
        
        self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 256, 86, 55)];
        [self.shareButton setTitleColor:[[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
        [self.shareButton setTitleColor:[[UIColor ftb_cellMatchPotColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        [self.shareButton setTitle:NSLocalizedString(@"Share", @"") forState:UIControlStateNormal];
        self.shareButton.titleLabel.font = [UIFont fontWithName:kFontNameMedium size:14];
        [self.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.cardContentView addSubview:self.shareButton];

        self.hostStepper = stepperBlock(self.hostImageView);
        self.drawStepper = stepperBlock(self.versusLabel);
        self.drawStepper.autoresizingMask = self.versusLabel.autoresizingMask;
        self.guestStepper = stepperBlock(self.guestImageView);
        self.guestStepper.autoresizingMask = self.guestImageView.autoresizingMask;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.cardContentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardContentView.layer.bounds cornerRadius:4].CGPath;
    self.hostUserImageView.center = CGPointTranslate(self.hostImageView.center, 24, 24);
    self.guestUserImageView.center = CGPointTranslate(self.guestImageView.center, 24, 24);
    self.drawUserImageView.center = CGPointTranslate(self.versusLabel.center, 24, 24);
}

- (IBAction)shareAction:(id)sender {
    if (self.shareBlock) self.shareBlock(self);
}

- (UIImage *)imageRepresentation {
    BOOL footerLabelHidden = self.footerLabel.isHidden;
    BOOL shareButtonHidden = self.shareButton.isHidden;
    
    self.cardContentView.width = 300;
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.cardContentView.width + 10, self.cardContentView.height + 10)];
    CGPoint cardCenter = self.cardContentView.center;
    [tempView addSubview:self.cardContentView];
    self.cardContentView.center = tempView.center;
    
    self.footerLabel.hidden = YES;
    self.shareButton.hidden = YES;
    
    CGFloat centerY = CGRectGetMidY(self.footerLabel.frame) + (self.stateLayout == MatchTableViewCellStateLayoutLive ? 2 : 1);
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rounded_icon_small"]];
    iconImageView.frame = CGRectMake(0, 0, 30, 30);
    iconImageView.center = CGPointMake(68, centerY);
    [self.cardContentView addSubview:iconImageView];
    
    UILabel *footblLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, iconImageView.y - 1, 200, 30)];
    footblLabel.text = NSLocalizedString(@"Footbl", @"").lowercaseString;
    footblLabel.font = [UIFont fontWithName:kFontNameSystemLight size:24];
    footblLabel.textAlignment = NSTextAlignmentLeft;
    footblLabel.textColor = [UIColor blackColor];
    [self.cardContentView addSubview:footblLabel];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(160, iconImageView.y, 2, iconImageView.height - 1)];
    separatorView.backgroundColor = [[UIColor ftb_greenGrassColor] colorWithAlphaComponent:0.4];
    separatorView.clipsToBounds = YES;
    separatorView.layer.cornerRadius = 1;
    [self.cardContentView addSubview:separatorView];
    
    UILabel *betLabel = [[UILabel alloc] initWithFrame:CGRectMake(172, iconImageView.y - 1, 100, 30)];
    betLabel.text = NSLocalizedString(@"wanna bet?", @"").lowercaseString;
    betLabel.font = [UIFont systemFontOfSize:14];
    betLabel.textAlignment = NSTextAlignmentLeft;
    betLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.cardContentView addSubview:betLabel];
    
    UIGraphicsBeginImageContextWithOptions(tempView.frame.size, NO, 2.0);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.contentView addSubview:self.cardContentView];
    self.cardContentView.center = cardCenter;
    self.cardContentView.width = self.contentView.width - 20;
    
    self.footerLabel.hidden = footerLabelHidden;
    self.shareButton.hidden = shareButtonHidden;
    
    [iconImageView removeFromSuperview];
    [footblLabel removeFromSuperview];
    [separatorView removeFromSuperview];
    [betLabel removeFromSuperview];
    
    return image;
}

- (IBAction)stepperAction:(UIStepper *)stepper {
    if (!self.selectionBlock || !self.stepperUserInteractionEnabled) {
        return;
    }
    
    if (stepper == self.hostStepper) {
        self.selectionBlock(0);
    } else if (stepper == self.drawStepper) {
        self.selectionBlock(1);
    } else if (stepper == self.guestStepper) {
        self.selectionBlock(2);
    }
}

- (BOOL)isStepperSelected {
    return self.hostStepper.touchInside || self.drawStepper.touchInside || self.guestStepper.touchInside;
}

- (void)gestureRecognizerHandler:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.selectionBlock) {
        return;
    }
    
    if (gestureRecognizer.view == self.hostImageView) {
        self.selectionBlock(0);
    } else if (gestureRecognizer.view == self.guestImageView) {
        self.selectionBlock(2);
    } else if (gestureRecognizer.view == self.versusLabel) {
        self.selectionBlock(1);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (!self.simpleSelection) {
		if (FBTweakValue(@"UX", @"Match", @"Tap & Hold", FT_ENABLE_TAP_AND_HOLD)) {
			self.stepperUserInteractionEnabled = YES;
			
			self.hostStepper.userInteractionEnabled = YES;
			self.drawStepper.userInteractionEnabled = YES;
			self.guestStepper.userInteractionEnabled = YES;
			
			CGPoint convertedPoint = [self convertPoint:point toView:self.cardContentView];
			if (CGRectContainsPoint(self.hostImageView.frame, convertedPoint)) {
				return [self.hostStepper hitTest:CGPointMake(self.hostStepper.width - 30, 10) withEvent:event];
			} else if (CGRectContainsPoint(self.versusLabel.frame, convertedPoint)) {
				return [self.drawStepper hitTest:CGPointMake(self.drawStepper.width - 30, 10) withEvent:event];
			} else if (CGRectContainsPoint(self.guestImageView.frame, convertedPoint)) {
				return [self.guestStepper hitTest:CGPointMake(self.guestStepper.width - 30, 10) withEvent:event];
			}
		} else {
			self.hostStepper.userInteractionEnabled = NO;
			self.drawStepper.userInteractionEnabled = NO;
			self.guestStepper.userInteractionEnabled = NO;
		}
	}
	
    return [super hitTest:point withEvent:event];
}

- (CGFloat)defaultTeamNameFontSize {
    return 16.0;
}

- (void)setFirstSeparatorPosition:(CGFloat)position {
    [self.cardContentView viewWithTag:kFirstSeparatorTag].y = position;
}

- (void)setSecondSeparatorPosition:(CGFloat)position {
    [self.cardContentView viewWithTag:kSecondSeparatorTag].y = position;
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
    CGSize size = [dateText boundingRectWithSize:CGSizeMake(INT_MAX, INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:[[NSStringDrawingContext alloc] init]].size;
    CGRect frame = self.dateLabel.frame;
    frame.size.width = roundf(size.width) + 30;
    CGPoint center = self.dateLabel.center;
    
    [UIView performWithoutAnimation:^{
        self.dateLabel.frame = frame;
        self.dateLabel.center = center;
    }];
}

- (void)setFooterText:(NSString *)footerText {
    static NSDictionary *attributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        attributes = @{NSFontAttributeName : self.footerLabel.font,
                       NSForegroundColorAttributeName : self.footerLabel.textColor,
                       NSParagraphStyleAttributeName : paragraphStyle};
    });
    
    static NSDictionary *moneySignAttributes;
    static dispatch_once_t onceSecondToken;
    dispatch_once(&onceSecondToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        moneySignAttributes = @{NSFontAttributeName : [UIFont fontWithName:kFontNameAvenirNextRegular size:17],
                       NSForegroundColorAttributeName : self.footerLabel.textColor,
                       NSParagraphStyleAttributeName : paragraphStyle};
    });
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:footerText attributes:attributes];
    [attributedString setAttributes:moneySignAttributes range:[footerText rangeOfString:NSLocalizedString(@"$", @"")]];
    self.footerLabel.attributedText = attributedString;
}

- (void)setSimpleSelection:(BOOL)simpleSelection {
	_simpleSelection = simpleSelection;
	
	self.stepperUserInteractionEnabled = !simpleSelection;
	self.shareButton.userInteractionEnabled = !simpleSelection;
	self.shareButton.hidden = simpleSelection;
	
	self.hostImageViewGestureRecognizer.enabled = !simpleSelection;
	self.guestImageViewGestureRecognizer.enabled = !simpleSelection;
	self.versusLabelGestureRecognizer.enabled = !simpleSelection;
}

@end
