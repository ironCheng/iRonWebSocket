# iRonWebSocket
WebSocket for iOS, depend on SocketRocket

## 用法
1、要记得载入 SocketRocket <br>
2、用法很简单，参照viewController来就好<br><br>

## 其他
心跳包：
 每10秒或15秒执行一次定时器 。
 有两种方式实现心跳包：
 1、普通的发送一个指定的消息，通知服务器后台：当前连接是正常的。
 2、用[self.socket sendPing:nil]这个方法，ping一下服务器，这时候会自动收到服务器的pong通知(可以统计ping与pong的数量判断有没有掉线)。


## Usage
1、You must import SocketRocket<br>
2、And just use it refer to the viewController.h/m.

## Other
  Heartbeat:
  You can use NSTimer to make your own hearbeat per 10/15 seconds.
    There are two kinds of way to execute that：
    1、In the timer action,send some a special message,the server repeat the same message.
    2、Just use the method "[self.socket sendPing:nil]",the server will repeat a pong(you can count the ping and pong to make sure line up).
