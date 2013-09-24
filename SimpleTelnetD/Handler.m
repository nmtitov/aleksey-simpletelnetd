//
//  Handler.m
//  SimpleTelnetD
//
//  Created by Alexey on 17.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "Handler.h"
#import "FileReader.h"
#import "CommandRunner.h"

@interface Handler ()

@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, strong) FileReader *reader;
@property (nonatomic, strong) CommandRunner *runner;

@end


@implementation Handler

- (id)init
{
    self = [super init];
    if (self){
        self.reader = [[FileReader alloc] init];
        self.runner = [[CommandRunner alloc] init];
        self.commands = [self.reader commandsArray];
    }
    return self;
}

- (void)handleInput:(NSString *)input
             answer:(void (^)(NSString *answer))answerBlock
               quit:(void (^)(void))quitBlock;
{
    if (!input){
        NSString *errorString = @"Error occured while getting data\r\n";
        NSLog(@"Error converting received data into UTF-8 String");
        answerBlock(errorString);
    }
    if ([input isEqualToString:@"quit"]){
        quitBlock();
    }
    if ([input isEqualToString:@"sighup"]){
        self.commands = [self.reader commandsArray];
        answerBlock([self availableCommands]);
    }
    NSArray *commandWithParameters = [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result;
    if ([self.commands containsObject:commandWithParameters[0]]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:commandWithParameters[0]]){
            result = [self.runner executeCommand:commandWithParameters];
        } else {
            result = @"Directory or file doesn't exist\r\n";
        }
    } else{
        result = @"Command is not allowed\r\n";
    }
    answerBlock(result);
}

- (NSString *)availableCommands
{
    NSString *result = @"Available commands:\r\n";
    for (NSString * entry in self.commands){
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", entry]];
    }
    return result;
}

@end
