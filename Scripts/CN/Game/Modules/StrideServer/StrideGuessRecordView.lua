--Date :2020-12-27
--Author :added by xhd
--Desc : 巅峰竞猜记录界面

local StrideGuessRecordView,Super = class("StrideGuessRecordView", Window)

function StrideGuessRecordView:ctor()
	--LuaLog("StrideGuessRecordView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideGuessRecordView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function StrideGuessRecordView:_initEvent( )
	
end

function StrideGuessRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideGuessRecordView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.dataCtrl = viewNode:getController('dataCtrl')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:StrideServer.StrideGuessRecordView
	--Do not modify above code-------------
end

function StrideGuessRecordView:_initListener( )
	
	-- self.blackBg:addClickListener(function()

	-- end)

	self.list:setItemRenderer(function(idx, obj)
		local index = idx + 1
        local data = self.list._dataTemplate[index]
		local gametxt1 = obj:getChildAutoType("gametxt1")
		local ganetxt2 = obj:getChildAutoType("ganetxt2")
		local daytime = obj:getChildAutoType("daytime")
		local resultCtrl = obj:getController("resultCtrl")

        local leftCell = obj:getChildAutoType("leftCell")
        local txt_name1 = obj:getChildAutoType("txt_name1")

		local rightCell = obj:getChildAutoType("rightCell")
        local txt_name2 = obj:getChildAutoType("txt_name2")

		daytime:setText(TimeLib.msToString( data.time, "%Y-%m-%d" ))
		resultCtrl:setSelectedIndex(data.result)
		local str1,str2 = StrideServerModel:getBigStageStr( data.bigStage,data.battleStage )
		gametxt1:setText(str1)
		ganetxt2:setText(str2)
		-- if str2=="" then
		-- 	gametxt1:setPosition(377,86)
		-- else
		-- 	gametxt1:setPosition(347,86)
		-- end
		local leftCellScript = BindManager.bindPlayerCell(leftCell)
		local leftPlayData = data.playerInfo[1]
		leftCellScript:setHead(leftPlayData.head, leftPlayData.level, leftPlayData.playerId, leftPlayData.name, leftPlayData.headBorder)
		local rightCellScript = BindManager.bindPlayerCell(rightCell)
		local rightPlayData = data.playerInfo[2]
		rightCellScript:setHead(rightPlayData.head, rightPlayData.level, rightPlayData.playerId, rightPlayData.name, rightPlayData.headBorder)
		
		txt_name1:setText(leftPlayData.name)
		txt_name2:setText(rightPlayData.name)	
		
		local num =  obj:getChildAutoType("num")
		local recordBtn =  obj:getChildAutoType("recordBtn")
		local showCtrl = obj:getController("showCtrl")
		
		if data.winPlayerId == leftPlayData.playerId then
			showCtrl:setSelectedIndex(0)
		else
			showCtrl:setSelectedIndex(1)
		end
		num:setText(data.score) 
		recordBtn:removeClickListener(88)
		recordBtn:addClickListener(function()
			if data.result ==0 then
				RollTips.show("尚未开奖")
				return
			end
			-- local info = {
			-- 	recordId     = data.recordIdList[index],
			-- 	gamePlayType = GameDef.GamePlayType.TopArena
			-- }
			-- BattleModel:requestBattleRecord(info.recordId,nil,info.gamePlayType)
			ViewManager.open("StrideResultView",{recordIdList = data.recordIdList})			

		end,88)

	end)
end

function StrideGuessRecordView:_initUI( )
	self:_initVM()
	self:_initListener()
    StrideServerModel:reqGetGuessRecord( )
end

function  StrideGuessRecordView:update_stride_guessRecord( _,params )
	-- printTable(1,params.data)
	self:updatePanel(params.data)
end

function StrideGuessRecordView:updatePanel( data )
	local listData = data.infoList
	table.sort(listData,function(a,b) 
		return a.time>b.time
	end)
	self.list:setData(listData)
	if #data.infoList>0 then
		self.dataCtrl:setSelectedIndex(0)
	else
		self.dataCtrl:setSelectedIndex(1)
	end
end



return StrideGuessRecordView
