//
//  FileReader.m
//  SimpleTelnetD
//
//  Created by Alexey on 22.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "FileReader.h"

NSString *kConfFile = @"/etc/simple-telnetd.conf";


@interface FileReader ()

@property (nonatomic, strong) NSFileManager *fileManager;

- (void)checkForConfFile;

@end


@implementation FileReader


- (void)checkForConfFile
{
    self.fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![self.fileManager fileExistsAtPath:kConfFile]){
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"simple-telnetd.conf"];
        NSString *destPath = [NSHomeDirectory() stringByAppendingPathComponent:@"simple-telnetd.conf"];
        [self.fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
    }

}

- (NSArray*)commandsArray
{
    NSError *error = nil;
    NSString *fileData = [NSString stringWithContentsOfFile:kConfFile encoding:NSUTF8StringEncoding error:&error];
    NSArray *result = [fileData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *mutableCopy = [result mutableCopy];
    if ([[mutableCopy lastObject] isEqualToString:@""]){
        [mutableCopy removeLastObject];
    }
    result = [NSArray arrayWithArray:mutableCopy];
    return result;
}

- (NSString *)availableCommands
{
    NSArray *commands = [self commandsArray];
    NSString *result = @"Available commands:\r\n";
    for (NSString *entry in commands) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", entry]];
    }
    return result;
}

@end
