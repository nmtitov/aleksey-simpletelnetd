//
//  main.m
//  telnetServ
//
//  Created by Alexey on 16.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        Server *srv = [Server sharedServer];
        [srv start];
        NSLog(@"Starting server");
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

