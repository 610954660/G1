目前有这个打算让cocos 能在coroutine的环境下运作。
具体是这样的，必须在最外层做一个封装，以让回调有办法被调回。这个好处就是我们日后做分帧处理和定时动作会变得异常简单。