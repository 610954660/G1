local CrossPVPBattleView,Super = class("CrossPVPBattleView", Window)

function CrossPVPBattleView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPBattleView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossPVPBattleView:_initEvent()
	
end

function CrossPVPBattleView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPBattleView
	self.btn_allDown = viewNode:getChildAutoType('btn_allDown')--GButton
	self.btn_change = viewNode:getChildAutoType('btn_change')--GButton
	self.c1 = viewNode:getController('c1')--Controller
	self.c2 = viewNode:getController('c2')--Controller
	self.list_team = viewNode:getChildAutoType('list_team')--GList
	--{autoFieldsEnd}:CrossPVP.CrossPVPBattleView
	--Do not modify above code-------------
end

function CrossPVPBattleView:_initUI()
	self:_initVM()
	local teamArr = CrossPVPModel:getPVPEnum()
	CrossPVPModel:setCurPVPModule(teamArr[1])
	self.list_team:addClickListener(function(idx)
        if (self.list_team:getSelectedIndex() + 1 ~= CrossPVPModel:getCurPVPModule()) then
			CrossPVPModel:setCurPVPModule(teamArr[self.list_team:getSelectedIndex() + 1])
            Dispatcher.dispatchEvent("battle_CrossChangeTeamType",teamArr[self.list_team:getSelectedIndex() + 1])
        end
    end)
	
	self.btn_change:addClickListener(function()
		ViewManager.open("CrossPVPSetArrayView")
	end)
	
	self.btn_allDown:addClickListener(function()
		local info = {
			text = Desc.CrossPVPDesc1,
			type="yes_no",
			onYes= function()
				CrossPVPModel:clearTypeAllHeroTemp()
			end,
		}
		Alert.show(info)
	end)
	
	self:_refreshView()
end


function CrossPVPBattleView:_refreshView()

end

function CrossPVPBattleView:onExit_()

end

return CrossPVPBattleView