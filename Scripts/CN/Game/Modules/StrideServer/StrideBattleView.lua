--Date :2020-12-27
--Author : added by xhd
--Desc : 
-- 巅峰竞技场编队额外控件
local StrideBattleView,Super = class("StrideBattleView", Window)

function StrideBattleView:ctor()
	--LuaLog("StrideBattleView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideBattleView"
	self._rootDepth = LayerDepth.WindowUI;
end

function StrideBattleView:_initEvent( )
	
end

function StrideBattleView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideBattleView
	self.btn_allDown = viewNode:getChildAutoType('btn_allDown')--GButton
	self.btn_change = viewNode:getChildAutoType('btn_change')--GButton
	self.c1 = viewNode:getController('c1')--Controller
	self.c2 = viewNode:getController('c2')--Controller
	self.list_team = viewNode:getChildAutoType('list_team')--GList
	--{autoFieldsEnd}:StrideServer.StrideBattleView
	--Do not modify above code-------------
end

function StrideBattleView:_initListener( )
	
	--重置
	self.btn_allDown:addClickListener(function()
		local info = {
			text = Desc.CrossPVPDesc1,
			type="yes_no",
			onYes= function()
				StrideServerModel:clearTypeAllHeroTemp()
			end,
		}
		Alert.show(info)
	end)
	
	--排序
	self.btn_change:addClickListener(function()
		ViewManager.open("StrideSetArrayView")
	end)
	
	local teamArr = StrideServerModel:getPVPEnum()
	StrideServerModel:setCurPVPModule(teamArr[1])
	self.list_team:addClickListener(function(idx)
        if (self.list_team:getSelectedIndex() + 1 ~= StrideServerModel:getCurPVPModule()) then
			StrideServerModel:setCurPVPModule(teamArr[self.list_team:getSelectedIndex() + 1])
            Dispatcher.dispatchEvent("battle_StrideChangeTeamType",teamArr[self.list_team:getSelectedIndex() + 1])
        end
    end)

end

function StrideBattleView:crossArena_hideTeam(_,hide)
	if hide then
		self.view:getController('c3'):setSelectedIndex(1)
	else
		self.view:getController('c3'):setSelectedIndex(0)
	end
end
function StrideBattleView:_initUI( )
	self:_initVM()
	self:_initListener()

end

return StrideBattleView