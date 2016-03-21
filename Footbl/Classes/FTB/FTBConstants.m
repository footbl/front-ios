//
//  FTBConstants.m
//  Footbl
//
//  Created by Leonardo Formaggio on 8/22/15.
//  Copyright (c) 2015 Footbl. All rights reserved.
//

#import "FTBConstants.h"

#if FTB_ENVIRONMENT_DEVELOPMENT
NSString *const FTBBaseURL			= @"https://footbl-staging.herokuapp.com";
//NSString *const FTBBaseURL			= @"http://localhost:8080";
NSString *const FTBSignatureKey		= @"-f-Z~Nyhq!3&oSP:Do@E(/pj>K)Tza%})Qh= pxJ{o9j)F2.*$+#n}XJ(iSKQnXf";
#elif FTB_ENVIRONMENT_PRODUCTION
NSString *const FTBBaseURL			= @"https://footbl-production.herokuapp.com";
NSString *const FTBSignatureKey		= @"~BYq)Ag-;$+r!hrw+b=Wx>MU#t0)*B,h+!#:+>Er|Gp#N)$=|tyU1%|c@yH]I2RR";
#endif

NSString * const kFTNotificationAPIOutdated = @"kFootblAPINotificationAPIOutdated";
NSString * const kFTNotificationAuthenticationChanged = @"kFootblAPINotificationAuthenticationChanged";
NSString * const kFTErrorDomain = @"FootblAPIErrorDomain";

NSString *FTBISOCountryCodeForCountry(NSString *aCountry) {
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    
    for (NSString *countryCode in countryCodes) {
        NSDictionary *components = @{NSLocaleCountryCode: countryCode};
        NSString *identifier = [NSLocale localeIdentifierFromComponents:components];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSString *country = [locale displayNameForKey:NSLocaleIdentifier value:identifier];
        if ([country isEqualToString:aCountry]) {
            return countryCode;
        }
    }
    
    return nil;
}
