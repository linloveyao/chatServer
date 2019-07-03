//
//  MyServer.m
//  socket
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import "MyServer.h"
#import "GCDAsyncSocket.h"
@interface MyServer()<GCDAsyncSocketDelegate>
@property (nonatomic,strong)GCDAsyncSocket *serverSocket;
@property (nonatomic,strong)NSMutableArray *clientArray;

@end

static NSInteger serverPort = 8888;

@implementation MyServer
/* 注释:懒加载 */
-(NSMutableArray *)clientArray{
    if (_clientArray==nil) {
        _clientArray=[NSMutableArray array];
    }
    return _clientArray;
}

-(void)start{
    //开启服务器  端口号为5288(端口号是表示应用程序的逻辑地址，每个应用程序会有一个唯一的端口号，范围是0~65559，其中0~1024被系统占用，开发当中建议使用1024以上的端口)
    //创建一个scoket对象
    dispatch_queue_t queue=dispatch_get_global_queue(0, 0);
    GCDAsyncSocket *serverSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:(queue)];
    //绑定服务器的端口，并开始监听，此时服务器已经开启
    NSError *error=nil;
    [serverSocket acceptOnPort:serverPort error:&error];
    if (!error) {
        NSLog(@"服务器开启成功");
    }
    else{
        //失败的原因是端口号被其他程序占用
        NSLog(@"服务器开启失败---%@",error);
    }
    //为子线程创建一个NSRunLoop  否则服务器一被创建就会被关闭
    [[NSRunLoop mainRunLoop]run];
    self.serverSocket=serverSocket;
}

#pragma mark ----------------当有客户端的socket连接到服务器---------------
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    [self.clientArray addObject:newSocket];
    //监听客户端有没有上传-1表示不超时  0表示客户端的标识符
    [newSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"%@已连接，其IP地址:%@，端口号:%d",newSocket,newSocket.connectedHost,newSocket.connectedPort);
    NSLog(@"当前共有%ld客户连接服务器",self.clientArray.count);
    
    
    //如果想要在客户端一连上就返回一条消息在这里写
    NSString *answer=[NSString stringWithFormat:@"欢迎来到人工服务:\n输入数字1：普通服务\n输入数字2：特殊服务\n输入数字3：退出服务\n"];
    NSData *answerData=[answer dataUsingEncoding:NSUTF8StringEncoding];
    //处理请求返回数据给客户端
    [newSocket writeData:answerData withTimeout:-1 tag:0];
}

#pragma mark ----------------当有客户端的socket断开连接---------------
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%@断开连接，其IP地址:%@，端口号:%d",sock,sock.connectedHost,sock.connectedPort);
    //将其从数组中移除
    [self.clientArray removeObject:sock];
}

#pragma mark ----------------当接收到有客户端发来消息---------------
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receive=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData *answerData=[receive dataUsingEncoding:NSUTF8StringEncoding];
    //把当前客户端发送的数据转发给其他客户端
    for (GCDAsyncSocket *socket in self.clientArray) {
        if (socket!=sock) {
            [socket writeData:answerData withTimeout:-1 tag:0];
        }
    }
    #warning  每次读完数据后都要调用一次监听数据的方法
    [sock readDataWithTimeout:-1 tag:0];
    
    //给客户端写一个退出登录的选项只需将该客户端从数组中移除即可
     if ([receive isEqualToString:@"quit"]) {
        //移除客户端
        [self.clientArray removeObject:sock];
    }
}

//发送消息到客户端
- (void)senMessageToAllClient:(NSString *)message{
    NSData *answerData=[message dataUsingEncoding:NSUTF8StringEncoding];
    //处理请求返回数据给客户端
    for (GCDAsyncSocket *socket in self.clientArray) {
        [socket writeData:answerData withTimeout:-1 tag:0];
    }
}

@end
