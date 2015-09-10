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
#import "FTBTrophy.h"

@interface TrophyRoomViewController ()

@property (nonatomic, strong) NSArray *trophies;

@end

@implementation TrophyRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)configureCell:(TrophyRoomCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FTBTrophy *trophy = self.trophies[indexPath.row];
	cell.iconImageView.image = [UIImage imageNamed:trophy.imageName];
	cell.nameLabel.text = trophy.name;
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

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	TrophyRoomPopupViewController *trophyRoomPopup = [[TrophyRoomPopupViewController alloc] init];
	trophyRoomPopup.trophy = self.trophies[indexPath.row];
	FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:trophyRoomPopup];
	[self presentViewController:popupViewController animated:YES completion:nil];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
