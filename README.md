# 小智AI IOS 客户端

>一个基于WebSocket的ios语音对话应用,支持实时语音交互和文字对话。
>基于Flutter框架开发的小智AI助手，提供实时语音交互和文字对话功能。


- 基本上修改自https://github.com/TOM88812/xiaozhi-android-client/
- 只留下了小智的功能，添加了OTA
- 效果和某宝小智机器人一样，只是换成了app版
- 改了一下原版里面语音通话/创建小智服务端后修改不生效的问题
- 可以连接多个
- 配置服务里面websockets和ota地址不填默认就是连小智的ai后台，只有第一次创建服务并开启对话的时候会发送ota信息，目前写死了会升级到1.8.2，删掉当前对话重新添加以后会主动更新一次ota
- 对话框中点击人物头像可以更换，对话框点击+可以更换对话背景
- 添加了一个快捷指令支持，会跳转到置顶的第一个对话，如果是iphone15以上的机型，可以绑定到action button

<img src="./Simulator Screenshot - iPhone 16 Pro - 2025-07-14 at 00.17.05.png" style="zoom:50%">
<img src="./Simulator Screenshot - iPhone 16 Pro - 2025-07-14 at 00.17.32.png" style="zoom:50%">
<img src="./IMG_3611.PNG" style="zoom:50%">
<img src="./IMG_3610.PNG" style="zoom:50%">


