--aded by wyang  BindView
--使用FGUI创建的显示基类，用于各类UI界面创建
local BindView = class("BindView")
function BindView:ctor( view,args )
    -- LuaLogE("BindView:ctor")
   self.view = view
	self.__isExited = false --是否隐藏了
	self.view:addEventListener(FUIEventType.Enter,function(context) self:__onEnter()  end);
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
    --层级节点
    self._parent = view:getParent()
	self._eventListeners = {}
	
	
end

--ctor 之后执行
function BindView:init(args)
	--LuaLogE("BindView:init")
	self:_initUI()
	self:_initEvent()
	self:_addRed()
	--[[if args and args.parent then
		self._parent = args.parent
		self._isChildBindView = true
	else
		self._parent = BindViewManager.getParentLayer(self._rootDepth)
	end--]]
	self:__addEventListner()
end


--在_toInit完成之后执行
function BindView:__onEnter()
    --print(1,"BindView __onEnter")
	self:_enter()
	if self.__isExited  then
		self.__isExited  = false
		self:__addEventListner()
		self:_refresh()
	end
end

--退出操作 在close执行之前 
function BindView:__onExit()
    -- print(1,"BindView __onExit")
	self:_exit() --执行子类重写
	self:__clearEventListeners()
	self.__isExited = true
end


function BindView:__addEventListner()
	local bindMap = self._eventListeners
	for funcName in pairs(getmetatable(self).__index) do
		if not bindMap[funcName] then
			bindMap[funcName]  = funcName
			local pos = string.find(funcName,"_")
			if pos and pos > 1 then
				if not __IS_RELEASE__ then
					--在不在两类事件枚举里面
				end
				Dispatcher.addEventListener(funcName,self)
			end
		end
	end	
end
-- 删除所有侦听的事件
function BindView:__clearEventListeners()
    for _, funcName in pairs(self._eventListeners) do
        --LuaLogE(self._BindViewName.."界面 BindView 中删除的事件监听 = "..funcName)
        Dispatcher.removeEventListener(funcName, self)
	end
	self._eventListeners = {};
end

---------------外部可调用接口-------------------------------

--设置隐藏状态
function BindView:setVisible(value)
    if self.view then
        self.view:setVisible(value)
    end
end

--获得隐藏状态
function BindView:getVisible()
    if self.BindView then
        return self.BindView:getVisible()
    end
    return false
end

function BindView:setVisible(v)
	if self.view then
		self.view:setVisible(v)
	end
end
function BindView:setPosition(x,y)
	if self.view then
		self.view:setPosition(x,y)
	end
end
function BindView:getWidth(x,y)
	if self.view then
		return self.view:getWidth()
	end
	return 0
end
function BindView:getHeight()
	if self.view then
		return self.view:getHeight()
	end
	return 0
end
function BindView:setAlpha(a)
	if self.view then
		return self.view:setAlpha(a)
	end
end


--获得父节点
function BindView:getParent()
    return self._parent
end

---------------外部可调用接口-------------------------------


----------------继承重写---------------------

-- [子类重写] 添加后执行 _initUI之前
function BindView:_enter()
end


-- [子类重写] 初始化UI方法 
function BindView:_initUI( ... )
	-- body
end

-- [子类重写] 准备事件 _initUI之后
function BindView:_initEvent( ... )
	-- body
end 
-- [子类重写] 准备事件 _initUI之后
function BindView:_addRed( ... )
    --body
end

-- [子类重写] 移除后执行 close之后
function BindView:_exit()
end

-- [子类重写] 移除后执行 在移除后再加回来
function BindView:_refresh()
	
end
----------------继承重写---------------------


return BindView
