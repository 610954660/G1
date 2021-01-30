--Date :2020-12-01
--Author : wyz
--Desc : 月慑神殿 挑战记录界面

local MoonAweTempleRecordView,Super = class("MoonAweTempleRecordView", Window)

function MoonAweTempleRecordView:ctor()
	--LuaLog("MoonAweTempleRecordView ctor")
	self._packName = "MoonAweTemple"
	self._compName = "MoonAweTempleRecordView"
	self._rootDepth = LayerDepth.PopWindow
	self.godId 		= self._args.godId
end

function MoonAweTempleRecordView:_initEvent( )
	
end

function MoonAweTempleRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:MoonAweTemple.MoonAweTempleRecordView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_record = viewNode:getChildAutoType('list_record')--GList
	--{autoFieldsEnd}:MoonAweTemple.MoonAweTempleRecordView
	--Do not modify above code-------------
end

function MoonAweTempleRecordView:_initUI( )
	self:_initVM()
	MoonAweTempleModel.godId = self.godId
	MoonAweTempleModel:reqRecordInfo(self.godId)
end

function MoonAweTempleRecordView:MoonAweTempleRecordView_refresh()
	self:setRecord()
end

function MoonAweTempleRecordView:setRecord()
	local recordInfo = MoonAweTempleModel.curRecordInfo
	self.list_record:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local txt_playerName = obj:getChildAutoType("txt_playerName")
		local txt_power = obj:getChildAutoType("txt_power") 		-- 战力
		local txt_strongTimes = obj:getChildAutoType("txt_strongTimes") 	-- 挑战强化次数
		local txt_timer 	= obj:getChildAutoType("txt_timer") 	-- 挑战时间
		local list_hero 	= obj:getChildAutoType("list_hero") 	-- 阵容列表
		local btn_video 	= obj:getChildAutoType("btn_video") 	-- 播放按钮
		local data = recordInfo[index]
	
		txt_playerName:setText(string.format(Desc.MoonAweTemple_playerName,data.name))
		txt_power:setText(string.format(Desc.MoonAweTemple_power,StringUtil.transValue(data.combat)))
		txt_strongTimes:setText(string.format(Desc.MoonAweTemple_strongTimes,data.stage)) 
		txt_timer:setText(TimeLib.msToString(data.timeMs))

		list_hero:setItemRenderer(function(idx2,obj2) 
			local index2 = idx2 + 1
			local hero = data.heroList[index2]
			local heroCell2 = BindManager.bindHeroCell(obj2)
			heroCell2:setBaseData(hero)
		end)
		list_hero:setData(data.heroList)

		btn_video:removeClickListener(11)
		btn_video:addClickListener(function()
			ModelManager.BattleModel:requestBattleRecord(data.recordId)
		end,11) 
	end)  
	self.list_record:setData(recordInfo)
end  




return MoonAweTempleRecordView