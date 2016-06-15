//
//  UserImageView.h
//  Footbl
//
//  Created by Leonardo Formaggio on 6/14/16.
//  Copyright © 2016 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FTBUser.h"

@interface UserImageView : UIImageView

@property (nonatomic, strong) FTBUser *user;
@property (nonatomic, getter=isRingVisible) BOOL ringVisible;

@end
