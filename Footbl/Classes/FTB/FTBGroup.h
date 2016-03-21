//
//  FTBGroup.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBModel.h"

typedef NS_ENUM(NSUInteger, FTBGroupType) {
    FTBGroupTypeWorld,
    FTBGroupTypeCountry,
    FTBGroupTypeFriends
};

@interface FTBGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) FTBGroupType type;
@property (nonatomic, copy) NSNumber *unreadMessagesCount;

- (NSString *)sharingText;
- (UIImage *)iconImage;

@end
