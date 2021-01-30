local PataBigReWard,Super = class("PataBigReWard", Window)
local ItemCell = require "Game.UI.Global.ItemCell"

function PataBigReWard:ctor()
	LuaLogE("PataRankReward ctor")
	self._packName = "Pata"
	self._compName = "PataBigReWard"

	self._rootDepth = LayerDepth.PopWindow
	
    self.rewardList=false

end
--初始化界面处理
function PataBigReWard:_initUI()
	LuaLogE("PataBigReWard _initUI")
	self.rewardList=self.view:getChildAutoType("list_rank")	
	self:setData()
end

function PataBigReWard:setData()
	local nowFloor=PataModel:getFightFloor()-1
	local activeType= PataModel.activeType
	
	--local allFloorReward = clone(DynamicConfigData.t_towerBigReward[activeType])
	local allFloorReward={}
	for k, scoreData in pairs(DynamicConfigData.t_towerBigReward[activeType]) do
		local  cloneScoreData={}
		for key, v in pairs(scoreData) do
			cloneScoreData[key]=v
		end
		table.insert(allFloorReward,cloneScoreData)
	end
	print(5656,allFloorReward,"allFloorReward")
	
	
	local copyInfo = ModelManager.MaterialCopyModel:getCopyInfo(activeType)
	local bigReward = copyInfo.diffPass.bigRewar
	
	for i, v in ipairs(allFloorReward) do
		if v.level<=nowFloor then
			v.type=1
		else
			v.type=0
		end
	end
	table.sort(allFloorReward,function (a,b)	
			if a.type==b.type then
				return a.level<b.level
			else
				return a.type<b.type
			end	
	end)
	self.rewardList:setVirtual()
	self.rewardList:setItemRenderer(function (index,rewardItem)
			local rewardData=allFloorReward[index+1]
		    
			local itemList=rewardItem:getChildAutoType("itemList")
			local level=rewardItem:getChildAutoType("passLimit")
			local receviedCtrl=rewardItem:getController("rewardType")
			local goInto=rewardItem:getChildAutoType("goInto")
			local color= false
			if nowFloor>=rewardData.level then
				color="#24a41c"
				receviedCtrl:setSelectedIndex(1)
			else
				color=ColorUtil.chatIemColorStr[6]
				receviedCtrl:setSelectedIndex(0)
			end
			goInto:addClickListener(function ()
					Dispatcher.dispatchEvent(EventType.pata_beginChallege)
					ViewManager.close("PataBigReWard")
			end,101)
		
			level:setText(string.format(Desc.pata_desc3,rewardData.level)..ColorUtil.formatColorString(string.format(Desc.pata_desc4, nowFloor,rewardData.level),color))
			itemList:setItemRenderer(function (k,itemObj) 
				   local itemcell = BindManager.bindItemCell(itemObj)
				   local itemData = ItemsUtil.createItemData({data = rewardData.reward[k + 1]})
				   itemcell:setItemData(itemData)
			end)
			itemList:setData(rewardData.reward)
	end)
	self.rewardList:setData(allFloorReward)
	
end


--退出销毁处理
function PataBigReWard:_exit()
end

return PataBigReWard

