//
//  main.m
//  telnetServ
//
//  Created by Alexey on 16.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

void SignalHandler(int sig) {
    
}


int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        Server *srv = [Server sharedServer];
        [srv start];
        struct sigaction newSignalAction;
        memset(&newSignalAction, 0, sizeof(newSignalAction));
        newSignalAction.sa_handler = &SignalHandler;
        sigaction(SIGHUP, &newSignalAction, NULL);
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}


