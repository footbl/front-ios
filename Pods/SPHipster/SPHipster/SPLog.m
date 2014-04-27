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

NSString * SPLogFilePath()  {
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Logs"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    return folder;
}

void SPLogSwitchToLocalFiles() {
    NSString *path = SPLogFilePath();
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH'h'mm'm'ss's'";
    path = [[path stringByAppendingPathComponent:[formatter stringFromDate:[NSDate date]]] stringByAppendingPathExtension:@"log"];
    [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    dup2([fileHandle fileDescriptor], STDERR_FILENO);
}

NSString * SPGenerateLogString(const char *file, int lineNumber, const char *functionName, SPDebugLogLevel logLevel) {
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    NSString *logType;
    switch (logLevel) {
        case SPDebugLogLevelVerbose:
            logType = @"VERBOSE";
            break;
        case SPDebugLogLevelError:
            logType = @"ERROR";
            break;
        default:
            logType = @"INFO";
            break;
    }
    return [NSString stringWithFormat:@"%@ (%s) (%@:%i)", logType, functionName, fileName, lineNumber];
}
