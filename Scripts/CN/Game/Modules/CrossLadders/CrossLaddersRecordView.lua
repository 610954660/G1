--Date :2020-12-30
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersRecordView,Super = class("CrossLaddersRecordView", Window)

function CrossLaddersRecordView:ctor()
	--LuaLog("CrossLaddersRecordView ctor")
	self._packName = "CrossLadders"
	self._compName = "CrossLaddersRecordView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossLaddersRecordView:_initEvent( )
	
end

function CrossLaddersRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLadders.CrossLaddersRecordView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.haveDataCtrl = viewNode:getController('haveDataCtrl')--Controller
	self.list_record = viewNode:getChildAutoType('list_record')--GList
	self.noneData = viewNode:getChildAutoType('noneData')--GGroup
	--{autoFieldsEnd}:CrossLadders.CrossLaddersRecordView
	--Do not modify above code-------------
end

function CrossLaddersRecordView:_initListener( )
	
end

function CrossLaddersRecordView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:CrossLaddersRecordView_refreshPanel()
	CrossLaddersModel:reqSkyLadder_GetBattleRecordInfo()
end

function CrossLaddersRecordView:CrossLaddersRecordView_refreshPanel()
	self:refreshPanel()
end

function CrossLaddersRecordView:timeFormat(time)
	local str = ""
	if time < 3600 then
		str = string.format(Desc.CrossLadders_str8,math.floor(time/60))
	elseif (time >=3600) and (time < 86400) then
		str = string.format(Desc.CrossLadders_str9,math.floor(time/3600))
	else
		str = string.format(Desc.CrossLadders_str10,math.floor(time/86400))
	end
	return str
end

function CrossLaddersRecordView:refreshPanel()
	local recordInfo = CrossLaddersModel.recordInfo or {}
	self.haveDataCtrl:setSelectedIndex(TableUtil.GetTableLen(recordInfo)>0 and 1 or 0)
	TableUtil.sortByMap(recordInfo,{{key="fightMs",asc=true}})
	self.list_record:setVirtual()
	self.list_record:setItemRenderer(function(index, obj)
		index = index +1
		local data = recordInfo[index]
		local heroCell 	= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local txt_power = obj:getChildAutoType("txt_power")
		local txt_rank 	= obj:getChildAutoType("txt_rank")
		local txt_name 	= obj:getChildAutoType("txt_name")
		local cosumBtn 	= obj:getChildAutoType("cosumBtn")
		local recordBtn = obj:getChildAutoType("recordBtn")
		local canFight 	= obj:getController("canFight") -- 0能复仇 1不能复仇
		local rankCtrl 	= obj:getController("rankCtrl") -- 0排名上升 1排名下降
		local txt_upnum = obj:getChildAutoType("txt_upnum")
		local titleTime = recordBtn:getChildAutoType("title")

		if data then
			local fightMs = math.floor(data.fightMs/1000)
			fightMs = ServerTimeModel:getServerTime() - fightMs
			titleTime:setText(self:timeFormat(fightMs))

			local curRankNum = data.oldRank - data.newRank
			rankCtrl:setSelectedIndex(curRankNum>=0 and 0 or 1)
			canFight:setSelectedIndex(data.isAttack and 1 or 0)
			txt_upnum:setText(math.abs(curRankNum))
			txt_name:setText(data.name or "")
			txt_rank:setText(string.format(Desc.CrossLadders_str11,data.newRank))
			txt_power:setText(string.format(Desc.CrossLadders_power,StringUtil.transValue(data.combat or 0)))
			heroCell:setHead(data.head, data.level, data.enemyId,nil,data.headBorder)

			obj:getChildAutoType("heroCell"):removeClickListener(11)
			obj:getChildAutoType("heroCell"):addClickListener(function(context)
				context:stopPropagation()--阻止事件冒泡
				ViewManager.open("ViewPlayerView",{
					playerId  = data.enemyId,
					serverId  = data.serverId,
					arrayType = GameDef.BattleArrayType.SkyLadderDef,
					})
			end,11)

			recordBtn:removeClickListener()
			recordBtn:addClickListener(function(context) 
				context:stopPropagation()--阻止事件冒泡
				ModelManager.BattleModel:requestBattleRecord(data.recordId)
			end)
			cosumBtn:removeClickListener()
			cosumBtn:addClickListener(function(context) 
				context:stopPropagation()--阻止事件冒泡
			
			end)
		end
	end)
	self.list_record:setData(recordInfo)
end




return CrossLaddersRecordView