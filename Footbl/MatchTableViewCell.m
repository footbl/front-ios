//
//  MatchTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/27/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "MatchTableViewCell.h"

#pragma mark MatchTableViewCell

@implementation MatchTableViewCell

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [FootblAppearance colorForView:FootblColorCellMatchBackground];
        self.backgroundColor = self.contentView.backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, CGRectGetWidth(self.contentView.frame), 20)];
        self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dateLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.dateLabel.textColor = [UIColor colorWithRed:57/255.f green:73/255.f blue:61/255.f alpha:0.80];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:self.dateLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetMidY(self.dateLabel.frame), CGRectGetWidth(self.contentView.frame) - 24, 0.5)];
        line.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator] ;
        [self.contentView insertSubview:line belowSubview:self.dateLabel];
        
        self.cardContentView = [[UIView alloc] initWithFrame:CGRectMake(10, 35, 300, 319)];
        self.cardContentView.backgroundColor = [UIColor whiteColor];
        self.cardContentView.layer.cornerRadius = 4;
        self.cardContentView.layer.shadowColor = [[FootblAppearance colorForView:FootblColorCellSeparator] colorWithAlphaComponent:1.0].CGColor;
        self.cardContentView.layer.shadowOpacity = 0.2;
        self.cardContentView.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.cardContentView.layer.shadowRadius = 1;
        [self.contentView addSubview:self.cardContentView];
        
        for (NSNumber *offsetY in @[@62, @256]) {
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY.floatValue, CGRectGetWidth(self.cardContentView.frame), 0.5)];
            separatorView.backgroundColor = [FootblAppearance colorForView:FootblColorCellSeparator];
            [self.cardContentView addSubview:separatorView];
        }
        
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
        
        UIImageView * (^teamImageView)(CGRect frame) = ^(CGRect frame) {
            UIImageView *teamImageView = [[UIImageView alloc] initWithFrame:frame];
            teamImageView.contentMode = UIViewContentModeScaleAspectFit;
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
        
        self.hostNameLabel = label(CGRectMake(17, 80, 86, 18), [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0]);
        self.hostNameLabel.font = [UIFont fontWithName:kFontNameBlack size:16];
        [self.cardContentView addSubview:self.hostNameLabel];
        
        UILabel *drawLabel = label(CGRectMake(113, 80, 74, 18), self.hostNameLabel.textColor);
        drawLabel.font = self.hostNameLabel.font;
        drawLabel.text = NSLocalizedString(@"Draw", @"");
        [self.cardContentView addSubview:drawLabel];
        
        self.guestNameLabel = label(CGRectMake(197, 80, 86, 18), self.hostNameLabel.textColor);
        self.guestNameLabel.font = self.hostNameLabel.font;
        [self.cardContentView addSubview:self.guestNameLabel];
        
        // Images
        self.hostImageView = teamImageView(CGRectMake(12, 130, 96, 96));
        self.guestImageView = teamImageView(CGRectMake(192, 130, 96, 96));
        
        UILabel *versusLabel = label(CGRectMake(108, 130, 84, 96), [UIColor colorWithRed:110/255.f green:130/255.f blue:119/255.f alpha:1]);
        versusLabel.font = [UIFont fontWithName:kFontNameLight size:55];
        versusLabel.text = @"X";
        
        // Footer
        self.footerLabel = potLabel(CGRectMake(0, 256, 300, 63));
    }
    return self;
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
    self.dateLabel.frame = frame;
    self.dateLabel.center = center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
