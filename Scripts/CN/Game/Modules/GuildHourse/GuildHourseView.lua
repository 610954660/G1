--Date :2020-12-09
--Author : added by xhd
--Desc : 公会金库

local GuildHourseView,Super = class("GuildHourseView", Window)
local PackConfiger = require "Game.ConfigReaders.PackConfiger"
local lastInterTime = 0.02
local maxInterTime = 0.5
function GuildHourseView:ctor()
	--LuaLog("GuildHourseView ctor")
	self._packName = "GuildHourse"
	self._compName = "GuildHourseView"
	--self._rootDepth = LayerDepth.Window
	self.listData1 = false
	self.listData2 = false
	self.listData3 = false
	self.listData4 = false

	self.listBagData1 = false
	self.listBagData2 = false
	self.listBagData3 = false
	self.listBagData4 = false

	self.packInfoList = false  --背包信息
	self.recordListData = false  --记录列表
	self.dayAddItemTimes = false --今天放入背包次数
	self.scheduler 		= {}
	self.useNum = 1
	self._itemData = false --选中的道具
	-- self.__timerIdArr = {}
	self.showMoneyType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.GuildPackScore},
	}
	self.aniFlagArr = {false,false,false,false}
end

function GuildHourseView:tidyTextShow( data )
	local str = ""
	str  = data.name or Desc.activity_txt43
	if data.opType == GameDef.GuildPackOpType.playerAdd then
		str  = string.format( "[color=#3ab7ff]%s[/color][color=#ffffff]%s[/color]",str,Desc.activity_txt44)
	elseif data.opType == GameDef.GuildPackOpType.SysAdd then
		str  = string.format( "[color=#3ab7ff]%s[/color][color=#ffffff]%s[/color]",str,Desc.activity_txt45)
	elseif data.opType == GameDef.GuildPackOpType.Remove then
		str  = string.format( "[color=#3ab7ff]%s[/color][color=#ffffff]%s[/color]",str,Desc.activity_txt46)
	elseif data.opType == GameDef.GuildPackOpType.TimeOut then
		str  =  string.format( "[color=#3ab7ff]%s[/color][color=#ffffff]%s[/color]",str,Desc.activity_txt47)
	end
	local str2 = ""
	print(1,"数据数量：",#data.items)
	for i,v in ipairs(data.items) do
		local color = ItemConfiger.getQualityByCode(data.items[i].code)
		local colorStr = ColorUtil.getItemTipsColorStr(color)
		local itemName = ItemConfiger.getItemNameByCode(data.items[i].code)
		str2 = string.format( "%s[color=%s]%s%s%d%s",str2,colorStr,itemName,"*",data.items[i].amount,"[/color]<br>")
	end
	return str,str2
end

function GuildHourseView:showRecordList( ... )
	TableUtil.sortBy(self.recordListData, "timeMs", false)
	-- printTable(1,self.recordListData)
	local showData = {}
	for i,v in ipairs(self.recordListData) do
		if #showData>=10 then
			break
		end
		table.insert(showData,self.recordListData[i])
	end
	self.recordList:setData(showData)
end

--列表显示
function GuildHourseView:itemShow( obj,index,type)
	obj:setVisible(true)
	local showData  = self["listData"..type][index+1]
	if not showData then
		return
	end
	local code = showData.code
	-- printTable(1,showData)
	if not DynamicConfigData.t_GuildTreasuryConfig[code] then
		print(1,"道具code不存在配置表")
		return
	end
	local basicPointsOut  = DynamicConfigData.t_GuildTreasuryConfig[code].basicPointsOut
	-- PlayerModel:getMoneyByType(GameDef.MoneyType.GuildPackScore) 
	local costRes = {type=GameDef.ItemType.Money,code= GameDef.MoneyType.GuildPackScore,amount= basicPointsOut,}
    showData.costRes = costRes
	local basicCopies = DynamicConfigData.t_GuildTreasuryConfig[code].basicCopies
	showData.getRes = {code=code,amount=basicCopies}
	local allAmount = showData.amount
	local buyTime = math.floor(allAmount/basicCopies)
	showData.buyTime = buyTime
	showData.packType = type

    --消耗显示
	if showData and costRes then
		local costItem  = BindManager.bindCostItem(obj:getChildAutoType("costItem"))
		costItem:setNoTips(true)
		costItem:setGreenColor("#3BFE44")
		costItem:setRedColor("#ff3b3b")
		costItem:setData(costRes.type, costRes.code, costRes.amount,true)
	end
   
	--库存
	local txt_limitType = obj:getChildAutoType("txt_limitType")
	txt_limitType:setText(string.format("库存:%d",showData.amount))
	
	--动画
	local interTime = maxInterTime/#self["listData"..type]
    if interTime >= lastInterTime then
    	interTime = lastInterTime
	end
	print(1,self["list"..type]:getFirstChildInView())
	if not self.aniFlagArr[type] then
		obj:setVisible(false)
		local tempIndex = index+1-self["list"..type]:getFirstChildInView()
		self.scheduler[tempIndex] = Scheduler.scheduleOnce(tempIndex*interTime, function( ... )
			if obj and  (not tolua.isnull(obj)) then
				obj:setVisible(true)
				obj:getTransition("t0"):play(function( ... )
				end);
			end
		end)
	end


    --名称显示
	local name = obj:getChildAutoType("txt_times")
	local item = DynamicConfigData.t_item[code]
	name:setText(ItemConfiger.getItemNameByCode(code))
	if item.color == 1 then
		name:setColor(cc.c3b(69,69,69))
	else
		name:setColor(ColorUtil.getItemColor(item.color))
	end
	
	--道具显示
	local itemCell =  BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
	itemCell:setData(code)

	--名字是新手引导查找商品用的，别删
	obj:setName(showData.id)
	
	obj:removeClickListener(33)--池子里面原来的事件注销掉
	obj:addClickListener(function(context)
		self:itemClick(index,obj,type)
	end,33)
	
	
	local  lastTime = obj:getChildAutoType("lastTime")
	-- local tempIndex = self["list"..type]:itemIndexToChildIndex(index+1)
	local tempIndex = index + 1
	if obj.timer then
		-- print(1,"销毁tempIndex位置定时器",tempIndex)
		TimeLib.clearCountDown(obj.timer)
		obj.timer = false
	end
	local timems = showData.expireMS - ServerTimeModel:getServerTimeMS()
	if timems>0 then
		timems = timems/1000
	end
	local function updateCountdownView(time)
		if tolua.isnull(self.view) then return end
		-- print(1,"updateCountdownView 计时位置",tempIndex)
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			lastTime:setText(timeStr)
		else
			obj:removeClickListener(33)--池子里面原来的事件注销掉
			lastTime:setText("已过期")
		end
	end
	updateCountdownView(timems)
	-- print(1,"新建tempIndex位置定时器",tempIndex)
	-- self.__timerIdArr[tempIndex] = TimeLib.newCountDown(timems, function(time)
	obj.timer = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		if tolua.isnull(obj) then
			return
		end
		obj:removeClickListener(33)--池子里面原来的事件注销掉
		lastTime:setText("已过期")
	end, false, false, false)

end

--库存点击
function GuildHourseView:itemClick(index,obj,type)
	local showData  = self["listData"..type][index+1]
	ViewManager.open("GuildBuyTipsView", {showData = showData})
end

function GuildHourseView:_initEvent( )
	self.list1:setVirtual()
	self.list2:setVirtual()
	self.list3:setVirtual()
	self.list4:setVirtual()
	self.list1:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[1] = true
	end)
	self.list1:setItemRenderer(function (index,obj)
		self:itemShow(obj,index,1)
	end
	)
	self.list2:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[2] = true
	end)
	self.list2:setItemRenderer(function (index,obj)
		self:itemShow(obj,index,2)
	end
	)
	self.list3:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[3] = true
	end)
	self.list3:setItemRenderer(function (index,obj)
		self:itemShow(obj,index,3)
	end
	)
	self.list4:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[4] = true
	end)
	self.list4:setItemRenderer(function (index,obj)
		self:itemShow(obj,index,4)
	end
	)

	self.bagList1:setVirtual()
	self.bagList2:setVirtual()
	self.bagList3:setVirtual()
	self.bagList4:setVirtual()
	self.bagList1:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listBagData1[index+1],CodeType.ITEM, "bag")
		itemcell.view:addClickListener(function(context)
				context:stopPropagation()
				self.useNum = 1
				self._itemData = itemcell._itemData
				self:updateRightPanel()
		end,33)
	end
	)
	self.bagList2:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listBagData2[index+1],CodeType.ITEM, "bag")
		itemcell.view:addClickListener(function(context)
			context:stopPropagation()
			self.useNum = 1
			self._itemData = itemcell._itemData
			self:updateRightPanel()
	end,33)
	end
	)
	self.bagList3:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listBagData3[index+1],CodeType.ITEM, "bag")
		itemcell.view:addClickListener(function(context)
			context:stopPropagation()
			self.useNum = 1
			self._itemData = itemcell._itemData
			self:updateRightPanel()
	end,33)
	end
	)
	self.bagList4:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listBagData4[index+1],CodeType.ITEM, "bag")
		itemcell.view:addClickListener(function(context)
			context:stopPropagation()
			self.useNum = 1
			self._itemData = itemcell._itemData
			self:updateRightPanel()
	end,33)
	end
	)

	self.btn_add:addClickListener(function( ... )
		local basicCopies = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicCopies
		local basicPointsInto = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicPointsInto
		local maxCopies = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].maxCopies
		local allAmount = self._itemData:getItemAmount()
		maxCopies = math.min(math.floor(allAmount/basicCopies),maxCopies) 
		local maxUseNum = maxCopies
		if self.useNum >= maxUseNum then return end
		self.useNum = self.useNum + 1
		self:updateRightPanel()
	end)

	self.btn_sub:addClickListener(function( ... )
		if self.useNum <= 1 then return end
		self.useNum = self.useNum - 1
		self.txt_num:setText(self.useNum)
		self:updateRightPanel()
	end)

	self.btn_putIn:addClickListener(function( ... )
		local params = {}
		params.code = self._itemData:getItemCode()
		params.amount = self.useNum
		params.onSuccess = function( res )
			self.bagTypeCtrl:setSelectedIndex(self.bagTypeCtrl2:getSelectedIndex())
			self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
			-- self:closeView()
		 end
		RPCReq.Guild_GuilPackdPutIn(params, params.onSuccess)
	end)

	self.btn_max:addClickListener(function( ... )
		local basicCopies = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicCopies
		local basicPointsInto = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicPointsInto
		local maxCopies = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].maxCopies
		local allAmount = self._itemData:getItemAmount()
		maxCopies = math.min(math.floor(allAmount/basicCopies),maxCopies) 
		local maxUseNum = maxCopies
		self.useNum = maxUseNum
		self:updateRightPanel()
	end)

	self.btn_min:addClickListener(function( ... )
		self.useNum = 1
		self:updateRightPanel()
	end)

   self.recordList:setVirtual()
	self.recordList:setItemRenderer(function (index,obj)
		local str,str2 =self:tidyTextShow(self.recordList._dataTemplate[index+1])
		obj:getChildAutoType("namelab"):setText(str)
		obj:getChildAutoType("detail"):setText(str2)
	end
	)
end

function GuildHourseView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:GuildHourse.GuildHourseView
	self.btnMore = viewNode:getChildAutoType('$btnMore')--GButton
	self.bagList1 = viewNode:getChildAutoType('bagList1')--GList
	self.bagList2 = viewNode:getChildAutoType('bagList2')--GList
	self.bagList3 = viewNode:getChildAutoType('bagList3')--GList
	self.bagList4 = viewNode:getChildAutoType('bagList4')--GList
	self.bagTypeCtrl = viewNode:getController('bagTypeCtrl')--Controller
	self.bagTypeCtrl2 = viewNode:getController('bagTypeCtrl2')--Controller
	self.btnCtrl = viewNode:getController('btnCtrl')--Controller
	self.btn_add = viewNode:getChildAutoType('btn_add')--GButton
	self.btn_max = viewNode:getChildAutoType('btn_max')--GButton
	self.btn_min = viewNode:getChildAutoType('btn_min')--GButton
	self.btn_putIn = viewNode:getChildAutoType('btn_putIn')--GButton
	self.btn_sub = viewNode:getChildAutoType('btn_sub')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itemCell = viewNode:getChildAutoType('itemCell')--GButton
	self.itemloder = viewNode:getChildAutoType('itemloder')--GLoader
	self.lihuiDisplay = viewNode:getChildAutoType('lihuiDisplay')--GButton
	self.list1 = viewNode:getChildAutoType('list1')--GList
	self.list2 = viewNode:getChildAutoType('list2')--GList
	self.list3 = viewNode:getChildAutoType('list3')--GList
	self.list4 = viewNode:getChildAutoType('list4')--GList
	self.list_type = viewNode:getChildAutoType('list_type')--GList
	self.list_type2 = viewNode:getChildAutoType('list_type2')--GList
	self.nameLabel = viewNode:getChildAutoType('nameLabel')--GRichTextField
	self.numVal = viewNode:getChildAutoType('numVal')--GRichTextField
	self.openBtn = viewNode:getChildAutoType('openBtn')--GButton
	self.pageCtrl = viewNode:getController('pageCtrl')--Controller
	self.recordList = viewNode:getChildAutoType('recordList')--GList
	self.rightCtrl = viewNode:getController('rightCtrl')--Controller
	self.secondBg = viewNode:getChildAutoType('secondBg')--GLoader
	self.tipCloseBtn = viewNode:getChildAutoType('tipCloseBtn')--GButton
	self.txt_goldNum = viewNode:getChildAutoType('txt_goldNum')--GTextField
	self.txt_num = viewNode:getChildAutoType('txt_num')--GTextField
	--{autoFieldsEnd}:GuildHourse.GuildHourseView
	--Do not modify above code-------------
end

function GuildHourseView:_initUI( )
	self:_initVM()
	self:setBg("ghHource_bg.png")
	self.secondBg:setURL( string.format("Bg/%s","ghHourse_scbg.png"))
    self.lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    self.lihuiDisplay:setData(15005, nil, true)
	-- self._closeBtn:removeClickListener()
	-- self._closeBtn:addClickListener(function ()
	-- 	for i=1,4 do
	-- 		local childrens = self["list"..i]:getChildren()
	-- 		for j=1,#childrens do
	-- 			local obj = self["list"..i]:getChildAt(j-1)
	-- 			if obj.timer then
	-- 				TimeLib.clearCountDown(obj.timer)
	-- 				obj.timer = false
	-- 			end
	-- 		end
	-- 	end
	-- 	self:closeView()
	-- end)

	self.btnMore:addClickListener(function() 
		ViewManager.open("GuildAllRecordView",{data=self.recordListData})
	end)

	self.openBtn:addClickListener(function() 
		self.useNum = 1
		if self.pageCtrl:getSelectedIndex() == 0 then
			self.pageCtrl:setSelectedIndex(1)
			self.btnCtrl:setSelectedIndex(1)
			self.bagTypeCtrl2:setSelectedIndex(self.bagTypeCtrl:getSelectedIndex())
			self:ChangeBagPage(self.bagTypeCtrl2:getSelectedIndex())
		elseif self.pageCtrl:getSelectedIndex() == 1 then
			self.pageCtrl:setSelectedIndex(0)
			self.btnCtrl:setSelectedIndex(0)
			self.bagTypeCtrl2:setSelectedIndex(self.bagTypeCtrl:getSelectedIndex())
			self:ChangeBagPage(self.bagTypeCtrl2:getSelectedIndex())
		end
	end)

	self.tipCloseBtn:addClickListener(function() 
		self.pageCtrl:setSelectedIndex(0)
	end)

	--默认是大页
	self.pageCtrl:setSelectedIndex(0)
	self.list_type:setItemRenderer(function (index,obj)
		obj:removeClickListener(33)
		obj:addClickListener(function( ... )
				self.bagTypeCtrl:setSelectedIndex(index)
				self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
		end,33)
	end)
	self.list_type:setNumItems(4)


	self.list_type2:setItemRenderer(function (index,obj)
		obj:removeClickListener(33)
		obj:addClickListener(function( ... )
				self.bagTypeCtrl2:setSelectedIndex(index)
				self:ChangeBagPage(self.bagTypeCtrl2:getSelectedIndex())
		end,33)
	end)
	self.list_type2:setNumItems(4)

	--请求服务器数据
	local params = {}
	params.onSuccess = function (res )
		-- printTable(1,res)
		self.packInfoList = res.packInfoList
		self.recordListData = res.recordList
		self.dayAddItemTimes = res.dayAddItemTimes
		if tolua.isnull(self.view) then return end
		self:showRecordList()
		self.bagTypeCtrl:setSelectedIndex(0)
		self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
	end
	RPCReq.Guild_GuidGetPackInfo(params, params.onSuccess)
end

--公会金库数据更新
function GuildHourseView:Guild_PackUpdateNotify(_,data)
	local params = {}
	params.onSuccess = function (res )
		self.packInfoList = res.packInfoList
		self.recordListData = res.recordList
		self.dayAddItemTimes = res.dayAddItemTimes
		if tolua.isnull(self.view) then return end
		self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
		self:showRecordList()
	end
	RPCReq.Guild_GuidGetPackInfo(params, params.onSuccess)
end

function GuildHourseView:getPackDataByType(type)
	for k,v in pairs(self.packInfoList) do
		if v.packType == type then
			local itemList = {}
			for k,v in pairs(v.itemList) do
				table.insert(itemList,v)
			end
			--排序
			table.sort(itemList,function( a,b )
				local code1 = a.code
				local code2 = b.code
				local color1 = ItemConfiger.getQualityByCode(code1)
				local color2 = ItemConfiger.getQualityByCode(code2)
				if color1 == color2 then
					if code1 ==code2 then
						return a.expireMS<b.expireMS
					else
						return code1>code2
					end
				else
					return color1>color2
				end 
			end)
			return itemList,v.count
		end
	end
end

function GuildHourseView:ChangePage( idx )
	local index = idx + 1
	self.aniFlagArr[index] = false
	self:updateList(idx)
	self["list"..index]:setSelectedIndex(0)
end

function GuildHourseView:ChangeBagPage( idx )
	self.useNum = 1
	local index = idx + 1
	self:updateBagList(idx)
	if not (#self["listBagData"..index]>0) then
		self.rightCtrl:setSelectedIndex(0)
		return
	end
	self.rightCtrl:setSelectedIndex(1)
	self["bagList"..index]:setSelectedIndex(0)
	self._itemData = self["listBagData"..index][1]
	self:updateRightPanel()
end

function GuildHourseView:updateRightPanel()
	local itemcellobj = BindManager.bindItemCell(self.itemCell)
	itemcellobj:setIsBig(true)
	itemcellobj:setItemData(self._itemData)
	local color = ItemConfiger.getQualityByCode(self._itemData:getItemCode())
	local colorStr = ColorUtil.getItemColorStr(color)
	self.nameLabel:setText(string.format("[color=%s]%s[/color]",colorStr,self._itemData:getName()))
	--基本份数
	local basicCopies = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicCopies
	local basicPointsInto = DynamicConfigData.t_GuildTreasuryConfig[self._itemData:getItemCode()].basicPointsInto
	local allAmount = self._itemData:getItemAmount()
	-- local maxCopies = math.floor(allAmount/basicCopies)*basicCopies
	itemcellobj:setAmount(self.useNum*basicCopies)
	self.txt_num:setText(self.useNum)
	self.txt_goldNum:setText(self.useNum *basicPointsInto)

	local url = ItemConfiger.getItemIconByCode(GameDef.MoneyType.GuildPackScore, GameDef.ItemType.Money, true)
	self.itemloder:setURL(url)
end

function GuildHourseView:makebagDatas(cateType)
	local configArr = {} --配置的分类1
	local config = DynamicConfigData.t_GuildTreasuryConfig
	for k,v in pairs(config) do
		if v.category == (cateType+1) and v.intoLimit~=1  then
			table.insert(configArr,v)
		end
	end
	local listData = {}
	for i=1,#configArr do
		local code = configArr[i].id
		local baseInfo = DynamicConfigData.t_item[tonumber(code)]
		local category =baseInfo.category
		if category == 1 then
			local bagItems = ModelManager.PackModel:getNormalBag():getPackItems(code,false)
			if bagItems then
				for k,v in pairs(bagItems) do
					if v:getItemCode() == code then
						table.insert(listData,v)
					end
				end
			end
		elseif category == 2 then
			local bagItems = ModelManager.PackModel:getEquipBag():getPackItems(code,false)
			if bagItems then
				for k,v in pairs(bagItems) do
					if v:getItemCode() == code then
						table.insert(listData,v)
					end
				end
			end
		elseif category == 3 then
			local bagItems = ModelManager.PackModel:getSpecialBag():getPackItems(code,false)
			if bagItems then
				for k,v in pairs(bagItems) do
					if v:getItemCode() == code then
						table.insert(listData,v)
					end
				end
			end
		elseif category == 4 then
			local bagItems = ModelManager.PackModel:getHeroCompBag():getPackItems(code,false)
			if bagItems then
				for k,v in pairs(bagItems) do
					if v:getItemCode() == code then
						table.insert(listData,v)
					end
				end
			end
		elseif category == 6 then
			local bagItems = ModelManager.PackModel:getJewelryBag():getPackItems(code,false)
			if bagItems then
				for k,v in pairs(bagItems) do
					if v:getItemCode() == code then
						table.insert(listData,v)
					end
				end
			end
		end
	end
	--排序
	table.sort(listData,function(a,b) 
		if (not a) or (not b) then
			return false
		end
		local aitemInfo = a:getItemInfo()
		local bitemInfo = b:getItemInfo()
		if (not aitemInfo) or (not bitemInfo) then
			return false
		end
		local asortFirst = 0
		local bsortFirst = 0
		if  type(aitemInfo.sortFirst) =="number" then
			asortFirst = aitemInfo.sortFirst
		else
			asortFirst = 0
		end

		if type(bitemInfo.sortFirst) =="number" then
			bsortFirst = bitemInfo.sortFirst	
		else
			bsortFirst = 0
		end
		if asortFirst == bsortFirst then
			if aitemInfo.color == bitemInfo.color then
				return aitemInfo.code < bitemInfo.code
			else
				return aitemInfo.color > bitemInfo.color
			end
		else
			return asortFirst>bsortFirst
		end
	end)
	return listData
end

function GuildHourseView:makeBagData( type )
	self["listBagData"..(type+1)] = self:makebagDatas(type)
	self["bagList"..(type+1)]:setData(self["listBagData"..(type+1)])
end

--普通道具消息监听方法
function GuildHourseView:pack_item_change( ... )
	print(1,"pack_item_change")
	self:makeBagData(self.bagTypeCtrl2:getSelectedIndex())
end

--装备道具消息监听方法
function GuildHourseView:pack_equip_change( ... )
	print(1,"pack_equip_change")
	self:makeBagData(self.bagTypeCtrl2:getSelectedIndex())
end

--装备道具消息监听方法
function GuildHourseView:pack_special_change( ... )
	print(1,"pack_special_change")
	self:makeBagData(self.bagTypeCtrl2:getSelectedIndex())
end

--装备道具消息监听方法
function GuildHourseView:pack_herocomp_change( ... )
	print(1,"pack_herocomp_change")
	self:makeBagData(self.bagTypeCtrl2:getSelectedIndex())
end

--装备道具消息监听方法
function GuildHourseView:pack_jewelry_change( ... )
	print(1,"pack_herocomp_change")
	self:makeBagData(self.bagTypeCtrl2:getSelectedIndex())
end

--更新放入页面的数据
function  GuildHourseView:updateBagList(type)
	if (type ~= self.bagTypeCtrl2:getSelectedIndex()) then
		return;
	end
	self:makeBagData(type)
end

--依旧保留列表操作记录 用多个列表来做
function GuildHourseView:updateList( type )
	print(1,"updateList")
	if (type ~= self.bagTypeCtrl:getSelectedIndex()) then
		return;
	end
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end

	self["listData"..(type+1)] = self:getPackDataByType(type+1)
	self["list"..(type+1)]:setData(self["listData"..(type+1)])
	self.numVal:setText(string.format("[color=#454545]%d[/color][color=#454545]%s[/color]",#self["listData"..(type+1)],"/"..DynamicConfigData.t_GuildTreasuryConstConfig["CategoryLimit"].TreasuryValue))
end


function GuildHourseView:_exit()
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end

	for i=1,4 do
		local childrens = self["list"..i]:getChildren()
		for j=1,#childrens do
			local obj = self["list"..i]:getChildAt(j-1)
			if obj.timer then
				TimeLib.clearCountDown(obj.timer)
				obj.timer = false
			end
		end
	end
	-- for k,v in pairs(self.__timerIdArr) do
	-- 	if self.__timerIdArr[k] then
	-- 		TimeLib.clearCountDown(self.__timerIdArr[k])
	--         self.__timerIdArr[k] = false
	-- 	end
	-- end
end

return GuildHourseView