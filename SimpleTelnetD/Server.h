//
//  Server.h
//  telnetServ
//
//  Created by Alexey on 16.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>


uint16_t const kPort;

@interface Server : NSObject<AsyncSocketDelegate>

- (void)stop;
- (void)start;
@end

