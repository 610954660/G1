--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技 战斗记录（外面一层）

local CrossTeamPVPRecordOutView,Super = class("CrossTeamPVPRecordOutView", Window)

function CrossTeamPVPRecordOutView:ctor()
	--LuaLog("CrossTeamPVPRecordOutView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPRecordOutView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossTeamPVPRecordOutView:_initEvent( )
	
end

function CrossTeamPVPRecordOutView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPRecordOutView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_record = viewNode:getChildAutoType('list_record')--GList
	self.recordCtrl = viewNode:getController('recordCtrl')--Controller
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPRecordOutView
	--Do not modify above code-------------
end

function CrossTeamPVPRecordOutView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel:reqGetRecordInfos()
	-- self:CrossTeamPVPRecordOutView_refreshPanel()
end

function CrossTeamPVPRecordOutView:CrossTeamPVPRecordOutView_refreshPanel()
	self:refreshPanel()
end

function CrossTeamPVPRecordOutView:refreshPanel()
	local recordsInfo = CrossTeamPVPModel.records or {}
	self.recordCtrl:setSelectedIndex(TableUtil.GetTableLen(recordsInfo) >0 and 0 or 1)
	self.list_record:setVirtual()
	self.list_record:setItemRenderer(function(idx,obj) 
		local index 	= idx + 1
		local checkWin	= obj:getController("checkWin") -- 0赢了 1输了
		local data  	= recordsInfo[index]
		local attacker 	= data.left
		local defender 	= data.right
		local txt_fightMs = obj:getChildAutoType("txt_fightMs")
		txt_fightMs:setText(TimeLib.msToString(data.fightMs))

		local txt_myTeam 	= obj:getChildAutoType("txt_myTeam")
		local txt_otherTeam = obj:getChildAutoType("txt_otherTeam")
		local list_myTeam 	= obj:getChildAutoType("list_myTeam")
		local list_otherTeam = obj:getChildAutoType("list_otherTeam")
		local txt_myTotalPower 		= obj:getChildAutoType("txt_myTotalPower")
		local txt_otherTotalPower 	= obj:getChildAutoType("txt_otherTotalPower")
		local btn_data 		= obj:getChildAutoType("btn_data")
		local txt_myIntegral= obj:getChildAutoType("txt_myIntegral")
		local txt_myRank	= obj:getChildAutoType("txt_myRank")
		local txt_myIntegralNew = obj:getChildAutoType("txt_myIntegralNew")
		local txt_myRankNew	= obj:getChildAutoType("txt_myRankNew")
		
		checkWin:setSelectedIndex(attacker.isWin and 0 or 1)
		-- txt_myTeam:setText(string.format(Desc.CrossTeamPVP_teamTitle,attacker.name))
		txt_myTeam:setText(Desc.CrossTeamPVP_myTeamTitle)
		txt_otherTeam:setText(Desc.CrossTeamPVP_otherTeamTitle)
		-- txt_otherTeam:setText(string.format(Desc.CrossTeamPVP_teamTitle,defender.name))
		list_myTeam:setItemRenderer(function(idx2,obj2)
			local index2 	= idx2 + 1
			local data2 	= attacker.members[index2]
			local heroCell 	= BindManager.bindPlayerCell(obj2)
			heroCell:setHead(data2.head,data2.level,data2.playerId) 
			obj2:removeClickListener()
			obj2:addClickListener(function(context)
				context:stopPropagation()--阻止事件冒泡
				if data2.playerId<0 then
					RollTips.show(Desc.Friend_cant_show)
					return
				end
				ViewManager.open("ViewPlayerView",{playerId = data2.playerId,serverId = data2.serverId,arrayType = GameDef.BattleArrayType.WorldTeamArena})
			end)
		end)
		list_myTeam:setData(attacker.members)

		list_otherTeam:setItemRenderer(function(idx2,obj2)
			local index2 	= idx2 + 1
			local data2 	= defender.members[index2]
			local heroCell 	= BindManager.bindPlayerCell(obj2)
			heroCell:setHead(data2.head,data2.level,data2.playerId,nil,data.headBorder) 
			obj2:removeClickListener()
			obj2:addClickListener(function(context)
				context:stopPropagation()--阻止事件冒泡
				if data2.playerId<0 then
					RollTips.show(Desc.Friend_cant_show)
					return
				end
				ViewManager.open("ViewPlayerView",{playerId = data2.playerId,serverId = data2.serverId,arrayType = GameDef.BattleArrayType.WorldTeamArena})
			end)
		end)
		list_otherTeam:setData(defender.members)

		txt_myTotalPower:setText(string.format(Desc.CrossTeamPVP_totalPower,StringUtil.transValue(attacker.totalFight)))
		txt_otherTotalPower:setText(string.format(Desc.CrossTeamPVP_totalPower,StringUtil.transValue(defender.totalFight)))
		txt_myIntegral:setText(string.format(Desc.CrossTeamPVP_myIntegral1,data.myScore))
		txt_myIntegralNew:setText(math.abs(data.myAddScore)..")")
		txt_myRank:setText(string.format(Desc.CrossTeamPVP_myRank1,data.myRank))
		txt_myRankNew:setText(math.abs(data.myAddRank)..")")

		btn_data:removeClickListener()
		btn_data:addClickListener(function()
			ViewManager.open("CrossTeamPVPRecordInView",{data = data})  
		end)
	end)
	self.list_record:setData(recordsInfo)

end




return CrossTeamPVPRecordOutView