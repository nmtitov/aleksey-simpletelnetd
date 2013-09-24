//
//  Handler.h
//  SimpleTelnetD
//
//  Created by Alexey on 17.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Handler : NSObject

- (void)handleInput:(NSString *)input
            answer:(void (^)(NSString *answer))answerBlock
            quit:(void (^)(void))quitBlock;

- (NSString *)availableCommands;

@end
