//
//  CommandRunner.h
//  SimpleTelnetD
//
//  Created by Alexey on 22.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandRunner : NSObject

- (NSString*)executeCommand:(NSArray*)command;

@end
