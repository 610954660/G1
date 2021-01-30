--这里充当Ctor构造函数
local GLoaderFuncs = fgui.GLoader
local DragDropManager=fgui.DragDropManager

local filePath = false

require("Game.Managers.DragDropManager")
local function GLoaderCtor(gLoaderObj)
	if gLoaderObj.dragEnd then
		return gLoaderObj--表示初始化過了
	end
	gLoaderObj.dragEnd=false
	gLoaderObj.dragDropManager=DragDropManager:getInstance()--GLoader替身拖拽管理类
	--gLoaderObj.dragAgent=gLoaderObj.dragDropManager:getAgent()
	return gLoaderObj
end

-- 替身拖动注册开始
function GLoaderFuncs:toAgentDrag(context,userData,func)
	--取消掉源拖动
	context:preventDefault();
	--icon是这个对象的替身图片url，userData可以是任意数据，底层不作解析。context.data是手指的id。
	self.dragDropManager:startDrag(self, userData, context:getInput():getTouchId());
	--gLoaderObj.dragAgent():displayObject():addChild(self.skeletonNode)
	--self.dragAgent:setFill(2)--纹理填充方式：适应高度
	dragDropManager():addSingelEvent(FUIEventType.DragEnd,func)
end

--替身拖动事件必须先注册cloneDragSrart
function GLoaderFuncs:cloneDragMove(func)
	--getAgent就是拿到的Gloader替身对象
	dragDropManager():addSingelEvent(FUIEventType.DragMove,func)
end

-- 组件本身被拖动的功能
function GLoaderFuncs:DragStart(func)
	self:setDraggable(true)
	self:addEventListener(FUIEventType.DragStart,func);
end
-- 组件本身被拖动的功能
function GLoaderFuncs:DragMove(func)
	self:addEventListener(FUIEventType.DragMove,func);
end
-- 组件本身被拖动结束的功能
function GLoaderFuncs:DragEnd(func)
	self:addEventListener(FUIEventType.DragEnd,func);
end
---- 组件被拖放的功能
--function GLoaderFuncs:onDrop(func)
	--self:addEventListener(FUIEventType.Drop,func);
--end
function GLoaderFuncs:setItemUrl(package, component)
    local url = UIPackageManager.getUIURL(package, component)
    self:setURL(url)
end

function GLoaderFuncs:setPrecent(value)
    self:setFillAmount(value)
end

function GLoaderFuncs:setUrlByPackege(packageName,resName)
     self:setURL(UIPackageManager.getUIURL(packageName,resName))
end

--使用网络图片
function GLoaderFuncs:setNetWorkUrl(url,func)
	
	if not filePath then
		filePath = cc.FileUtils:getInstance():getWritablePath().."dimage/"
	end
	
	local fileName = gy.GYStringUtil:getStringMD5(url)
	local fullPath = filePath..fileName
	if cc.FileUtils:getInstance():isFileExist(fullPath) then
		self:setURL(fullPath)
		return
	end
	if url == self.netWorkUrl then return end
	self.netWorkUrl = url
	HttpUtil.downLoadFile({
			url = url,
			onFinish = function (data)
				if data.code == 200 then
					LuaLogE("downLoadFile success "..fullPath)
					if func then
						func(url,fullPath)
					end
					if not tolua.isnull(self) then
						if self.netWorkUrl == url then
							self:setURL(fullPath)
						end
					end
				else
					self.netWorkUrl = ""
				end
			end,
			onProgress = function ()
				end,
			fileName = fileName,
			filePath =  filePath,
		})
	

	--LuaLogE("setNetWorkUrl ")
end

----isSync: 是否同步加载。默认是异步，值为nil，只有同步时才会设置为true。
--function GLoaderFuncs:setUrl(url)
    --self:setURL(url)
--end
--function GLoaderFuncs:getUrl()
    --return self:getURL()
--end
return GLoaderCtor
