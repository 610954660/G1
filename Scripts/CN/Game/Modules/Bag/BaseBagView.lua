--多页窗口其中一页测试页面
local BaseBagView = class("BaseBagView", View)

function BaseBagView:ctor()
	-- self._title = "背包"
	self._packName = "Bag"
    self._compName = "BaseBagView"
end

--重写方法 初始化UI
function BaseBagView:_initUI( ... )
	print(1,"baseBagView _initUI 初始化UI")
end

--事件初始化
function BaseBagView:_initEvent( ... )
	print(1,"BaseBagView _initEvent")
end

--initEvent前执行
function BaseBagView:_enter( ... )
	print(1,"BaseBagView _enter")
	-- body
end

--页面退出时执行
function BaseBagView:_exit( ... )
	print(1,"BaseBagView _exit")
end


return BaseBagView