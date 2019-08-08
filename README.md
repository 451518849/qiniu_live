# qiniu_live

封装了七牛的实时音频的功能.

### 封装的功能有

	1. 发布直播间
	2. 进入直播间
	3. 获取进入、退出直播间人的信息
	4. 关闭、打开扬声器
	5. 关闭、打开声音

### 安装方式
Add this to your package's pubspec.yaml file:

	dependencies:
		qiniu_live: ^0.0.1
		  
	flutter packages get
	
## Getting Started


#### 1、发布直播
    QiniuLive.publishAudio('url', "d8lk7l4ed", "test","", {
      "user_id": "4",
      "avatar_url":
          "http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100",
      "username": "jason1",
      "is_admin": true
    });
    
#### 2、控制扬声器
    QiniuLive.speakerOn(isSpeakerOn);


#### 3、控制扬声器
    QiniuLive.muteAudio(isMute);

#### 4、退出直播
    QiniuLive.unPublish();

#### 4、获取实时出入人数

    static const EventChannel eventChannel = const EventChannel('qiniu_live_users');

    eventChannel
        .receiveBroadcastStream("")
        .listen(_onEvent, onError: _onError);
        
    void _onEvent(Object event) {

    print("qiniu_live_users:$event");
    setState(() {

    });
    }