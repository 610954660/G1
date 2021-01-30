--added by wyang
--秘境摇骰子组件
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FairyLandMapItem,Super = class("FairyLandMapItem",BindView)
function FairyLandMapItem:ctor(view)
	self.data = false
	self.iconLoder = false
	self.c1 = false
	self.btn_roll = false
	self.txt_name = false
	self.txt_title = false
	self.img_shadow = false
	self.clound = false
	self._isShow = false
	self._spineModel = false
end

function FairyLandMapItem:_initUI( ... )
	self.iconLoder = self.view:getChildAutoType("icon")
	self.c1 = self.view:getController("c1")
	self.btn_roll = self.view:getChildAutoType("btn_roll")
	self.txt_name = self.view:getChildAutoType("txt_name")
	self.txt_title = self.view:getChildAutoType("txt_title")
	self.clound = self.view:getChildAutoType("clound")
	self.img_shadow = self.view:getChildAutoType("img_shadow")
end

--有状态更新
function FairyLandMapItem:fairyLand_gotRewardUpdate(event, data)
	if(self.data and data.floor == self.data.floor and data.grid == self.data.grid) then
		--self:updateIcon()
		if not tolua.isnull(self.iconLoder) then
			if self.data.type == GameDef.FairyLandGridType.Reward or self.data.type == GameDef.FairyLandGridType.Magnet then
				self.view:getTransition("t0"):play(function()
					self.iconLoder:setVisible(false)
					self.iconLoder:setAlpha(1)
					self.iconLoder:setPosition(-4,-47)
					self.iconLoder:setScale(0.6,0.6)
				end)
			else
				self.iconLoder:setVisible(false)
			end
			self.txt_name:setVisible(false)
			self.img_shadow:setVisible(false)
			self.c1:setSelectedIndex(0)
		end
	end
end

function FairyLandMapItem:setData(data)
	self.data = data
end

function FairyLandMapItem:setState(isShow, isInit)
	if isInit then
		self:clear()
	end
	if self._isShow  ~= isShow or isInit then
		self._isShow  = isShow
		self:updateState(isInit)
	end
end

function FairyLandMapItem:updateState(isInit)
	
	if self._isShow then
		local onComplete = function()
			if tolua.isnull(self.view) then return end
			self:updateIcon()
			self.clound:setAlpha(0)
			self.clound:setVisible(false)
		end
		if isInit then
			onComplete()
		else
			TweenUtil.alphaTo(self.clound, {from = 1, to = 0, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
		end
		--self.c1:setSelectedIndex(0)
	else
		local onComplete = function()
			self:clear()
			self.clound:setAlpha(1)
			self.clound:setVisible(true)
			--self.c1:setSelectedIndex(1)
		end
		if isInit then
			onComplete()
		else
			self.clound:setVisible(true)
			TweenUtil.alphaTo(self.clound, {from = 0, to = 1, time = 0.5, ease = EaseType.Linear, onComplete=onComplete})
		end
	end
end

function FairyLandMapItem:clear()
	self.iconLoder:setURL("")
	self.txt_name:setText("")
	self.txt_name:setText("")
	self.txt_title:setText("")
	self.img_shadow:setVisible(false)
	if self._spineModel then
		self._spineModel:removeFromParent()
		self._spineModel = false
	end
end

--更新图标显示，如果已经领过奖励的不显示
function FairyLandMapItem:updateIcon()
	local iconName = ""
	self.txt_name:setText("")
	 --self.c1:setSelectedIndex(0)
	self.txt_title:setText(self.data.grid)
	
	if(not ModelManager.FairyLandModel:isRewardGot(self.data.floor, self.data.grid)) then
		self.iconLoder:setVisible(true)
		self.img_shadow:setVisible(true)
		self.txt_name:setVisible(true)
		local data = self.data
		if(data.type == GameDef.FairyLandGridType.Base) then
			
		elseif(data.type == GameDef.FairyLandGridType.Base) then
			
		elseif(data.type == GameDef.FairyLandGridType.Empty) then
		elseif(data.type == GameDef.FairyLandGridType.Reward) then
			--self.c1:setSelectedIndex(1)
			--local itemData =  ItemsUtil.createItemData({data = {code = data.show}})
			local url = ItemConfiger.getItemIconByCode(data.show)
			iconName = url
		elseif(data.type == GameDef.FairyLandGridType.Question) then
			--iconName = "UI/FairyLand/fairyLand_Question.png"
			if self._spineModel then
				self._spineModel:removeFromParent()
				self._spineModel = false
			end
			self._spineModel = SpineUtil.createModel(self.iconLoder, {x = 50, y =0}, "stand", 45002,false)
			self.txt_name:setText(Desc.fairyLand_question)
		elseif(data.type == GameDef.FairyLandGridType.Magnet) then
			iconName = "UI/FairyLand/fairyLand_Magnet.png"
		elseif(data.type == GameDef.FairyLandGridType.Guarder) then
			if self._spineModel then
				self._spineModel:removeFromParent()
				self._spineModel = false
			end
			self._spineModel = SpineUtil.createModel(self.iconLoder, {x = 50, y =0}, "stand", 54001,false)
			self.txt_name:setText(Desc.fairyLand_fight)
			--iconName = "UI/FairyLand/fairyLand_Guarder.png"
		elseif(data.type == GameDef.FairyLandGridType.Ending) then
		end
	else
		if self.data.type == GameDef.FairyLandGridType.Reward or self.data.type == GameDef.FairyLandGridType.Magnet then
			self.view:getTransition("t0"):play(function()
				self.iconLoder:setVisible(false)
				self.iconLoder:setAlpha(1)
				self.iconLoder:setPosition(-4,-47)
				self.iconLoder:setScale(0.6,0.6)
			end)
		else
			self.iconLoder:setVisible(false)
		end
		-- self.iconLoder:setVisible(false)
		self.txt_name:setVisible(false)
		self.img_shadow:setVisible(false)
		print(1, "已领取",self.data.floor, self.data.grid )
	end
	if not tolua.isnull(self.view)  and iconName ~= "" then
		self.iconLoder:setURL(iconName)
	else
		self.img_shadow:setVisible(false)
		--self.iconLoder:setPosition(5,-10)
	end
end


--退出操作 在close执行之前 
function FairyLandMapItem:__onExit()
    print(1,"FairyLandMapItem __onExit")
end

return FairyLandMapItem