//
//  Server.h
//  SimpleTelnetD
//
//  Created by Alexey on 16.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>


@interface Server : NSObject<AsyncSocketDelegate>

- (void)stop;
- (void)start;
+ (id)sharedServer;
- (void)refreshCommands;
@end

