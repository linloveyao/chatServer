//
//  MyServer.h
//  socket
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyServer : NSObject
-(void)start;

- (void)senMessageToAllClient:(NSString *)message;
@end
