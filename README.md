# qiniu_live

封装了七牛的实时音频的功能，用于一对多的音频直播。通过控制是否时管理员（admin）来控制有多少个主播能发布声音，非管理员用户都为观众，只能听不能说话。
可用于场景：FM电台、聊天室、讲座等。
### 封装的功能有

	1. 发布直播间
	2. 进入、离开直播间
	3. 获取进入、退出直播间人的信息
	4. 关闭、打开扬声器
	5. 关闭、打开声音

### 安装方式
Add this to your package's pubspec.yaml file:

	dependencies:
		qiniu_live: ^0.0.2
		  
	flutter packages get
	
## Getting Started


#### 1、发布直播（兼容测试）
    QiniuLive.publishAudio("appId", "roomName","token ", {
      "user_id": "4",
      "avatar_url":
          "http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100",
      "username": "jason1",
      "is_admin": true //true表示主播，false表示观众
    });
    这里兼容了七牛给的测试链接，如果为测试环境，token为“”，
    需要填写七牛给的appId,如果为线上使用则无需填写appId，直接填入token即可。
    
#### 2、控制扬声器开关（默认打开）
    QiniuLive.speakerOn();


#### 3、控制扬声器开关（默认打开）
    QiniuLive.muteAudio();

#### 4、退出直播间（用户）
    QiniuLive.leaveRoom();

#### 6、关闭直播（主播）
    QiniuLive.unPublish();
    
#### 7、获取实时出入人数
如果你想要实时监控进入房间和退出房间的情况，则可以实现以下通道。

    static const EventChannel eventChannel = const EventChannel('qiniu_live_users');

    eventChannel
        .receiveBroadcastStream("")
        .listen(_onEvent, onError: _onError);
        
    void _onEvent(Object event) {

    print("qiniu_live_users:$event");
    setState(() {

    });
    }