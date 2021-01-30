--Date :2021-01-10
--Author : generated by FairyGUI
--Desc : 

local BatteSpeedView,Super = class("BatteSpeedView", Window)

function BatteSpeedView:ctor()
	--LuaLog("BatteSpeedView ctor")
	self._packName = "Battle"
	self._compName = "BatteSpeedView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.unLockSpeed=1
	self.recomInfo=false
	
end

function BatteSpeedView:_initEvent( )
	
end

function BatteSpeedView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:Battle.BatteSpeedView
	self.blacmask = viewNode:getChildAutoType('blacmask')--GLabel
	self.btn_add = viewNode:getChildAutoType('btn_add')--GButton
	self.btn_add1 = viewNode:getChildAutoType('btn_add1')--GButton
	self.btn_jump = viewNode:getChildAutoType('btn_jump')--GButton
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.dslider = viewNode:getChildAutoType('dslider')--Slider2
		self.dslider.num = viewNode:getChildAutoType('dslider/num')--GTextField
	self.nextOpen = viewNode:getChildAutoType('nextOpen')--GTextField
	self.taskIcon = viewNode:getChildAutoType('taskIcon')--GLoader
	self.titleFont = viewNode:getChildAutoType('titleFont')--GLoader
	self.typeCtr = viewNode:getController('typeCtr')--Controller
	--{autoFieldsEnd}:Battle.BatteSpeedView
	--Do not modify above code-------------
end

function BatteSpeedView:_initListener( )
	--local spConfig,unLockSpeed=BattleModel:getSpeedModule()
	
	RedManager.register("V_UNLOCKSPEED",self.btn_add:getChildAutoType("img_red"))
	self.btn_add:addClickListener(function()
			
			if not self.btn_add.touchable then
				RollTips.show(Desc.battle_speedUnlock)
				return 
			end
			
			local value = math.floor(self.dslider:getValue()+0.5)
			value=value+1
			self:setSliderValue(value)
	end)

	self.btn_add1:addClickListener(function()
			local value = math.floor(self.dslider:getValue()+0.5)
			value=value-1
		    self:setSliderValue(value)
	end)

	self.btn_jump:addClickListener(function()
			local windowId= self.recomInfo.jump
			ModuleUtil.openModule(windowId, true)
	end)
	local function onChanged( ... )
		local value = math.floor(self.dslider:getValue()+0.5)
		if value>self.unLockSpeed then
			value=self.unLockSpeed
			RollTips.show(Desc.battle_speedUnlock)
		end
		BattleModel:saveSpViewSetting(value)
		self:setBtnState(value)
		self.dslider:getChildAutoType("num"):setText("+"..(value))
	end
	self.dslider:addEventListener(FUIEventType.Changed, onChanged);
	self.dslider:displayObject():onUpdate(function (dt)
			local value = math.floor(self.dslider:getValue()+0.5)
			if value>self.unLockSpeed then
				value=self.unLockSpeed
				self.dslider:setValue(self.unLockSpeed)
			end
	end,0)

end

function BatteSpeedView:_initUI( )
	self:_initVM()
	self:setData()
	self:_initListener()
end

function BatteSpeedView:setData()
	local spV=BattleModel:getSpViewSetting()
	local spConfig,unLockInfo=BattleModel:getSpeedModule()
	
	self.unLockSpeed=unLockInfo.unLockSpeed
	local maxSpeed=spConfig[#spConfig].speed
	self.dslider:setMax(maxSpeed)
	if unLockInfo.nextOpenTip then
		self.nextOpen:setText(unLockInfo.nextOpenTip)
	end
	
	self.recomInfo=BattleModel:getRecommendInfo()

	self.taskIcon:setURL(PathConfiger.getSpeedTip(self.recomInfo.picture))
	if self.recomInfo.type==0 then
		self.typeCtr:setSelectedPage("type"..self.recomInfo.type)
	end


	self:setSliderValue(spV,true)
end


function BatteSpeedView:setSliderValue(value,init)
	BattleModel:saveSpViewSetting(value)
	self.dslider:setValue(value)
	self.dslider:getChildAutoType("num"):setText("+"..(value))
	self:setBtnState(value,init)
end

function BatteSpeedView:setBtnState(value,init)
	local spConfig,unLockInfo=BattleModel:getSpeedModule()
	local spV=value or BattleModel:getSpViewSetting()
	
	if not init and unLockInfo.unLockSpeed>BattleModel.recordSpeed then
		BattleModel:setUnLockSpeed(unLockInfo.unLockSpeed)
		BattleModel:updateRed(unLockInfo.unLockSpeed)
	end
	
	if spV>=self.unLockSpeed then
		self.btn_add:setGrayed(true)
		self.btn_add:setTouchable(not unLockInfo.unLockAll)
		self.btn_add.touchable=false
	else
		self.btn_add:setGrayed(false)
		self.btn_add:setTouchable(true)
		self.btn_add.touchable=true
	end
	
	if spV==0 then
		self.btn_add1:setGrayed(true)
		self.btn_add1:setTouchable(false)
	else
		self.btn_add1:setGrayed(false)
		self.btn_add1:setTouchable(true)
	end
	Dispatcher.dispatchEvent(EventType.buoyWindow_SpeedChange)
end


--退出操作 在close执行之前
function BatteSpeedView:__onExit()
	Dispatcher.dispatchEvent(EventType.buoyWindow_Close)
end




return BatteSpeedView