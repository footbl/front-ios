//
//  FTBModel.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FTBModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;

+ (NSValueTransformer *)dateJSONTransformer;
+ (instancetype)modelWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
