//
//  FileReader.m
//  SimpleTelnetD
//
//  Created by Alexey on 22.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "FileReader.h"

NSString * const kConfFile = @"/etc/simple-telnetd.conf";


@interface FileReader ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *confPath;

- (void)checkForConfFile;

@end


@implementation FileReader


- (id)init
{
    self = [super init];
    if (self){
    }
    return self;
}

- (void)checkForConfFile
{
    self.fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![self.fileManager fileExistsAtPath:kConfFile]){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"simple-telnetd" ofType:@"conf"];
        self.confPath= [NSHomeDirectory() stringByAppendingPathComponent:@"simple-telnetd.conf"];
        [self.fileManager copyItemAtPath:sourcePath toPath:self.confPath error:&error];
    } else {
        self.confPath = kConfFile;
    }
}

- (NSArray*)commandsArray
{
    [self checkForConfFile];
    NSString *fileData = [NSString stringWithContentsOfFile:self.confPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *result = [fileData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *mutableCopy = [result mutableCopy];
    if ([[mutableCopy lastObject] isEqualToString:@""]){
        [mutableCopy removeLastObject];
    }
    result = [NSArray arrayWithArray:mutableCopy];
    return result;
}

@end
