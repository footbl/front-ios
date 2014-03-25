//
//  SPLog.m
//  SPHipster
//
//  Created by Fernando Saragoça on 1/12/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import "SPLog.h"

#pragma mark SPLog

#pragma mark - Extern Functions

SPDebugLogLevel kSPDebugLogLevel = SPDebugLogLevelError;

NSString * SPGenerateLogString(const char *file, int lineNumber, const char *functionName) {
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    return [NSString stringWithFormat:@"(%s) (%@:%i)", functionName, fileName, lineNumber];
}
