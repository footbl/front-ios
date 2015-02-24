//
//  FootblLabel.m
//  Footbl
//
//  Created by Fernando Saragoça on 7/30/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "FootblLabel.h"

#pragma mark FootblLabel

@implementation FootblLabel

#pragma mark - Getters/Setters

- (void)setText:(NSString *)text {
    [super setText:text];
    
    if ((self.firstLineFont || self.firstLineTextColor) && [text rangeOfString:@"\n"].location != NSNotFound) {
        NSMutableDictionary *textAttributes = [NSMutableDictionary new];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = self.textAlignment;
        if (self.lineHeightMultiple > 0) {
            paragraphStyle.lineHeightMultiple = self.lineHeightMultiple;
        }
        textAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
        
        if (self.firstLineFont) {
            textAttributes[NSFontAttributeName] = self.firstLineFont;
        } else {
            textAttributes[NSFontAttributeName] = self.font;
        }
        
        if (self.firstLineTextColor) {
            textAttributes[NSForegroundColorAttributeName] = self.firstLineTextColor;
        } else {
            textAttributes[NSForegroundColorAttributeName] = self.textColor;
        }
        
        NSString *firstLine = [[text componentsSeparatedByString:@"\n"].firstObject stringByAppendingString:@"\n"];
        NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:firstLine attributes:textAttributes]];
        
        NSString *secondLine = [text stringByReplacingOccurrencesOfString:firstLine withString:@"" options:0 range:NSMakeRange(0, firstLine.length)];
        textAttributes[NSFontAttributeName] = self.font;
        textAttributes[NSForegroundColorAttributeName] = self.textColor;
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:secondLine attributes:textAttributes]];
        
        if (self.numberOfLines == 1) {
            self.numberOfLines = 0;
        }
        self.attributedText = attributedString;
    }
}

@end
