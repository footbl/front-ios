//
//  FTBTeam.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/12/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBTeam.h"

@implementation FTBTeam

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSDictionary *keyPaths = @{@"name": @"name",
							   @"pictureURL": @"picture"};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}

+ (NSValueTransformer *)pictureURLJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        NSURL *URL = [self.pictureURL URLByDeletingLastPathComponent];
        if ([URL.lastPathComponent hasPrefix:@"v"]) {
            URL = [URL URLByDeletingLastPathComponent];
        }
        URL = [URL URLByAppendingPathComponent:@"e_grayscale"];
        URL = [URL URLByAppendingPathComponent:self.pictureURL.lastPathComponent];
        self.grayscalePictureURL = URL;
    }
    return self;
}

@end
