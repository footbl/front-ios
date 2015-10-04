//
//  FTBPool.m
//  Footbl
//
//  Created by Leonardo Formaggio on 10/3/15.
//  Copyright © 2015 Footbl. All rights reserved.
//

#import "FTBPool.h"
#import "FTBModel.h"

@interface FTBPool ()

@property (nonatomic, strong) NSMutableSet *container;

@end

@implementation FTBPool

+ (instancetype)pool {
	static FTBPool *pool;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		pool = [[FTBPool alloc] init];
	});
	return pool;
}

- (NSMutableSet *)container {
	if (!_container) {
		_container = [[NSMutableSet alloc] init];
	}
	return _container;
}

- (FTBModel *)modelOfClass:(Class)modelClass withIdentifier:(NSString *)identifier {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
	FTBModel *model = [[self.container filteredSetUsingPredicate:predicate] anyObject];
	if (!model) {
		model = [[modelClass alloc] init];
		model.identifier = identifier;
		[self.container addObject:model];
	}
	return model;
}

- (NSArray *)modelsOfClass:(Class)modelClass withIdentifiers:(NSArray *)identifiers {
	NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:identifiers.count];
	for (NSString *identifier in identifiers) {
		FTBModel *model = [self modelOfClass:modelClass withIdentifier:identifier];
		[models addObject:model];
	}
	return models;
}

- (void)removeModel:(FTBModel *)model {
	[self.container removeObject:model];
}

- (void)drain {
	[self.container removeAllObjects];
}

@end
