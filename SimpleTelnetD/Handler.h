//
//  Handler.h
//  telnetServ
//
//  Created by Alexey on 17.09.13.
//  Copyright (c) 2013 Aleksey. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString const *confFile;

@interface Handler : NSObject

- (void)handleInput:(NSString *)input
            success:(void (^)(NSString *goodNews))successBlock
            failure:(void (^)(NSString *badNews))failureBlock;

@end
