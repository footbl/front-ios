//
//  ProfileTableViewCell.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/20/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <StyledPageControl/StyledPageControl.h>
#import "ProfileTableViewCell.h"
#import "UIView+Frame.h"

@interface ProfileTableViewCell () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *verifiedImageView;
@property (strong, nonatomic) StyledPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *aboutLabel;

@end

#pragma mark ProfileTableViewCell

@implementation ProfileTableViewCell

#pragma mark - Getters/Setters

- (void)setVerified:(BOOL)verified {
    _verified = verified;
    
    self.verifiedImageView.hidden = !self.isVerified;
}

- (void)setAboutText:(NSString *)aboutText {
    _aboutText = aboutText;
    
    CGFloat originY = 20;
    if (aboutText.length > 0) {
        originY = 16;
        self.pageControl.numberOfPages = 2;
        self.scrollView.scrollEnabled = YES;
    } else {
        self.pageControl.numberOfPages = 1;
        self.scrollView.scrollEnabled = NO;
    }
    
    self.usernameLabel.frameY = originY;
    originY += 17;
    self.nameLabel.frameY = originY;
    originY += 17;
    self.dateLabel.frameY = originY;
    
    self.aboutLabel.text = aboutText;
}

#pragma mark - Instance Methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [FootblAppearance colorForView:FootblColorViewMatchBackground];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 44, 44)];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = CGRectGetWidth(self.profileImageView.frame) / 2;
        self.profileImageView.image = self.placeholderImage;
        [self.contentView addSubview:self.profileImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 16, 185, 22)];
        self.usernameLabel.font = [UIFont fontWithName:kFontNameAvenirNextDemiBold size:16];
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        self.usernameLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:1.0];
        [self.contentView addSubview:self.usernameLabel];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.profileImageView.frame), 0, CGRectGetWidth(self.contentView.frame) - 50, self.contentView.frameHeight)];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frameWidth * 2, self.scrollView.frameHeight);
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self.contentView insertSubview:self.scrollView belowSubview:self.profileImageView];
        
        UIView *opaqueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMidX(self.profileImageView.frame), self.contentView.frameHeight)];
        opaqueView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        opaqueView.backgroundColor = self.contentView.backgroundColor;
        [self.contentView insertSubview:opaqueView belowSubview:self.profileImageView];
        
        UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(opaqueView.frame), 0, self.usernameLabel.frameX - CGRectGetMaxX(opaqueView.frame), self.contentView.frameHeight)];
        gradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer new];
        gradientLayer.colors = @[(id)self.contentView.backgroundColor.CGColor, (id)[self.contentView.backgroundColor colorWithAlphaComponent:0].CGColor];
        gradientLayer.frame = CGRectMake(0, 0, gradientView.frameWidth, 93);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.locations = @[@0.5, @1];
        [gradientView.layer insertSublayer:gradientLayer atIndex:0];
        
        [self.contentView insertSubview:gradientView belowSubview:self.profileImageView];
        
        CGRect nameFrame = self.usernameLabel.frame;
        nameFrame.origin.y += 17;
        nameFrame.origin.x -= self.scrollView.frameX;
        self.nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        self.nameLabel.font = [UIFont fontWithName:kFontNameMedium size:13];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor colorWithRed:141/255.f green:151/255.f blue:144/255.f alpha:1.00];
        [self.scrollView addSubview:self.nameLabel];
        
        CGRect dateFrame = self.nameLabel.frame;
        dateFrame.origin.y += 17;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:dateFrame];
        self.dateLabel.font = [UIFont fontWithName:kFontNameAvenirNextMedium size:10];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        self.dateLabel.textColor = [[FootblAppearance colorForView:FootblColorCellMatchPot] colorWithAlphaComponent:0.6];
        [self.scrollView addSubview:self.dateLabel];
        
        CGRect aboutFrame = self.nameLabel.frame;
        aboutFrame.size.height = 40;
        aboutFrame.origin.x += self.scrollView.frameWidth;
        self.aboutLabel = [[UILabel alloc] initWithFrame:aboutFrame];
        self.aboutLabel.font = self.nameLabel.font;
        self.aboutLabel.textAlignment = self.nameLabel.textAlignment;
        self.aboutLabel.textColor = self.nameLabel.textColor;
        self.aboutLabel.numberOfLines = 2;
        self.aboutLabel.adjustsFontSizeToFitWidth = YES;
        self.aboutLabel.minimumScaleFactor = 0.8;
        [self.scrollView addSubview:self.aboutLabel];
        
        self.verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verified_badge"]];
        self.verifiedImageView.hidden = YES;
        self.verifiedImageView.frame = CGRectMake(185, 23, 16, 16);
        [self.contentView addSubview:self.verifiedImageView];
        
        self.starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_inactive"] highlightedImage:[UIImage imageNamed:@"star_active"]];
        self.starImageView.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 40, CGRectGetMidY(self.nameLabel.frame));
        [self.contentView addSubview:self.starImageView];
        
        self.followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.followersLabel.center = CGPointMake(CGRectGetMidX(self.starImageView.frame), CGRectGetMidY(self.starImageView.frame) + 25);
        self.followersLabel.textColor = self.nameLabel.textColor;
        self.followersLabel.font = self.nameLabel.font;
        self.followersLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.followersLabel];
        
        gradientView = [[UIView alloc] initWithFrame:CGRectMake(self.starImageView.frameX - 10, 0, self.contentView.frameWidth - self.starImageView.frameX + 10, self.contentView.frameHeight)];
        gradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        gradientLayer = [CAGradientLayer new];
        gradientLayer.colors = @[(id)[self.contentView.backgroundColor colorWithAlphaComponent:0].CGColor, (id)self.contentView.backgroundColor.CGColor];
        gradientLayer.frame = CGRectMake(0, 0, gradientView.frameWidth, 93);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.locations = @[@0.3, @.7];
        [gradientView.layer insertSublayer:gradientLayer atIndex:0];
        
        [self.contentView insertSubview:gradientView belowSubview:self.profileImageView];
        
        self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, 76, CGRectGetWidth(self.contentView.frame), 10)];
        self.pageControl.numberOfPages = 2;
        self.pageControl.currentPage = 0;
        self.pageControl.coreSelectedColor = [UIColor colorWithRed:0.6 green:0.65 blue:0.61 alpha:1];
        self.pageControl.coreNormalColor = self.contentView.backgroundColor;
        self.pageControl.strokeNormalColor = self.pageControl.coreSelectedColor;
        self.pageControl.strokeSelectedColor = self.pageControl.coreSelectedColor;
        self.pageControl.strokeWidth = 1;
        self.pageControl.diameter = 7;
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.gapWidth = 5;
        self.pageControl.userInteractionEnabled = NO;
        [self.contentView addSubview:self.pageControl];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 92.5, CGRectGetWidth(self.contentView.frame), 0.5)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.83 alpha:1];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:separatorView];
    }
    return self;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"avatarless_user"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    self.starImageView.highlighted = highlighted || self.isSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.starImageView.highlighted = selected;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frameWidth);
}

@end
