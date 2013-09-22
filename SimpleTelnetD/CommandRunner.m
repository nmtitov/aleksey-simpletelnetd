//
//  CommandRunner.m
//  SimpleTelnetD
//
//  Created by Alexey on 22.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "CommandRunner.h"

@interface CommandRunner ()

- (NSArray*)parametersFromCommand:(NSArray*)command;

@end

@implementation CommandRunner

- (NSString*)executeCommand:(NSArray*)command
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command[0]];
    
    NSArray *parameters = [self parametersFromCommand:command];
    
    if (parameters.count > 0){
        [task setArguments:parameters];
    }
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSArray*)parametersFromCommand:(NSArray*)command
{
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    if (command.count > 1){
        for (int i = 1; i < command.count; i++){
            [mutable addObject:command[i]];
        }
    }
    NSArray *result = [NSArray arrayWithArray:mutable];
    return result;
}

@end
