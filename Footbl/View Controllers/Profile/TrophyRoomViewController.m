//
//  TrophyRoomViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "TrophyRoomViewController.h"
#import "TrophyRoomCell.h"
#import "TrophyRoomPopupViewController.h"
#import "UINavigationBar+UIProgressView.h"

#import "FTBTrophy.h"

@interface TrophyRoomViewController ()

@property (nonatomic, strong) NSArray *trophies;

@end

@implementation TrophyRoomViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupProgressView];
	[self setupTrophies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)setupTrophies {
	NSMutableArray *trophies = [[NSMutableArray alloc] init];
	while (trophies.count < 60) {
		NSDictionary *dict = @{@"progressive": @YES, @"progress": @0.3, @"title": @"Endurer", @"subtitle": @"Bet in 3 consecutive seasons.", @"imageName": @"footbl_circle"};
		FTBTrophy *trophy = [[FTBTrophy alloc] initWithDictionary:dict error:nil];
		[trophies addObject:trophy];
	}
	self.trophies = trophies;
}

- (void)setupProgressView {
	UINavigationBar *navigationBar = self.navigationController.navigationBar;
	UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	progressView.progressTintColor = self.view.tintColor;
	progressView.progress = 0.3;
	[navigationBar addProgressView:progressView];
}

- (void)configureCell:(TrophyRoomCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FTBTrophy *trophy = self.trophies[indexPath.row];
	cell.iconImageView.image = [UIImage imageNamed:trophy.imageName];
	cell.nameLabel.text = trophy.title;
	cell.progressView.progress = trophy.progress.floatValue;
	cell.progressView.hidden = !trophy.isProgressive;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.trophies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	TrophyRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionReusableView *view = nil;
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
	}
	return view;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	TrophyRoomPopupViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrophyRoomPopupViewController"];
	viewController.trophy = self.trophies[indexPath.row];
	[self presentViewController:viewController animated:YES completion:nil];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
