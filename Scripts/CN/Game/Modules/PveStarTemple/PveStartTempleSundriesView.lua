--Name : PveStartTempleSundriesView.lua
--Author : generated by FairyGUI
--Date : 2020-7-31
--Desc : 

local PveStartTempleSundriesView,Super = class("PveStartTempleSundriesView", Window)

function PveStartTempleSundriesView:ctor()
	--LuaLog("PveStartTempleSundriesView ctor")
	self._packName = "PveStarTemple"
	self._compName = "PveStartTempleSundriesView"
	self._rootDepth = LayerDepth.PopWindow
	self.areaID = self._args.areaID
	self.pos = self._args.pos
	self.eventID = self._args.eventID
	self.configData = ModelManager.PveStarTempleModel:getEventConfig(5,0,self.eventID)
	self.optionList = {}
	self.optionDataList = {}
	self.resultDataList = {}
end

function PveStartTempleSundriesView:_initEvent( )
	
end

function PveStartTempleSundriesView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:PveStarTemple.PveStartTempleSundriesView
		--{vmFieldsEnd}:PveStarTemple.PveStartTempleSundriesView
	--Do not modify above code-------------
end

function PveStartTempleSundriesView:_initUI( )
	self:_initVM()
	self.txtDesc = self.view:getChildAutoType("txtDesc")
	self.optionList[1] = self.view:getChildAutoType("op1")
	self.optionList[2] = self.view:getChildAutoType("op2")

	self.view:getChildAutoType("n30"):setURL(PathConfiger.getPveStarTempleBG("lockbox_frame"))

	self:updateView()
	self:updateOptionList()
end

function PveStartTempleSundriesView:_exit()
	self.areaID = false
	self.pos = false
	self.eventID = false
	self.optionDataList = false
	self.resultDataList = false
	self.configData = false
	self.optionList = false
end

function PveStartTempleSundriesView:updateView()
	self.txtDesc:setText(self.configData.dec)
end

function PveStartTempleSundriesView:updateOptionList()
	self.optionDataList = {}
	self.resultDataList = {}

	for word in string.gmatch(self.configData.option,'%[([^%[%]]+)%]') do
		table.insert(self.optionDataList,word)
	end

	for word in string.gmatch(self.configData.result,'%[([^%[%]]+)%]') do
		table.insert(self.resultDataList,word)
	end

	for i,v in ipairs(self.optionList) do
		v:setTitle(self.optionDataList[i])
		v:addClickListener(function()
			self:onOptionClick(i)
		end,1)
	end
end


function PveStartTempleSundriesView:onOptionClick(index)
	RollTips.show(self.resultDataList[index])
	Dispatcher.dispatchEvent(EventType.PveStarTemple_EevntUse,{areaID = self.areaID,pos = self.pos})
	self:closeView()
end


return PveStartTempleSundriesView