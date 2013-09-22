//
//  Server.m
//  telnetServ
//
//  Created by Alexey on 16.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import "Server.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "Handler.h"
#import "FileReader.h"

int const kAnswer = 0;
int const kError = 1;

float const kReadTimeOut = 15.0;
float const kExtraTimeOut = 10.0;

uint16_t const kPort = 8080;

@interface Server ()

@property (nonatomic, strong) GCDAsyncSocket *listenSocket;
@property (nonatomic, strong) NSMutableArray *clients;
@property (nonatomic, strong) Handler *handler;
@property (nonatomic, strong) FileReader *reader;

@end

@implementation Server

static Server *sharedInstance = nil;

+(id)sharedServer
{
    if (sharedInstance){
        return sharedInstance;
    }
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[Server alloc] init];
    });
    return sharedInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.clients = [[NSMutableArray alloc] init];
        self.handler = [[Handler alloc] init];
        self.reader = [[FileReader alloc] init];
    }
    return self;
}

- (void)start
{
    self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:kPort error:&error])
        {
        @throw [NSException exceptionWithName:@"Socket error"
                                       reason:@"Could not create listening socket"
                                     userInfo:@{@"Error": error}];
        }
}

- (void)stop
{
    [self.listenSocket disconnect];
    
    @synchronized(self.clients){
        for (int i=0; i < self.clients.count; i++){
            [self.clients[i] disconnect];
        }
    }
    NSLog(@"Server stopped: %@", self);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //Accepting new socket
    
    [self.clients addObject:newSocket];
    
    NSData *welcome = [@"Welcome\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	
    [newSocket writeData:welcome withTimeout:-1 tag:kAnswer];
    
    NSData *availableCommands = [[self.reader availableCommands] dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:availableCommands withTimeout:-1 tag:kAnswer];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:kAnswer];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//Handling received data
    dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
			NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
			NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@", msg);
            if (!msg){
                NSLog(@"Error converting received data into UTF-8 String");
                NSString *errorString = @"Error occured while getting data\r\n";
                NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:errorData withTimeout:-1 tag:kAnswer];
                return;
            }
            
            if ([msg isEqualToString:@"quit"]){
                [self stop];
                return;
            }
            
            if ([msg isEqualToString:@"sighup"]){
                NSData *answerData = [[self.reader availableCommands] dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:answerData withTimeout:-1 tag:kAnswer];
                return;
            }
            
            [self.handler handleInput:msg success:^(NSString *goodNews) {
                NSData *strData = [goodNews dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:strData withTimeout:-1 tag:kAnswer];
            } failure:^(NSString *badNews) {
                NSData *strData = [badNews dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:strData withTimeout:-1 tag:kAnswer];
            }];
            
		}
	});
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    //Waitng for an answer longer than the timeout
    if (elapsed <= kReadTimeOut){
		NSString *warningMsg = @"Are you still there?\r\n";
		NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
		
		[sock writeData:warningData withTimeout:-1 tag:kError];
		
		return kExtraTimeOut;
    }
	return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != self.listenSocket){
		dispatch_async(dispatch_get_main_queue(), ^{
			@autoreleasepool {
				NSLog(@"Client Disconnected");
			}
		});
		@synchronized(self.clients){
			[self.clients removeObject:sock];
        }
    }
}

@end