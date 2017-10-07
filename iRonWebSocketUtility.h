//
//  iRonWebSocketUtility.h
//  iRonSocket
//
//  Created by iRonCheng on 2017/9/4.
//  Copyright © 2017年 iRonCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>

@interface iRonWebSocketUtility : NSObject

/** 连接状态 */
@property (nonatomic,assign) SRReadyState socketReadyState;

+ (iRonWebSocketUtility *)instance;

- (void)iRonWebSocketOpen;      //开启连接
- (void)iRonWebSocketClose;     //关闭连接
- (void)iRonSendData:(id)data;  //发送数据


@end
