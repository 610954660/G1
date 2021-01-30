local CrossArenaPVPBattleView,Super = class("CrossArenaPVPBattleView", Window)

function CrossArenaPVPBattleView:ctor()
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenaPVPBattleView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossArenaPVPBattleView:_initEvent()
	
end

function CrossArenaPVPBattleView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossArenaPVP.CrossArenaPVPBattleView
	self.btn_change = viewNode:getChildAutoType('btn_change')--GButton
	self.c1 = viewNode:getController('c1')--Controller
	self.c2 = viewNode:getController('c2')--Controller
	self.c3 = viewNode:getController('c3')--Controller
	self.list_team = viewNode:getChildAutoType('list_team')--GList
	--{autoFieldsEnd}:CrossArenaPVP.CrossArenaPVPBattleView
	--Do not modify above code-------------
end

function CrossArenaPVPBattleView:_initUI()
	self:_initVM()


	self.btn_change:addClickListener(function()
		ViewManager.open("CrossPVPSetArrayView",{model = CrossArenaPVPModel})
	end)

	local teamArr = CrossArenaPVPModel:getPVPEnum()
	CrossArenaPVPModel:setCurPVPModule(teamArr[1])
	self.list_team:addClickListener(function(idx)
		local index = self.list_team:getSelectedIndex()
        if (index + 1 ~= CrossArenaPVPModel:getCurPVPModule()) then
			CrossArenaPVPModel:setCurPVPModule(teamArr[index + 1])
            Dispatcher.dispatchEvent("battle_CrossChangeTeamType",teamArr[index + 1])
        end
	end)
	local hideNum = CrossArenaPVPModel:getCanHideNum() 
	local curHideNum = 0
	local lastClick = false
	local s_ctr = {}
	local hideData = {}
	CrossArenaPVPModel.changeTeamHide = {}
	if CrossArenaPVPModel:getCurPVPType() == 1 and self._args.mapConfig.configType == GameDef.BattleArrayType.CrossArenaDefOne then
		for index,value in pairs(self.list_team:getChildren()) do
			local obj = value
			local ctr = obj:getController("ishide")
			local data = CrossArenaPVPModel:getTypeHeroTempInfo()[teamArr[index]]
			s_ctr[data.arrayType] = ctr
			hideData[data.arrayType] = data
			ctr:setSelectedIndex(data.isHide and 1 or 0)
			if data.isHide then
				curHideNum = curHideNum + 1 
			end
			CrossArenaPVPModel.changeTeamHide[data.arrayType] = data.isHide
			obj:getChild("hideBtn"):addClickListener(function()
				
				ctr:setSelectedIndex(ctr:getSelectedIndex() == 0 and 1 or 0)
				local state = ctr:getSelectedIndex() == 1 and true or false
				CrossArenaPVPModel.changeTeamHide[data.arrayType] = state
				if state then 
					curHideNum = curHideNum + 1
				else
					curHideNum = curHideNum - 1
				end
				if hideNum == 1 then
					for k,v in pairs(s_ctr) do 
						if v ~= ctr then
							v:setSelectedIndex(0)
							CrossArenaPVPModel.changeTeamHide[k] = false
						end
					end
				elseif hideNum == 2 and curHideNum > 2 then
					for k,v in pairs(s_ctr) do 
						if v ~= ctr and (lastClick == v or lastClick == false)then
							v:setSelectedIndex(0)
							curHideNum = curHideNum -1 
							CrossArenaPVPModel.changeTeamHide[k] = false
							break
						end
					end
				end
				lastClick = ctr
			end,99)
		end
	end

	local children = self.list_team:getChildren();
	local team = CrossArenaPVPModel:getPVPEnum()
	for idx, obj in ipairs(children) do
		local key = "CrossArena_teamEmpty"..CrossArenaPVPModel.curPVPType..team[idx]
        RedManager.register(key, obj:getChildAutoType("img_red"));
	end
	CrossArenaPVPModel:checkTeamHasEmpty()
	self:_refreshView()
end


function CrossArenaPVPBattleView:_refreshView()

end

function CrossArenaPVPBattleView:crossArena_hideTeam(_,hide)
	if hide then
		self.view:getController('c3'):setSelectedIndex(1)
	else
		self.view:getController('c3'):setSelectedIndex(0)
	end
end

function CrossArenaPVPBattleView:_exit()

end

return CrossArenaPVPBattleView