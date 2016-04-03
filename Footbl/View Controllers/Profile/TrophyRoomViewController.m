//
//  TrophyRoomViewController.m
//  Footbl
//
//  Created by Leonardo Formaggio on 9/6/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "TrophyRoomViewController.h"
#import "FTBTrophy.h"
#import "TrophyRoomCollectionViewCell.h"
#import "TrophyRoomPopupViewController.h"
#import "UINavigationBar+UIProgressView.h"

@interface TrophyRoomViewController ()

@property (nonatomic, strong) NSArray *trophies;

@end

@implementation TrophyRoomViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.progressView.progress = 0.25;
	
	[self setupTrophies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)setupTrophies {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"trophies" ofType:@"json"];
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	self.trophies = [MTLJSONAdapter modelsOfClass:[FTBTrophy class] fromJSONArray:array error:nil];
}

- (void)configureCell:(TrophyRoomCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
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
	TrophyRoomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionReusableView *view = nil;
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
		UILabel *label = (UILabel *)[view viewWithTag:777];
		label.text = [NSString stringWithFormat:@"Complete to collect trophies: %ld%% complete", (long)25];
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
