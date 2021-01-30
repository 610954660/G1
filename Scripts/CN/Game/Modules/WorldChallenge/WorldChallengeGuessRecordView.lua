--Date :2020-12-27
--Author :added by wyang
--Desc : 世界擂台赛竞猜记录界面

local WorldChallengeGuessRecordView,Super = class("WorldChallengeGuessRecordView", Window)

function WorldChallengeGuessRecordView:ctor()
	--LuaLog("WorldChallengeGuessRecordView ctor")
	self._packName = "WorldChallenge"
	self._compName = "WorldChallengeGuessRecordView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function WorldChallengeGuessRecordView:_initEvent( )
	
end

function WorldChallengeGuessRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.WorldChallengeGuessRecordView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.dataCtrl = viewNode:getController('dataCtrl')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:StrideServer.WorldChallengeGuessRecordView
	--Do not modify above code-------------
end

function WorldChallengeGuessRecordView:_initListener( )
	
	--[[.WorldArena_GuessRecordBase {
		groupId             1:integer       #竞猜所在分组, 决赛阶段忽略
		stage               2:integer       #比赛阶段
		pos                 3:integer       #位置
		money               4:integer       #竞猜金币数量
		playerId            5:integer       #押注的玩家
		result              6:integer       #竞猜结果
		isRead              7:boolean       #是否已查看
	}--]]
	self.list:setItemRenderer(function(idx, obj)
		local index = idx + 1
        local data = self.list._dataTemplate[index]
		local record = data.record
		local playerInfo = data.playerInfo

        local txt_state = obj:getChildAutoType("txt_state")
        local txt_name1 = obj:getChildAutoType("txt_name1")
        local txt_name2 = obj:getChildAutoType("txt_name2")
        local txt_combat1 = obj:getChildAutoType("txt_combat1")
        local txt_combat2 = obj:getChildAutoType("txt_combat2")
        local heroCell1 = obj:getChildAutoType("heroCell1")
        local heroCell2 = obj:getChildAutoType("heroCell2")		
        local resultCtrl = obj:getController("resultCtrl")		
		
		local playerData1 = ModelManager.WorldChallengeModel.playerMap[playerInfo[1].playerId]
		local playerData2 = ModelManager.WorldChallengeModel.playerMap[playerInfo[2].playerId]
		local GuessBattlePlayerInfo1 = WorldChallengeModel.guessInfo.guessInfo.playerInfo[1]
		local GuessBattlePlayerInfo2 = WorldChallengeModel.guessInfo.guessInfo.playerInfo[2]
		--[[local combat1 = 0
		local combat2 = 0
		
		for _,v in pairs(GuessBattlePlayerInfo1.heroInfo) do
			combat1 = combat1 + v.combat
		end
		
		for _,v in pairs(GuessBattlePlayerInfo2.heroInfo) do
			combat2 = combat2+ v.combat
		end--]]
		
		
		local playerCell1 = BindManager.bindPlayerCell(heroCell1)
		local playerCell2 = BindManager.bindPlayerCell(heroCell2)
		playerCell1:setHead(playerData1.head, playerData1.level, playerData1.playerId,playerData1.name,playerData1.headBorder)
		playerCell2:setHead(playerData2.head, playerData2.level, playerData2.playerId,playerData2.name,playerData2.headBorder)
		playerCell1:setShowLv(false)
		playerCell2:setShowLv(false)
		playerCell1:setShowName(false)
		playerCell2:setShowName(false)
		
		txt_combat1:setText(StringUtil.transValue(playerData1.combat))
		txt_combat2:setText(StringUtil.transValue(playerData2.combat))
		local str = "[s.%s]%s"
		txt_name1:setText(string.format(str, playerData1.level, playerData1.name))
		txt_name2:setText(string.format(str, playerData2.level, playerData2.name))
		txt_state:setText(Desc["WorldChallenge_stage"..record.stage])

		resultCtrl:setSelectedIndex(data.record.result)
		
		local btn_record =  obj:getChildAutoType("btn_record")
		btn_record:removeClickListener(88)
		btn_record:addClickListener(function()
			if data.result ==0 then
				RollTips.show("尚未开奖")
				return
			end
			--ViewManager.open("StrideResultView",{recordIdList = data.recordIdList})	
			local has,recordId = WorldChallengeModel:getGuessingRecordId(record)
			if recordId then
				ModelManager.BattleModel:requestBattleRecord(recordId)
			end

		end,88)

	end)
end

function WorldChallengeGuessRecordView:_initUI( )
	self:_initVM()
	self:_initListener()
    --StrideServerModel:reqGetGuessRecord( )
	printTable(69, WorldChallengeModel.guessInfo)
	local data = WorldChallengeModel.guessInfo.recordList or {}
	if data then
		self:updatePanel(data)
	end
end


function WorldChallengeGuessRecordView:updatePanel( listData )
	
	
	--[[local listData = data.infoList
	table.sort(listData,function(a,b) 
		return a.time>b.time
	end)--]]
	self.list:setData(listData)
	if #listData >0 then
		self.dataCtrl:setSelectedIndex(0)
	else
		self.dataCtrl:setSelectedIndex(1)
	end
end



return WorldChallengeGuessRecordView
