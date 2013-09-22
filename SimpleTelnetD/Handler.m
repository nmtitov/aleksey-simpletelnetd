//
//  Handler.m
//  telnetServ
//
//  Created by Alexey on 17.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "Handler.h"
#import "FileReader.h"
#import "CommandRunner.h"

NSString *confFile = @"/etc/simple-telnetd.conf";

@interface Handler ()

@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, strong) NSFileManager *fileManager;
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
            success:(void (^)(NSString *goodNews))successBlock
            failure:(void (^)(NSString *badNews))failureBlock
{
    NSArray *commandWithParameters = [input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.fileManager = [NSFileManager defaultManager];
    if ([self.commands containsObject:commandWithParameters[0]]){
        if ([self.fileManager fileExistsAtPath:commandWithParameters[0]]){
            NSString *result = [self.runner executeCommand:commandWithParameters];
            successBlock(result);
        } else {
            failureBlock(@"Directory or file doesn't exist\r\n");
        }
    } else{
        failureBlock(@"Command is not allowed\r\n");
    }
}

@end
