--aded by xhd  View
--使用FGUI创建的显示基类，用于各类UI界面创建
local View = class("View")
function View:ctor( args )
    -- LuaLogE("View:ctor")
    args = args or {}
    -- view名字
    self._viewName = self.__cname
    -- view 对象
    self.view = false
    -- 参数
    self._args = args
    --层级节点
    self._parent = false
    --层级
    self._sortingOrder = 0
    --指定位置
    self._posX = false
    self._posY = false
    -- 事件
    self._eventListeners = {}
    --资源包
    self._packName = args._packName or ""
    -- 资源包中的组件
    self._compName = args._compName or ""
    --是否是子节点
    self._isChildView = true

    -- 是否全屏
    self._isFullScreen = true
    -- 是否异步
    self._isAsync = false

    -- 是否正在关闭中
    self._isClosing = false
	
	--创建完成回调
	self.donecb = false

    --根节点深度
    self._rootDepth = args._rootDepth or LayerDepth.Zero
    --在各自层级里面的层级计数
    self._layerNum = 0
	--多页面中 主窗口类句柄
	self._parentWin = false
	--模糊背景
	self._capSceneSprite = false
	--
	self._batttleView = false
end

--ctor 之后执行
function View:init(args)
	LuaLogE("View:init "..self._compName)
	if args and args.parent then
		self._parent = args.parent
		self._isChildView = true
	else
		self._parent = ViewManager.getParentLayer(self._rootDepth)
	end
	
end

--自动绑定事件
function View:_initAutoEvent()
	local bindMap = self:excludebindMapFun()
	for funcName in pairs(getmetatable(self).__index) do
		if not bindMap[funcName] then
			local pos = string.find(funcName,"_")
			if pos and pos > 1 then
				if not __IS_RELEASE__ then
					--在不在两类事件枚举里面
				end
				self:addEventListener(funcName,self)
			end
		end
	end
end


--镜头模糊
function View:_checkOpenBlur()
	
	if not self.view or tolua.isnull(self.view) then return end
	
	local gb = self.view:getChildAutoType("GaussianBlur")
	if gb then return true end

	local blackBg = self.view:getChildAutoType("blackBg")
	if not blackBg then
		blackBg = self.view:getChildAutoType("$blackBg")
	end
	if not blackBg then
		blackBg = self.view:getChildAutoType("blackbg")
	end
	if blackBg then
		blackBg:setAlpha(0)
		return true 
	end
	local closeButton = self.view:getChildAutoType("closeButton")
	if not closeButton then
		closeButton = self.view:getChildAutoType("$closeButton")
	end
	if not closeButton then
		closeButton = self.view:getChildAutoType("closeButton1")
	end
	if not closeButton then
		closeButton = self.view:getChildAutoType("closeBtn2")
	end
	if not closeButton then
		closeButton = self.view:getChildAutoType("closeBtn")
	end
	if closeButton and closeButton:getWidth() > 800 and closeButton:getHeight() > 600 then
		closeButton:setAlpha(0)
		return true
	end
	
	return false
end

--镜头模糊
function View:_setBlur(check,blurColor)
	
	--if true then return end
	if check and not self:_checkOpenBlur() then return end
	
	
	if self._capSceneSprite then return end
	if cc.SpriteCaptureFB.createCaptureNode then
		--本地环境先用新的截屏方案。
		print(15,"new captureNode")
		local node = cc.SpriteCaptureFB:createCaptureNode()
		node:setContentSize(display.width,display.height)
		local shaderKey = "guassian_blur"
		local glProgramCache = cc.GLProgramCache:getInstance()
		local glProgram  = glProgramCache:getGLProgram(shaderKey)
		if not glProgram then
			local vertex = require "Game.Shaders.GaussianBlurVert"
			local fragment = require "Game.Shaders.GaussianBlurFrag"
			glProgram = cc.GLProgram:createWithByteArrays(vertex , fragment)
			if not glProgram then return end
			glProgramCache:addGLProgram(glProgram, shaderKey)
		end
		local state = cc.GLProgramState:create(glProgram)
		state:setUniformVec2("unit_matrix", {x = 1/display.width,y = 1/display.height})
		state:setUniformFloat("blurRaius", 9)
		state:setUniformFloat("sampleNum", 4)
		node:setGLProgramState(state)
		local pos = self.view:globalToLocal(Vector2(display.width/2, display.height/2))
		local posZero = self.view:globalToLocal(Vector2(0, 0))
		self._capSceneSprite = node
		self._capSceneSprite:setPosition(pos)
		self._capSceneSprite:setCapturePreFrame(false)--这个方法锁帧。
		self.view:displayObject():addChild(self._capSceneSprite, -100)
		local BlurColor = blurColor or 77
		local layer = cc.LayerColor:create(cc.c4b(0,0,0,220-BlurColor),display.width,display.height);
		layer:setPosition(posZero)
		self.view:displayObject():addChild(layer,-99)
	else
		self.view:setVisible(false)
		local node = cc.utils:newCaptureScreenSprite()
		node:setAnchorPoint(0.5,0)
		local shaderKey = "guassian_blur"
		local glProgramCache = cc.GLProgramCache:getInstance()
		local glProgram  = glProgramCache:getGLProgram(shaderKey)
		if not glProgram then
			local vertex = require "Game.Shaders.GaussianBlurVert"
			local fragment = require "Game.Shaders.GaussianBlurFrag"

			glProgram = cc.GLProgram:createWithByteArrays(vertex , fragment)
			if not glProgram then return end
			glProgramCache:addGLProgram(glProgram, shaderKey)
		end
		local state = cc.GLProgramState:create(glProgram)
		state:setUniformVec2("unit_matrix", {x = 1/display.width,y = 1/display.height})
		state:setUniformFloat("blurRaius", 9)
		state:setUniformFloat("sampleNum", 4)
		node:setGLProgramState(state)
		local pos = self.view:globalToLocal(Vector2(display.width/2, display.height/2))
		--node:setPosition(pos)
		--display.getRunningScene():addChild(node,9999)
		
		self._capSceneSprite = DisplayUtil.captureNode(node)
		--self._capSceneSprite:
		self._capSceneSprite:setPosition(pos)
		
		local BlurColor = blurColor or 77
		
		self._capSceneSprite:setColor({r=BlurColor,g=BlurColor,b=BlurColor})
		self.view:setVisible(true)
		
		self.view:displayObject():addChild(self._capSceneSprite,-100)
		
	end
	
	--移除掉
	--node:removeFromParentAndCleanup(true)
	--node:setVisible(false)
end

--ViewManager 调用创建方法
function View:toCreate(donecb)
	-- LuaLogE("View:toCreate")
	self.donecb = donecb
	if self._parent then
        self:__readyPackage(function() 
				self:__doCreateObj() 
			end)
	else
        print("View toCreate _parent is nil")
    end
end

function View:__readyPackage(callfunc)

    --去创建包体界面回调
    if not self._packName then
        print(1,"包名为空 不可创建")
        return
    end
        
	local info = UIPackageManager.getPackageInfo(self._packName) --查看是否包还存在
	if not info then
		-- LuaLogE("没有包的任何信息，需要异步加载，然后再创建")
		UIPackageManager.addPackage(self._packName,callfunc)
		callfunc(false)
		-- UIPackageManager.addPackageAsync(self._packName, doCreateObj)
	else

		-- if not true then
		-- else
			-- 有包的所有信息，直接创建
			callfunc(true)
		-- end
	end
end


--组件已创建成功回调
function View:__onCreateObjSuccess( obj )
	local failed = false
	if obj == nil then
		LuaLogE(string.format("%s %s => package-not-found", self._package, self._compName), Desc.view_nopackage)
		failed = true
	end

	if self._isClosing then
		failed = true
	end

	if failed then --失敗 计算-1
		ViewManager.subCount(self._packName, self._compName)
		return
	end
	--添加onEnter/onExit 事件触发
	self.view:addEventListener(FUIEventType.Enter,function(context) self:__onEnter()  end);
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);


	self:addToParent()
	self:__toInit()

	if self.donecb then
		self:donecb(self)
	end


	Dispatcher.dispatchEvent(EventType.view_open,self)
end

--外部接口  移到最上层
function View:bringToFront( ... )

	local index = self._parent:numChildren() - 1
	
	print(33,"bringToFront ",index)
	if index > 0 then
		self._parent:setChildIndex(self.view,index)
	end
	ViewManager.freshShowView(self,false)
	
end

function View:__doCreateObj()
	
	if self._isClosing then --如果界面已关闭 return
		return
	end
	ViewManager.addCount(self._packName, self._compName)
	if self._isAsync then --是否需要异步
		UIPackageManager.createObjectAsync(self._packName, self._compName, function(obj)
				self.view = obj
				self:__onCreateObjSuccess(obj)
		end)
	else
		LuaLogE(DescAuto[39],self._packName,self._compName) -- [39]="从包中创建页面组件"
		self.view = UIPackageManager.createGComponent(self._packName,self._compName)
		self:__onCreateObjSuccess(self.view)
	end
end

--创建弹幕
function View:__initBarrage()
	local barrageConfig = DynamicConfigData.t_Barrage[self._compName]
	if barrageConfig then
		Scheduler.scheduleOnce(0.1,function()
			if tolua.isnull(self.view) then return end
			local ViewGroups = require "Game.UI.ViewGroups"
			local viewInfo = ViewGroups["BarrageView"]
			local cpmView = require(viewInfo.path).new()
			cpmView._parent = self.view
			cpmView._args = barrageConfig
			cpmView:toCreate()
		end)
	end
end

--异步的时候回调会调用
function View:__toInit()
    print(1,"View:__toInit")

	self:__fitToScreen()

    --常驻粒子特效动画
	if self._showParticle then
		local parent=self.view:getChildAt(0)
		if parent then
			 local MapWidth=fgui.GRoot:getInstance():getViewWidth()
			 local MapHeight=fgui.GRoot:getInstance():getViewHeight()
			 local centerPos=Vector2(MapWidth/2,MapHeight/2)
			 local spine=SpineUtil.residentSpine("Effect","efx_xuehua","efx_xuehua",self.view,centerPos)
			 local action=self._action or "xuehua_zhujiemian"
			 spine:setAnimation(0, action, true)
			--ParticleUtil.residentParticle("particle_View",parent)
		end
	end
	
	--Scheduler.scheduleNextFrame(function()
		--self:_setBlur()
	--end)
	

	CLASS_ALLOW_NEW_INDEX = true
	self:_initUI()

	CLASS_ALLOW_NEW_INDEX = false
	
	self:_initAutoEvent()
    self:_initEvent()
	self:_addRed()
	self:__initBarrage()
end

--播放背景音乐
function View:playBgm(isMainUI)
	local bgm = DynamicConfigData.t_Bgm[self.__cname]
	if __USE_TEST_SOUND__ or __AGENT_CODE__ == "g1pingce1" then
		bgm = DynamicConfigData.t_Bgm2[self.__cname]
	end
	if bgm then
		print(1,"有配置 播放音效",bgm.music)
		SoundManager.playMusic(bgm.music, nil, isMainUI, self._viewName)
	end
end

function View:__fitToScreen(fitPage)
	--Fgui 全屏适配方案处理
	if self._isFullScreen then


		local targetHeight = 720
		local targetWidth = 1280
		if display.height > 720 then
			targetHeight = 720
		elseif display.width > 1400 then
			if SettingModel.data.sp then
				targetWidth = targetWidth + SettingModel.data.sp/100.0 * (display.width - targetWidth)
			else
				targetWidth = 1400
			end

		end
		print(33,"targetWidth=",targetWidth)
		self.view:setSize(targetWidth, targetHeight)
		if not self._parentWin then
			self.view:setPosition((display.width - targetWidth)/2, (display.height - targetHeight)/2)
		end
		
		if fitPage and self.ctlView then
			for k,v in pairs(self.ctlView) do
				v:__fitToScreen(fitPage)
			end
		end
	end

end
--添加到父节点上
function View:addToParent( )
	-- LuaLogE("View:addToParent")
	if(self.view and self._parent) then
		self.view._rootDepth = self._rootDepth
		if self.view:getName() == "" then
			self._parent:addChildByName(self.view,self._compName)
		else
			self._parent:addChild(self.view)
		end
		self.view.sortingOrder = self._sortingOrder
		if self._posX then
            self.view.x = self._posX
        end
        if self._posY then
            self.view.y = self._posY
        end
	end
end

--
function View:centerScreen( )
	self.view:setPivot(0.5,0.5,true)
	self.view:setPosition(display.cx,display.cy)
end

--事件监听
function View:addEventListener(name, listener, listenerCaller, priority)
    --LuaLogE(self._viewName.."界面 View 中增加的事件监听 = "..name)
    Dispatcher.addEventListener(name, listener, listenerCaller, priority)
    table.insert(self._eventListeners, { name = name, listener = listener })
end

-- 删除所有侦听的事件
function View:clearEventListeners()
    for _, event in ipairs(self._eventListeners) do
       print(0,self._viewName.."界面 View 中删除的事件监听 = "..event.name)
        Dispatcher.removeEventListener(event.name, event.listener)
    end
end

--内部close 不可直接调用
function View:close()
    LuaLogE(self._viewName.."do close function")
    if string.find(self._viewName,'RollTipsView')==nil  then
        SoundManager.playSound(2,false)
    end
    if self.donecb then
		self.donecb = false
	end
    --执行红点处理移除
    RedManager.removeAll(self.view)
	if not self._isClosing then
		self._isClosing = true
	    if self.view then
	    	--对象销毁
	    	ViewManager.subCount(self._packName, self._compName)
	        self.view:removeFromParent()
			self:_exitFinish()
	        self.view = false
	    end
	end
	
	--有配置
	local bgm = DynamicConfigData.t_Bgm[self.__cname]
	if __USE_TEST_SOUND__ or __AGENT_CODE__ == "g1pingce1" then
		bgm = DynamicConfigData.t_Bgm2[self.__cname]
	end
	if bgm then
		print(1,"有音效配置")
		
		local topView = ViewManager.getLayerTopWindow(nil,{[LayerDepth.MainUI] = true,[LayerDepth.RollTips] = true,[LayerDepth.Guide] = true,[LayerDepth.Message] = true,[LayerDepth.UIEffect] = true})
		if not topView then
			--SoundManager.initLastMusicArr()
			--SoundManager.playMusic(6) --主界面背景音乐66
			--self:playBgm()
		else
			print(1,"topView",topView.window._viewName)
			--如果最后一个背景音乐刚好是关闭的这个界面，刚删除最后一个，并播放上一个
			--如果不是最后一个，则只需要从音乐列表中删掉就行
			local info = SoundManager.getLastMusicId()
			if info.viewName == self._viewName then
				--print(1,"last musicid",id)
				SoundManager.deleteLastMusicId()
				info = SoundManager.getLastMusicId()
				if info then
					SoundManager.playMusic(info.musicKey)
				end
			else
				SoundManager.deleteLastMusicId(self._viewName)
			end
		end
	end
end

--[[
    刘海屏适配
    注意：这里只适配不会动态改变位置的控件
    会动的控件需要自己单独创建一个组件
]]
function View:_doUpdateScreenOrientation()
end


--在_toInit完成之后执行
function View:__onEnter()
    --print(1,"View __onEnter")
	-- if not self._transToShow then
 --        if self._doShowAnimation then
 --            self:_onShow()
 --            self:_doShowAnimation()
 --        else
 --            self:_onShow()
 --            self:onAnimateEnd()
 --        end
 --    else
 --        if self._doShowAnimation then
 --            self:_doShowAnimation()
 --        else
 --            self:_onShow()
 --            self:onAnimateEnd()
 --        end
 --    end

	self:_enter()
end


-- function View:_onShow( ... )
-- 	-- self:_initEvent()
-- 	self:_enter()
-- end


--退出操作 在close执行之前 
function View:__onExit()
    print(1,"View __onExit")
   --if self._showParticle then
		--SpineUtil.retainSpine("efx_xuehua")
   --end
   SpineUtil.retainSpine("efx_xuehua")
   self:_exit() --执行子类重写
   self:clearEventListeners()

end

---------------外部可调用接口-------------------------------
--关闭界面 --下一帧
function View:closeViewNextFrame()
	Scheduler.scheduleNextFrame(function()
			if not tolua.isnull(self.view) then 
				self:closeView()
			end
		end)
end

--关闭界面 --经过UI管理器
function View:closeView()
    print(5, "ViewManager.close", self._viewName)
	--作为子页的时候不能调用关闭 需要执行主窗口的closeView
	if self._parentWin then
		self._parentWin:closeView()
	else
    	ViewManager.close(self._viewName)
	end
	
	
end

function View:hideView()
    ViewManager.hide(self._viewName)
end

--设置隐藏状态
function View:setVisible(value)
    if self.view then
        self.view:setVisible(value)
    end
end

--获得隐藏状态
function View:getVisible()
    if self.view then
        self.view:isVisible()
    end
    return false
end

--获得父节点
function View:getParent()
    return self._parent
end

---------------外部可调用接口-------------------------------


----------------继承重写---------------------
-- [子类重写] 排除的自动绑定的方法  ctor 之后
function View:excludebindMapFun( ... )
	return {}
end

-- [子类重写] 添加后执行 _initUI之前
function View:_enter()
end


-- [子类重写] 初始化UI方法 
function View:_initUI( ... )
	-- body
end

-- [子类重写] 准备事件 _initUI之后
function View:_initEvent( ... )
	-- body
end 
-- [子类重写] 准备事件 _initUI之后
function View:_addRed( ... )
    --body
end

-- [子类重写] 移除后执行 close之后
function View:_exit()
	
end

-- [子类重写] 移除后执行 close之后 不稳定，外部关闭（非主动关闭）可能不会触发
function View:_exitFinish()

end

--[子类重写] 新手引导时需要执行的操作
function View:_doGuideFunc(args)
	GuideModel:_doGuideFunc(args)
end

----------------继承重写---------------------


return View
