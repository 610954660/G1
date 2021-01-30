--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersChampRecordView,Super = class("CrossLaddersChampRecordView", Window)

function CrossLaddersChampRecordView:ctor()
	--LuaLog("CrossLaddersChampRecordView ctor")
	self._packName = "CrossLaddersChamp"
	self._compName = "CrossLaddersChampRecordView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossLaddersChampRecordView:_initEvent( )
	
end

function CrossLaddersChampRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLaddersChamp.CrossLaddersChampRecordView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.haveDataCtrl = viewNode:getController('haveDataCtrl')--Controller
	self.list_record = viewNode:getChildAutoType('list_record')--GList
	self.noneData = viewNode:getChildAutoType('noneData')--GGroup
	--{autoFieldsEnd}:CrossLaddersChamp.CrossLaddersChampRecordView
	--Do not modify above code-------------
end

function CrossLaddersChampRecordView:_initListener( )
end

function CrossLaddersChampRecordView:_initUI( )
	self:_initVM()
	self:_initListener()
	CrossLaddersChampModel:reqSkyLadChampion_GetBattleRecordInfo(function() 
		self:setRecordList()
	end)
end

function CrossLaddersChampRecordView:timeFormat(time)
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

function CrossLaddersChampRecordView:setRecordList()
	local c_recordInfo 	= CrossLaddersChampModel.fightRecordInfo or {}
	local keys = {
		{key = "fightMs",asc=true}
	}
	TableUtil.sortByMap(c_recordInfo,keys)
	self.haveDataCtrl:setSelectedIndex(TableUtil.GetTableLen(c_recordInfo)>0 and 1 or 0)
	self.list_record:setItemRenderer(function(index, obj)
		index 	= index + 1
		local data 	= c_recordInfo[index]
		local integralCtrl 	= obj:getController("integralCtrl") -- 0下降 1上升
		local heroCell 	= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local recordBtn 	= obj:getChildAutoType("recordBtn")
		local txt_power 	= obj:getChildAutoType("txt_power")
		local txt_name 	= obj:getChildAutoType("txt_name")
		local txt_integral 	= obj:getChildAutoType("txt_integral")
		local txt_rounds 	= obj:getChildAutoType("txt_rounds")

		integralCtrl:setSelectedIndex(data.score > 0 and 1 or 0)
		heroCell:setHead(data.head, data.level, data.enemyId,nil,data.headBorder)
		txt_power:setText(string.format(Desc.CrossLaddersChamp_str9,StringUtil.transValue(data.combat or 0)))
		txt_name:setText(data.name or "")
		txt_integral:setText("+" .. data.score)
		txt_rounds:setText(string.format(Desc.CrossLaddersChamp_str11,data.ring or 1))

		local fightMs = math.floor(data.fightMs/1000)
		fightMs = ServerTimeModel:getServerTime() - fightMs
		recordBtn:getChildAutoType("title"):setText(self:timeFormat(fightMs))
		recordBtn:removeClickListener(11)
		recordBtn:addClickListener(function()
			CrossLaddersChampModel.isFigthtRecord = true
			ModelManager.BattleModel:requestBattleRecord(data.recordId)
		end,11)

		obj:getChildAutoType("heroCell"):removeClickListener(11)
		obj:getChildAutoType("heroCell"):addClickListener(function(context)
			context:stopPropagation()--阻止事件冒泡
			ViewManager.open("ViewPlayerView",{playerId = data.enemyId,serverId = data.serverId,arrayType = GameDef.BattleArrayType.SkyLadChampion })
		end,11)
	end)
	self.list_record:setData(c_recordInfo)

end




return CrossLaddersChampRecordView