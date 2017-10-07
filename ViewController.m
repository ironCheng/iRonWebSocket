//
//  ViewController.m
//  iRonSocket
//
//  Created by iRonCheng on 2017/9/4.
//  Copyright © 2017年 iRonCheng. All rights reserved.
//

#import "ViewController.h"
#import "iRonWebSocketUtility.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSString *idSting;
@property (nonatomic, strong) NSString *nameString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //打开soket
    [[iRonWebSocketUtility instance] iRonWebSocketOpen];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iRonWebSocketDidOpen) name:@"kWebSocketDidOpenNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iRonWebSocketDidReceiveMsg:) name:@"kWebSocketdidReceiveMessageNote" object:nil];
    
//    [[iRonWebSocketUtility instance] iRonWebSocketClose]; 在需要得地方 关闭socket
//    [[iRonWebSocketUtility instance] iRonSendData:data];  发送数据
    
}

#pragma mark - Notification

/* 开启成功 */
- (void)iRonWebSocketDidOpen {
    NSLog(@"sorket开启成功");
}

/* 接收到消息 */
- (void)iRonWebSocketDidReceiveMsg:(NSNotification *)note {
    
    NSString * message = note.object;
    
    NSLog(@"%@",message);
    
}

@end
