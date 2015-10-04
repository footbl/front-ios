//
//  FTBPool.h
//  Footbl
//
//  Created by Leonardo Formaggio on 10/3/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTBModel;

@interface FTBPool : NSObject

+ (instancetype)pool;
- (FTBModel *)modelOfClass:(Class)modelClass withIdentifier:(NSString *)identifier;
- (NSArray *)modelsOfClass:(Class)modelClass withIdentifiers:(NSArray *)identifiers;
- (void)removeModel:(FTBModel *)model;
- (void)drain;

@end
