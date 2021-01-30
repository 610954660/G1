-- added by xhd
-- 神社祈福 终极宝物

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local ActBlessView = class("ActBlessView",Window)

function ActBlessView:ctor()
	self._packName 	= "ActShrineBless"
	self._compName 	= "ActBlessView"

	self.config = false
	self.serverData = false
	self.curSelect = false
	self._rootDepth  = LayerDepth.PopWindow
	self.tabData = false
	self.curTabData = false
	self.selectedIndex = 0 --当前选中的Index
end



function ActBlessView:_initUI()
    --已经存在大奖选择器
	self.awardList = self.view:getChildAutoType("awardList")
	self.WishBtn = self.view:getChildAutoType("WishBtn")
	self.tabList = self.view:getChildAutoType("tabList")
	self.layerLab = self.view:getChildAutoType("layerLab")
	self.txt_evenyLayer = self.view:getChildAutoType("txt_evenyLayer")
	local Devide = ActShrineBlessModel:getDevideByModuleId()
	self.txt_evenyLayer:setText(string.format("(每隔%s层可选珍稀宝物)", Devide))

	self.WishBtn:addClickListener(function( ... )
		if not (self.curSelect and self.curSelect.id>0) then
			RollTips.show(Desc.activity_txt28)
			return 
		end
		local params = {}
		params.activityId = ActShrineBlessModel:getActivityId( )
		params.id = self.curSelect.id
		printTable(1,params)
		params.onSuccess = function (res )
			ViewManager.close("ActBlessView")
		end
		 RPCReq.Activity_ShrinePray_AddWish(params, params.onSuccess)
	end)
	
	--标签栏显示
	self.tabList:setItemRenderer(function(idx,obj)
		local curTabData = self.tabData[idx+1]
		if curTabData[1]~=curTabData[2] and curTabData[2] ~= nil then
			obj:setTitle("每"..curTabData[1].."-"..curTabData[2]..Desc.activity_txt40)
		else
			obj:setTitle("每"..curTabData[1]..Desc.activity_txt40)
		end
		if curTabData and self.curTabData then
			if self.curTabData[1] == curTabData[1] and self.curTabData[2] == curTabData[2] then
				obj:setSelected(true)
			else
				obj:setSelected(false)
			end
		else
			if idx == 0 then
				obj:setSelected(true)
				self.curTabData = self.tabData[idx+1]
			else
				obj:setSelected(false)
			end
		end
	end)

	self.tabList:addEventListener(FUIEventType.ClickItem,function()
		local index = self.tabList:getSelectedIndex() + 1
		self.curSelect = false
		self.curTabData = self.tabData[index]
		self.config = ActShrineBlessModel:getChooseConfigByMod( self.curTabData[1] )
		self.awardList:setData(self.config)
		--如果层数不对 按钮不能点击
	
		local Devide = ActShrineBlessModel:getDevideByModuleId()
		local tempRing = self.serverData.ring%Devide 
		if tempRing == 0 then tempRing = Devide end

        if self.curTabData[1] ~=self.curTabData[2] then
			if tempRing >= self.curTabData[1] and tempRing<= self.curTabData[2] then
				self.WishBtn:setGrayed(false)
			    self.WishBtn:setTouchable(true)
			else
				self.WishBtn:setGrayed(true)
				self.WishBtn:setTouchable(false)
			end
		else
			local temp = self.serverData.ring%self.curTabData[1]
			if temp == 0 then temp = self.curTabData[1] end
			if tempRing==Devide and tempRing ==  temp  then
				self.WishBtn:setGrayed(false)
			    self.WishBtn:setTouchable(true)
			else
				self.WishBtn:setGrayed(true)
				self.WishBtn:setTouchable(false)
			end
		end
	end)
	
	--许愿池列表
	self.awardList:setVirtual()
	self.awardList:setItemRenderer(function(idx,obj)
		local curConfig = self.awardList._dataTemplate[idx+1]
		local statusCtrl = obj:getController("statusCtrl")
		local reward 	= curConfig.reward[1]
		local itemCell = obj:getChildAutoType("itemCell")
		local itemCellObj 	= BindManager.bindItemCell(itemCell)
		
		--obj:setTouchable(true)
		itemCellObj:setClickable(false)
		obj:setSelected(false)
		-- itemCellObj:setIsBig(true)
		local clickable = false
		if self.curSelect and  self.curSelect.id == curConfig.id then
			self.selectedIndex = idx
			self.awardList:setSelectedIndex(self.selectedIndex)
		end
		itemCellObj:setData(reward.code, reward.amount, reward.type)
		local itemconfig = ItemConfiger.getInfoByCode(reward.code, reward.type)
		obj:getChildAutoType("itemName"):setText(itemconfig.name)
		local hadNum = ActShrineBlessModel:getLimitbyCodeId( curConfig.id )
		obj:getChildAutoType("num"):setText(hadNum.."/"..curConfig.limit)
		statusCtrl:setSelectedIndex(0)

		if self.serverData.wish and self.serverData.wish>0 and self.serverData.wish == curConfig.id then
			statusCtrl:setSelectedIndex(1)
		end

		if hadNum>=curConfig.limit then
			statusCtrl:setSelectedIndex(2)
		end
		
		if curConfig.floor ~= "" and self.serverData.ring < curConfig.floor then
			statusCtrl:setSelectedIndex(3)
			obj:getChildAutoType("txt_level"):setText(curConfig.floor.."层可选")
			clickable = true
		end
		
		obj:removeClickListener()
		obj:addClickListener(function( ... )
			if clickable or (self.curSelect and  self.curSelect.id == curConfig.id) then
				itemCellObj:onClickCell(true)
			else
				if curConfig.floor ~= "" and self.serverData.ring < curConfig.floor then
					itemCellObj:onClickCell(true)
					return 
				end
				self.curSelect = curConfig
				self.selectedIndex = idx
				self.awardList:setSelectedIndex(idx)
			end
		end)
	end)
	--[[self.awardList:addEventListener(FUIEventType.ClickItem,function(obj)
		local index = self.awardList:getSelectedIndex() + 1
		local curConfig = self.awardList._dataTemplate[index]
		if curConfig.floor ~= "" and self.serverData.ring < curConfig.floor then
			self.awardList:setSelectedIndex(self.selectedIndex)
			return 
		end
		self.curSelect = self.config[index]
		self.selectedIndex = index -1
	end)--]]
end

function ActBlessView:_initEvent( ... )
	self:initPanel()
end

function ActBlessView:initPanel( ... )

	self.serverData = ActShrineBlessModel:getData( ... )
	self.layerLab:setVar("layer",tostring(self.serverData.ring))
	self.layerLab:flushVars()
	self.tabData = ActShrineBlessModel:getTabData()
	local index = 0
	local Devide = ActShrineBlessModel:getDevideByModuleId()
	local tempRing = self.serverData.ring% Devide
	if tempRing == 0 then tempRing = Devide end
	self.curTabData = self.tabData[1]
	for i=1,#self.tabData do
		if self.tabData[i][1] ~=self.tabData[i][2] then
			if tempRing>= self.tabData[i][1] and tempRing<= self.tabData[i][2] then
				self.curTabData = self.tabData[i]
				break
			end
		else
			local temp = self.serverData.ring%self.tabData[i][1]
			if temp == 0 then temp = self.tabData[i][1] end
			if tempRing==Devide and tempRing ==  math.modf(temp)  then
				self.curTabData = self.tabData[i]
				break
			end
		end
	end
	self.tabList:setData(self.tabData)
	if self.curTabData then
		self.config = ActShrineBlessModel:getChooseConfigByMod( self.curTabData[1] )
		self.awardList:setData(self.config)
	end
end


function ActBlessView:_exit()

end

return ActBlessView