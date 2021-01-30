--aded by xhd Window :View
--窗口window基类
local Window,Super = class("Window", View)
function Window:ctor( args )
	-- LuaLogE("Window:ctor")
	
	self.showMoneyType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
		} --显示的货币类型，从左到右排列
	--层级
	self._rootDepth = LayerDepth.Window
	--标题
	self._titleTxt = false
	-- mask类型 0无遮挡 1虚化 2黑框
	self._maskType = 0
	-- 是否显示钱
	self._moneyType = true
	-- 是否需要隐藏主界面UI（在模糊出现之前）
	self._hideMainUI = false
	-- 窗口框
	self._frame = false
	-- 关闭按钮
	self._closeBtn = false
	-- 窗口标题
	self._titleLabel = false
	-- 内容区域
	self._contentArea = false
	-- 内容节点
	self._contentNode = false
	-- 拖动区域
	self._dragArea = false
	
	--是否点击背景关闭
	self._bgClose = true
	
	-- 是否隐藏关闭按钮
	self._hideCloseBtn = false
	
	-- 模态等待panel
	self._modalWaitPane = false
	
	--是否使用动画
	self.isPlayingAnimation = false
	
	self._transToShow = false
	--金钱条
	self.moneyBar = false
    --帮助按钮
    self.btn_help = false
	
	self._title = false   --窗口标题
	self._closeBtn = false --窗口关闭按钮


    
end

function Window:init( ... )
	--print(1,"Window:init")
	if self._maskType ==1 then
		self._hideMainUI = true
	end
end

function Window:__toInit()
	print(1,"Window:__toInit")
	--默认添加静态模糊

	
	
	self:closeModalWait()
	self:__initWindowBase()
	Super.__toInit(self)
	
end

function Window:__initWindowBase()
	print(1,"Window:__initWindowBase")
	
	self:playBgm()
	--标签节点
	self._frame = FGUIUtil.getChild(self.view,"frame","GComponent")
	if not self._frame then
		self._frame = self.view --多页面的情况
	end
	
	--关联的关闭按钮
	self._closeBtn = self._frame:getChildAutoType("closeButton")
	if self._closeBtn then
		self._closeBtn:addClickListener(function ()
			self:closeView()
		end)
		if self._hideCloseBtn and not tolua.isnull(self._closeBtn)then
			self._closeBtn:setVisible(false)
		end
	end


	self.btn_help = self._frame:getChildAutoType("btn_help")
	if self.btn_help then
		self.btn_help:addClickListener(
	        function(...)
	        	if not self._args.moduleId  then
	        		if not __IS_RELEASE__ then
	        			RollTips.show(DescAuto[40]) -- [40]="获取不到模块ID,需要用ModuleUtil.openModule的方式打开"
	        		end
	        		return
	        	end

	        	if not Desc["help_StrTitle"..self._args.moduleId]  then
	        		if not __IS_RELEASE__ then
	        			RollTips.show(Desc.window_noconfig)
	        		end
	        		return
	        	end

	            local info={}
	            info['title']=Desc["help_StrTitle"..self._args.moduleId]
	            info['desc']=Desc["help_StrDesc"..self._args.moduleId]
	            ViewManager.open("GetPublicHelpView",info) 
	        end
	    )
	end
	local blackBg = self.view:getChildAutoType("blackBg")
	if not blackBg then
		blackBg = self.view:getChildAutoType("blackbg")
	end

	if not blackBg then
		blackBg = self.view:getChildAutoType("blackbgAlpha")
	end
	if blackBg then
		blackBg:addClickListener(function ()
			if self._bgClose then
				self:closeView()
			end
		end)
	end
	
	-- 标题
	self._titleLabel = FGUIUtil.getChild(self._frame,"title","GTextField")
	if self._titleLabel then
		self:_initTitleLabel(self._titleLabel)
	end
	
	-- 内容区域
	self._contentArea = FGUIUtil.getChild(self._frame,"contentArea","GComponent")
	
	-- 空的内容节点
	self._contentNode = self._frame:getChild("contentNode")	
	
	if self._frame  then
		
		--初始化金钱列表
		local moneyBar = self._frame:getChildAutoType("moneyComp")
		if moneyBar then
			--把金钱条移到最上层
			moneyBar:retain()
			moneyBar:removeFromParent()
			self.view:addChild(moneyBar)
			moneyBar:release()
			self.moneyBar = BindManager.bindMoneyBar(moneyBar)
			self.moneyBar:setData(self.showMoneyType)
		end
	
		
		
		--当屏幕刚好是1280*720时隐藏竖线
		local line_ver = self._frame:getChildAutoType("line_ver")
		if line_ver and display.height/display.width >= 720/1280 then
			line_ver:setVisible(false)
		end
		
		
		--[[local title = self._frame:getChildAutoType("title")
		if title then
			--把标题移到最上层
			title:retain()
			title:removeFromParent()
			self.view:addChild(title)
			title:release()
		end	--]]	
	end
end


--把标题移到最高层
function Window:moveTitleToTop()
	self._title = self._frame:getChildAutoType("title")
	if self._title then
		--把金钱条移到最上层
		self._title:retain()
		self._title:removeFromParent()
		self.view:addChild(self._title)
		self._title:release()
	end

	self._closeBtn = self._frame:getChildAutoType("closeButton")
	if self._closeBtn then
		self._closeBtn:retain()
		self._closeBtn:removeFromParent()
		self.view:addChild(self._closeBtn)
		self._closeBtn:release()
	end
	
	self._closeBtnArrow = self._frame:getChildAutoType("close")
	if self._closeBtnArrow then
		self._closeBtnArrow:retain()
		self._closeBtnArrow:removeFromParent()
		self.view:addChild(self._closeBtnArrow)
		self._closeBtnArrow:release()
	end
end

--设置金钱显示类型
function Window:setMoneyType(moneyType)
	self.showMoneyType = moneyType
	if self.moneyBar then
		self.moneyBar:setData(self.showMoneyType)
	end
end


function Window:__onEnter()
	print(1,"Window __onEnter")
	self:__updateWindowCount(true)
	self:__updateMainUIShow(true)
	self:__updateMaskShow(true)
	Super.__onEnter(self)
end

--退出时触发
function Window:__onExit()
	self:__updateWindowCount(false)
	Super.__onExit(self)
end



function Window:close( isImmediate)
	if not self._isClosing and self.view then
		self:__updateMainUIShow(false)
		self:__updateMaskShow(false)
	end
	Super.close(self,isImmediate)
	
end

function Window:_setMoneyType(typeList)
	self.showMoneyType = typeList
	if(self.moneyBar) then
		self.moneyBar:setData(self.showMoneyType)
	end
end

--显示 播放动画 暂时不加动画
function Window:_doShowAnimation()
end

--关闭播放动画  暂时不加动画
function Window:_doHideAnimation( ... )
	-- body
end




--虚化更新
function Window:__updateMaskShow(bool)
	-- 虚化
	if bool then
		if self._maskType == 2 or self._maskType == 1 then
			local layer = cc.LayerColor:create(cc.c4b(0,0,0,120),display.width,display.height);
			layer:setAnchorPoint(0.5,0.5)
			local pos = self.view:localToGlobal(Vector2.zero)
			layer:setPosition(-pos.x,-pos.y)
			self.view:displayObject():addChild(layer,-1)
		end
	end
end


--更新窗口计数
function Window:__updateWindowCount(bool)
	if bool then
		ViewManager.addWindowCount()
		-- Dispatcher.dispatchEvent(EventType.WINDOW_COUNT_ADD)
	else
		ViewManager.subWindowCount()
		-- Dispatcher.dispatchEvent(EventType.WINDOW_COUNT_SUB)
	end
end

--主界面更新显示
function Window:__updateMainUIShow(bool)
	if self._hideMainUI then
		if bool then
			-- Dispatcher.dispatchEvent(EventType.HIDE_MAINUI_COUNT_ADD)
		else
			-- Dispatcher.dispatchEvent(EventType.HIDE_MAINUI_COUNT_SUB)
		end
	end
end


--window 加入父节点
function Window:addToParent( ... )
	Super.addToParent(self)
	-- self.view:center(true)
end


function Window:_initTitleLabel( titleLabel )
	print(1,"Window _initTitleLabel")
	if not titleLabel then return end
	local title = self._titleTxt
	if title then
		titleLabel:setText(title)
	end
end


-- 更新背景
function Window:setBg(value)
	local fullScreen = self.view:getChildAutoType("frame/fullScreen")
	fullScreen:setIcon(PathConfiger.getBg(value))
end

-- 更新标题文本
function Window:setTitle(value)
	if value ~= nil and value ~= self._titleTxt then
		self._titleTxt = value
		self:_initTitleLabel(self._titleLabel)
	end
end

--开启模态等待
function Window:showModalWait( ... )
	if self._modalWaitPane==false then
		if self._frame and self._contentArea then
			self._modalWaitPane = UIPackageManager.createGComponent("UIPublic", "ModalWaitView")
			self._modalWaitPane.sortingOrder = 1
		end
		if self._contentNode then
			self._contentNode.addChild(self._modalWaitPane)
		else
			self.view:addChild(self._modalWaitPane)
		end
		self._layoutModalWaitPane()
	end
end

--模态显示布局
function Window:_layoutModalWaitPane( ... )
	local pt = self._frame.localToGlobal(Vector2.zero)
	pt = self.view:globalToLocal(pt)
	self._modalWaitPane:setPosition(pt.x+self._contentArea.getX(),pt.y+self._contentArea.getY())
	self._modalWaitPane:setSize(self._contentArea:getWidth(), self._contentArea:getHeight());
	self._layoutModalWaitPane.addRelation(self._contentArea,fgui.RelationType.Size)
end

--关闭模态等待
function Window:closeModalWait(  )
	if self._modalWaitPane and not self._modalWaitPane:getParent() then
		self._contentNode.removeChild(self._modalWaitPane)
		self._modalWaitPane = false
	end
end



return Window

