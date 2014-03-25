//
//  SPLog.h
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

typedef NS_ENUM(NSInteger, SPDebugLogLevel) {
    SPDebugLogLevelNothing,
    SPDebugLogLevelError,
    SPDebugLogLevelInfo,
    SPDebugLogLevelVerbose
};
extern SPDebugLogLevel kSPDebugLogLevel; // defaults to SPLogLevelError

#define SPLog(x, ...) if(kSPDebugLogLevel >= SPDebugLogLevelInfo) NSLog(@"%@: " x, SPGenerateLogString(__FILE__, __LINE__, __FUNCTION__), ##__VA_ARGS__)
#define SPLogError(x, ...) if(kSPDebugLogLevel >= SPDebugLogLevelError) NSLog(@"Error: %@ " x, SPGenerateLogString(__FILE__, __LINE__, __FUNCTION__), ##__VA_ARGS__)
#define SPLogVerbose(x, ...) if(kSPDebugLogLevel >= SPDebugLogLevelVerbose) NSLog(@"%@: " x, SPGenerateLogString(__FILE__, __LINE__, __FUNCTION__), ##__VA_ARGS__)

extern NSString * SPGenerateLogString(const char *file, int lineNumber, const char *functionName);