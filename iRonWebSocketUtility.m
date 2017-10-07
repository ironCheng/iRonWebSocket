//
//  iRonWebSocketUtility.m
//  iRonSocket
//
//  Created by iRonCheng on 2017/9/4.
//  Copyright © 2017年 iRonCheng. All rights reserved.
//

#import "iRonWebSocketUtility.h"

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface iRonWebSocketUtility () <SRWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
}

@property (nonatomic,strong) SRWebSocket *socket;

@end

@implementation iRonWebSocketUtility


+ (iRonWebSocketUtility *)instance
{
    static iRonWebSocketUtility *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[iRonWebSocketUtility alloc] init];
    });
    return Instance;
}

#pragma mark - Open Method

//开启连接
- (void)iRonWebSocketOpen
{
    //如果是同一个url return
    if (self.socket) {
        return;
    }
    
    //这里填写你服务器的地址
    self.socket = [[SRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.0.1"]]];
    //实现这个 SRWebSocketDelegate 协议
    self.socket.delegate = self;
    //open 就是直接连接了
    [self.socket open];
}

//关闭连接
- (void)iRonWebSocketClose
{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
//        [self destoryHeartBeat];
    }
}

//发送数据
- (void)iRonSendData:(id)data
{
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                [self reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                
                NSLog(@"重连");
                
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}


#pragma mark - Getter

- (SRReadyState)socketReadyState{
    return self.socket.readyState;
}


#pragma mark - SRWebSocket Delegate

/* 正常连接 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    
    //开启心跳
//    [self initHeartBeat];
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket 连接成功************************** ");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kWebSocketDidOpenNote" object:nil];
        
    }
}

/* 连接失败 */
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        //连接失败就重连
        [self reConnect];
    }
}

/* 关闭连接 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket连接断开************************** ");
        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        
        [self iRonWebSocketClose];
    }
    
}

/*该函数是接收服务器发送的pong消息
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
}

/* 接受到消息 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
//        NSLog(@"************************** socket收到数据了************************** ");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kWebSocketdidReceiveMessageNote" object:message];
    }
}


#pragma mark - Privated Method

//重连机制
- (void)reConnect
{
    [self iRonWebSocketClose];
    
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self iRonWebSocketOpen];
        NSLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (reConnectTime == 0) {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

//初始化心跳
- (void)initHeartBeat
{
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        heartBeat = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:heartBeat forMode:NSRunLoopCommonModes];
    })
}

- (void)sentheart{
    //发送心跳 和后台可以约定发送什么内容
    [self iRonSendData:@"heart"];
}

//取消心跳
- (void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (heartBeat) {
            if ([heartBeat respondsToSelector:@selector(isValid)]){
                if ([heartBeat isValid]){
                    [heartBeat invalidate];
                    heartBeat = nil;
                }
            }
        }
    })
}


//pingPong

/*
    这个心跳包其实就是一个ping消息，我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息
    直接在该函数里面统计一下收到的次数，跟发送的次数比较，如果每次发送之前，自己发送的ping消息的个数，跟收到pong消息的个数相同，那就代表一直在连接状态
 
 */
- (void)ping{
    if (self.socket.readyState == SR_OPEN) {
        /* 发送Ping过去 如果收到，服务端回返回pong */
        [self.socket sendPing:nil];
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
