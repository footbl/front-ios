//
//  FTBModel.h
//  Footbl
//
//  Created by Leonardo Formaggio on 8/11/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FTBModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSDate *createdAt;
@property (nonatomic, copy, readonly) NSDate *updatedAt;

+ (NSValueTransformer *)dateJSONTransformer;
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
