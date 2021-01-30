--Date :2020-12-01
--Author : wyz
--Desc : 月慑神殿 主界面


local MoonAweTempleView,Super = class("MoonAweTempleView", Window)

function MoonAweTempleView:ctor()
	--LuaLog("MoonAweTempleView ctor")
	self._packName = "MoonAweTemple"
	self._compName = "MoonAweTempleView"
	--self._rootDepth = LayerDepth.Window
	
end

function MoonAweTempleView:_initEvent( )
	
end

function MoonAweTempleView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:MoonAweTemple.MoonAweTempleView
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.godItem_1 = viewNode:getChildAutoType('godItem_1')--godItem
		self.godItem_1.CrownTitleCell = viewNode:getChildAutoType('godItem_1/CrownTitleCell')--GComponent
		self.godItem_1.loaderBottom = viewNode:getChildAutoType('godItem_1/loaderBottom')--GLoader
		self.godItem_1.modelNode = viewNode:getChildAutoType('godItem_1/modelNode')--GComponent
		self.godItem_1.txt_name = viewNode:getChildAutoType('godItem_1/txt_name')--GTextField
		self.godItem_1.txt_nobody = viewNode:getChildAutoType('godItem_1/txt_nobody')--GTextField
		self.godItem_1.txt_title = viewNode:getChildAutoType('godItem_1/txt_title')--GTextField
	self.godItem_2 = viewNode:getChildAutoType('godItem_2')--godItem
		self.godItem_2.CrownTitleCell = viewNode:getChildAutoType('godItem_2/CrownTitleCell')--GComponent
		self.godItem_2.loaderBottom = viewNode:getChildAutoType('godItem_2/loaderBottom')--GLoader
		self.godItem_2.modelNode = viewNode:getChildAutoType('godItem_2/modelNode')--GComponent
		self.godItem_2.txt_name = viewNode:getChildAutoType('godItem_2/txt_name')--GTextField
		self.godItem_2.txt_nobody = viewNode:getChildAutoType('godItem_2/txt_nobody')--GTextField
		self.godItem_2.txt_title = viewNode:getChildAutoType('godItem_2/txt_title')--GTextField
	self.godItem_3 = viewNode:getChildAutoType('godItem_3')--godItem
		self.godItem_3.CrownTitleCell = viewNode:getChildAutoType('godItem_3/CrownTitleCell')--GComponent
		self.godItem_3.loaderBottom = viewNode:getChildAutoType('godItem_3/loaderBottom')--GLoader
		self.godItem_3.modelNode = viewNode:getChildAutoType('godItem_3/modelNode')--GComponent
		self.godItem_3.txt_name = viewNode:getChildAutoType('godItem_3/txt_name')--GTextField
		self.godItem_3.txt_nobody = viewNode:getChildAutoType('godItem_3/txt_nobody')--GTextField
		self.godItem_3.txt_title = viewNode:getChildAutoType('godItem_3/txt_title')--GTextField
	self.godItem_4 = viewNode:getChildAutoType('godItem_4')--godItem
		self.godItem_4.CrownTitleCell = viewNode:getChildAutoType('godItem_4/CrownTitleCell')--GComponent
		self.godItem_4.loaderBottom = viewNode:getChildAutoType('godItem_4/loaderBottom')--GLoader
		self.godItem_4.modelNode = viewNode:getChildAutoType('godItem_4/modelNode')--GComponent
		self.godItem_4.txt_name = viewNode:getChildAutoType('godItem_4/txt_name')--GTextField
		self.godItem_4.txt_nobody = viewNode:getChildAutoType('godItem_4/txt_nobody')--GTextField
		self.godItem_4.txt_title = viewNode:getChildAutoType('godItem_4/txt_title')--GTextField
	self.godItem_5 = viewNode:getChildAutoType('godItem_5')--godItem
		self.godItem_5.CrownTitleCell = viewNode:getChildAutoType('godItem_5/CrownTitleCell')--GComponent
		self.godItem_5.loaderBottom = viewNode:getChildAutoType('godItem_5/loaderBottom')--GLoader
		self.godItem_5.modelNode = viewNode:getChildAutoType('godItem_5/modelNode')--GComponent
		self.godItem_5.txt_name = viewNode:getChildAutoType('godItem_5/txt_name')--GTextField
		self.godItem_5.txt_nobody = viewNode:getChildAutoType('godItem_5/txt_nobody')--GTextField
		self.godItem_5.txt_title = viewNode:getChildAutoType('godItem_5/txt_title')--GTextField
	self.godItem_6 = viewNode:getChildAutoType('godItem_6')--godItem
		self.godItem_6.CrownTitleCell = viewNode:getChildAutoType('godItem_6/CrownTitleCell')--GComponent
		self.godItem_6.loaderBottom = viewNode:getChildAutoType('godItem_6/loaderBottom')--GLoader
		self.godItem_6.modelNode = viewNode:getChildAutoType('godItem_6/modelNode')--GComponent
		self.godItem_6.txt_name = viewNode:getChildAutoType('godItem_6/txt_name')--GTextField
		self.godItem_6.txt_nobody = viewNode:getChildAutoType('godItem_6/txt_nobody')--GTextField
		self.godItem_6.txt_title = viewNode:getChildAutoType('godItem_6/txt_title')--GTextField
	self.list_condition = viewNode:getChildAutoType('list_condition')--GList
	self.txt_challengeTitle = viewNode:getChildAutoType('txt_challengeTitle')--GTextField
	--{autoFieldsEnd}:MoonAweTemple.MoonAweTempleView
	--Do not modify above code-------------
end

function MoonAweTempleView:_initUI( )
	self:_initVM()
	-- self:MoonAweTempleView_refreshPanal()
	self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
		local info={}
		info['title']=Desc["help_StrTitle"..ModuleId.MoonAweTemple.id]
		info['desc']=Desc["help_StrDesc"..ModuleId.MoonAweTemple.id]
		ViewManager.open("GetPublicHelpView",info) 
    end)

	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("MoonAweTempleView_isShow"..dayStr, true)
	MoonAweTempleModel:updateRed()
	MoonAweTempleModel:reqStarTempleInfo()
end

-- 接收刷新面板事件
function MoonAweTempleView:MoonAweTempleView_refreshPanal()
	self:refreshPanal()
end

-- 刷新面板数据
function MoonAweTempleView:refreshPanal()
	self:setGodItem()
	self:setCondition()
end

-- 设置神位数据
function MoonAweTempleView:setGodItem()
	local allGodData = MoonAweTempleModel.allGodData
	local godInfo 	= DynamicConfigData.t_MoonTempleBasic
	local crownInfo =  DynamicConfigData.t_CrownTitle 	-- 称号信息
	for i= 1,#godInfo do
		local item = self.view:getChildAutoType("godItem_" .. i)
		local loaderBottom = item:getChildAutoType("loaderBottom")
		local loaderTop = item:getChildAutoType("loaderTop")
		local modelNode = item:getChildAutoType("modelNode")
		local txt_name 	= item:getChildAutoType("txt_name") 	-- 玩家名字
		local txt_title = item:getChildAutoType("txt_title") 	-- 称号
		local godTypeCtrl = item:getController("godType") 
		local checkBody = item:getController("checkBody")
		local CrownTitleCell = BindManager.bindCrownTitleCell(item:getChildAutoType("CrownTitleCell"))
		local data = allGodData[i]
		local cfgData = godInfo[i]

		CrownTitleCell:setData(cfgData.crownId)
		if i == 1 then
			godTypeCtrl:setSelectedIndex(1)
		elseif i>1 and i <= 3 then
			godTypeCtrl:setSelectedIndex(2)
		else
			godTypeCtrl:setSelectedIndex(3)
		end

		txt_title:setText(cfgData.name)

		if modelNode then
			modelNode:displayObject():removeAllChildren()
		end
		
		local skeletonNode
		if data and data.playerId ~= 0  then
			checkBody:setSelectedIndex(0)
			txt_name:setText(data.name)
			skeletonNode = SpineUtil.createModel(modelNode, {x = 0, y =0}, "stand", data.heroOpertion,true,nil, data.fashionCode)
		else
			checkBody:setSelectedIndex(1)
			txt_name:setText(Desc.MoonAweTemple_nobody)
			skeletonNode = SpineUtil.createModel(modelNode, {x = 0, y =0}, "stand", cfgData.modelId,true)
		end
		--if i == 1 then
			local temp= skeletonNode:findBone("hanging_point")
			local pos = {x=temp:getWorldX(),y=-temp:getWorldY()}
			local globalPos = modelNode:localToGlobal(pos)
			local hpPos= item:globalToLocal(globalPos)
			CrownTitleCell:setPosition(hpPos.x ,hpPos.y)
		--end
		
		item:removeClickListener(111)
		item:addClickListener(function() 
			ViewManager.open("MoonAweTempleChallengeView",{godId = i,crownId = cfgData.crownId})
		end,111)
	end
end

-- 设置挑战条件
function MoonAweTempleView:setCondition()
	self.txt_challengeTitle:setText(Desc.MoonAweTemple_challengeTitle)
	local godInfo 		= DynamicConfigData.t_MoonTempleBasic
	local crownInfo 	= DynamicConfigData.t_CrownTitle 		-- 称号信息
	local conditionCfg 	= DynamicConfigData.t_CrownCfg 
	local crownIdInfo 	= {}

	for k,v in pairs(conditionCfg) do
		local data = {}
		data.crownId = k
		if v.lowestRank then
			data.lowestRank 	= v.lowestRank
			data.highestRank 	= v.highestRank
			data.id  			= v.id
		else
			data.lowestRank 	= v[1].lowestRank
			data.highestRank 	= v[1].highestRank
			data.id  			= v[1].id
		end
		table.insert(crownIdInfo,data)
	end
	local keys ={
		{key = "crownId",asc = false},
	}
	TableUtil.sortByMap(crownIdInfo,keys)

	self.list_condition:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local crownId 		= crownIdInfo[index].crownId
		local lowestRank 	= crownIdInfo[index].lowestRank
		local highestRank 	= crownIdInfo[index].highestRank
		local godId  		= crownIdInfo[index].id
		local data 		= godInfo[godId]

		local txt_title = obj:getChildAutoType("txt_title")
		txt_title:setText(string.format(Desc.MoonAweTemple_crownName,data.name,lowestRank))
	end)  
	self.list_condition:setData(crownIdInfo)

end




return MoonAweTempleView