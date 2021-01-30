-- added by wyz
-- 远征探员列表

local EDAgentListView = class("EDAgentListView",Window)


function EDAgentListView:ctor()
	self._packName = "Expedition"
	self._compName = "EDAgentListView"
	self._rootDepth = LayerDepth.PopWindow
	self.agentList 	= false 		-- 探员列表
end

function EDAgentListView:_initUI()
	self.agentList = self.view:getChildAutoType("agentList")
end

function EDAgentListView:_initEvent()
	-- ExpeditionModel:reqAgentList()
	self.agentList:setVirtual()
	self.agentList:setItemRenderer(function(idx,obj)
		local data=	ExpeditionModel.agentArray[idx+1]
		local heroCell = BindManager.bindHeroCell(obj)
		heroCell:setData(data)
		heroCell:showNp(data.rage)
	end)

	self.agentList:setData(ExpeditionModel.agentArray)
end

return EDAgentListView