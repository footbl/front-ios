//
//  Team.m
//  Footbl
//
//  Created by Fernando Saragoça on 3/26/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "Team.h"

@interface Team ()

@end

#pragma mark Team

@implementation Team

#pragma mark - Class Methods

#pragma mark - Instance Methods

- (NSString *)displayName {
    if (self.acronym && self.acronym.length > 0) {
        NSString *string = [NSString stringWithFormat:@"Team: %@", self.acronym];
        if ([NSLocalizedString(string, @"") isEqualToString:string]) {
            return self.acronym;
        }
        return NSLocalizedString(string, @"");
    }
    
    NSString *string = [NSString stringWithFormat:@"Team: %@", self.name];
    if ([NSLocalizedString(string, @"") isEqualToString:string]) {
        return self.name;
    }
    return NSLocalizedString(string, @"");
}

- (NSURL *)pictureURL {
    NSString *absoluteString = self.picture;
    absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    if ([absoluteString rangeOfString:@"res.cloudinary.com"].location != NSNotFound && [absoluteString rangeOfString:@"image/upload/"].location != NSNotFound && [absoluteString componentsSeparatedByString:@"/"].count == 6) {
        NSString *stringToReplace = [[absoluteString componentsSeparatedByString:@"/"] objectAtIndex:4];
        absoluteString = [absoluteString stringByReplacingOccurrencesOfString:stringToReplace withString:@"w_192,h_192,c_fit"];
    }
    absoluteString = [NSString stringWithFormat:@"http://%@?@2x.png", absoluteString];
    
    return [NSURL URLWithString:absoluteString];
}

- (void)updateWithData:(NSDictionary *)data {
    [super updateWithData:data];
}

@end
