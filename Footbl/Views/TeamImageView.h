//
//  TeamImageView.h
//  Footbl
//
//  Created by Fernando Saragoça on 4/28/14.
//  Copyright (c) 2014 Footbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamImageView : UIImageView

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, strong) NSOperation *operation;

@end
