简单说明一下：
	Dex是一个光娱在开发中的游戏整体解决方案，目前在cocos客户端这部分先实现简单的网络交互和协议内容。
	其中Libs目录下面收录了一些外部引用库。为了解决外部引用库在引入时候的


兼容多线程机器人。
	完成以后需要做这个事情，主要是吧network抽出来单独成为一个客户度底层供多线程机器人client用，这样的话就基本上不能有用到cocos的接口，这里可以考虑用纯lua逻辑来实现。详见老版本的服务端目录上的GameClient。
	