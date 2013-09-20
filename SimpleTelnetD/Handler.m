//
//  Handler.m
//  telnetServ
//
//  Created by Alexey on 17.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "Handler.h"

NSString *confFile = @"/etc/simple-telnetd.conf";

@interface Handler ()

@property NSArray *commands;
@property NSArray *commandWithParameters;
@property NSFileManager *fileManager;

@end

@implementation Handler

- (id)init
{
    self = [super init];
    if (self){
        [self getTheListOfCommands];
    }
    return self;
}

- (void)handleInput:(NSString *)input
            success:(void (^)(NSString *goodNews))successBlock
            failure:(void (^)(NSString *badNews))failureBlock
{
    self.commandWithParameters = [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    BOOL isAValidCommand = NO;
    
    for (NSString *entry in _commands){
        if ([self.commandWithParameters[0] isEqualToString:entry]){
            isAValidCommand = YES;
        }
    }
    self.fileManager = [NSFileManager defaultManager];
    if (isAValidCommand){
        if ([self.fileManager fileExistsAtPath:self.commandWithParameters[0]]){
            NSString *result = [self executeCommand];
            successBlock(result);
        } else {
            failureBlock(@"Directory or file doesn't exist\r\n");
        }
    } else{
        failureBlock(@"Command is not allowed\r\n");
    }
}

- (NSString *)executeCommand
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:_commandWithParameters[0]];
    
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    if (self.commandWithParameters.count > 1){
        for (int i = 1; i < self.commandWithParameters.count; i++){
            [parameters addObject:self.commandWithParameters[i]];
        }
    }
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

- (NSString *)getTheListOfCommands
{
    self.fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![self.fileManager fileExistsAtPath:confFile]){
        NSString *newFileData = @"/bin/ls\r\n/bin/cd";
        [newFileData writeToFile:confFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    NSString *fileData = [NSString stringWithContentsOfFile:confFile encoding:NSUTF8StringEncoding error:&error];
    self.commands = [fileData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *mutableCommands = [self.commands mutableCopy];
    if ([[mutableCommands lastObject] isEqualToString:@""]){
        [mutableCommands removeLastObject];
    }
    self.commands = [NSArray arrayWithArray:mutableCommands];
    NSLog(@"%@", self.commands);
    NSString *result = @"Available commands:\r\n";
    for (NSString *entry in self.commands) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", entry]];
    }
    return result;
}

@end
