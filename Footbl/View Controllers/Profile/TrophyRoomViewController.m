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

@interface TrophyRoomViewController ()

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
	cell.iconImageView.image = nil;
	cell.nameLabel.text = nil;
	cell.progressView.progress = 0.5;
	cell.progressView.hidden = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	TrophyRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	TrophyRoomPopupViewController *trophyRoomPopup = [[TrophyRoomPopupViewController alloc] init];
	FootblPopupViewController *popupViewController = [[FootblPopupViewController alloc] initWithRootViewController:trophyRoomPopup];
	[self presentViewController:popupViewController animated:YES completion:nil];
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
