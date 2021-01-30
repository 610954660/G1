

local LoadingController = {}



function LoadingController:ctor()

	
end

function LoadingController:init()
	LuaLogE("LoadingController init")
	Dispatcher.addEventListener(EventType.loading_begin,self)
	Dispatcher.addEventListener(EventType.loading_end,self)
	Dispatcher.addEventListener(EventType.loading_closeLoading,self)
	Dispatcher.addEventListener(EventType.login_sdkInit_success,self)
	self.loadEndCall = false
	self.LoadingView = false
	
	self.end1 = false
	self.end2 = false
end


function LoadingController:runScene()
	LuaLogE("LoadingController runScene")

	if __IGNORE_UPDATE__ then
		self:loading_end()
	else
		local LoadingView = require "Game.Modules.Loading.LoadingView"
		self.LoadingView = LoadingView.new()
	end
end


---监听事件
function LoadingController:loading_begin(name,func)
	print(15,"loading_begin",name, func)
	self.loadEndCall = func
	self:runScene();
	
end

function LoadingController:loading_end(num)
	LuaLogE("loading_end")
	if num == 1 then
		self.end1 = true 
	elseif num == 2 then
		self.end2 = true
	end
	
	if self.end1 and self.end2 and self.loadEndCall then
		LuaLogE("loadEndCall")
		self.loadEndCall()
		self.loadEndCall = false
		self.end1 = false
		self.end2 = false
	end
	
end

--sdk初始化完成，如果已经更新完毕的，就直接登陆
function LoadingController:login_sdkInit_success(e, sdkRes)
	if __SDK_LOGIN__  then
		if LoginModel:getUserName() == ""  and FlowManager.canLogin then
			SDKUtil.login()
		end
	end
end

--关闭loading
function LoadingController:loading_closeLoading()
	LuaLogE("loading_closeLoading")
	self.LoadingView:clear()
	
end

--检查是否需要更新
function LoadingController:checkIsNeedUpdate(func)
		
	local function onSuccess(data)
		--判断最新资源MD5跟本地资源MD5
		if data.md5 ~= ResUpdateManager.getLocalServerListMD5() then
			if func then
				func(true)
			end
		else
			if func then
				func(false)
			end
		end
	end
	
	local function onFailed(data)
		if func then
			func(false)
		end
	end
	LuaLogE("checkIsNeedUpdate")
	PHPUtil.getVersion(onSuccess, onFailed)	
end

return LoadingController