local EmblemStarUpView = class("EmblemStarUpView", Window)
local EmblemCell = require "Game.Modules.Emblem.EmblemCell"

function EmblemStarUpView:ctor()
	self._packName = "Emblem"
	self._compName = "EmblemStarUpView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.data = self._args.data
	self.items = {}
	self.counts = {} -- 每种材料、纹章选择的数量
	self.hasNums = {} -- 每种材料、纹章的拥有数量
	self.itemCfgs = {} -- 每种材料、纹章的数据
	self.itemObjList = {}
	self.selectItemlList = {} 

	self.spineStr = {}
	self.itemList = false
	self.btn_add = false
	self.btn_confirm = false
	self.btn_cancel = false
	self.expProgressBar = false
	self.costItem = false
	self.txt_addExp = false
	self.upAnimation = false
	self.upgradeCfg = DynamicConfigData.t_EmblemUpgrade -- 升星配置
	self.upgradeConstCfg = DynamicConfigData.t_EmblemConst[1] -- 升星配置
	self.t_Emblem = DynamicConfigData.t_Emblem
	self.rank = self.data.color -- 纹章品质
	self:resetData()
	self.needExp = 0
	self.maxAddExp = 0 -- 当前纹章升到满级需要的经验
	self.amount = 0
	self.maxStarLevel = self.data.color - 1 -- 当前纹章可达到的最大星级
	self.bCurIsMaxStarLevel = self.curStar == self.maxStarLevel -- 当前是否最大星级

end

function EmblemStarUpView:_initUI()	
	
	local view = self.view
	self.itemList = view:getChildAutoType("itemList")
	self.btn_add = view:getChildAutoType("btn_add")
	self.btn_confirm = view:getChildAutoType("btn_confirm")
	self.btn_cancel = view:getChildAutoType("btn_cancel")
	self.progressBar = view:getChildAutoType("ProgressBar")
	self.expProgressBar = view:getChildAutoType("expProgressBar")
	self.protitle = view:getChildAutoType("title")
	local conf = self.t_Emblem[self.data.code]
	view:getChildAutoType("name"):setText(conf.name)
	self.fightAttrList = view:getChildAutoType("fightAttrList")
	self.fightAttrList:setItemRenderer(function(index,obj)
		local str = DynamicConfigData.t_combat[self.attribute[index + 1].attrId].name
		if self.attribute[index + 1].attrId >= 100 then
			obj:getChildAutoType("str1"):setText(str .. "   " .. math.ceil(self.attribute[index + 1].val) / 100 .. "%")
		else
			obj:getChildAutoType("str1"):setText(str .. "   " .. math.ceil(self.attribute[index + 1].val))
		end
		if self.attribute[index + 1].starAdd then
			if self.attribute[index + 1].attrId >= 100 then
				obj:getChildAutoType("str2"):setText(math.ceil(self.attribute[index + 1].starAdd)/ 100 .. "%")
			else
				obj:getChildAutoType("str2"):setText(math.ceil(self.attribute[index + 1].starAdd))
			end
			obj:getController("state"):setSelectedIndex("1")
			
		else
			obj:getController("state"):setSelectedIndex("0")
		end
		if tolua.isnull(obj.skeletonNode) then
			local spinenode = obj:getChildAutoType("spine")
			obj.skeletonNode = SpineUtil.createSpineObj(spinenode,vertex2(0,0), "ui_wenzhangshengxing_2", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang",false,true)
			obj.skeletonNode:setVisible(false)
			table.insert(self.spineStr,obj)
		end
	end)
	self.spinenode = view:getChildAutoType("spinenode")
	self.spinenode.skeletonNode = SpineUtil.createSpineObj(self.spinenode,vertex2(0,0), "ui_wenzhangshengxing_1", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang",false,true)
	self.spinenode:setVisible(false)

	self.costItem = BindManager.bindCostItem(view:getChildAutoType("costItem"))
	self.txt_addExp = view:getChildAutoType("txt_addExp")
	self.txt_addExp:displayObject():setOpacity(0)

	local lbl = self.txt_addExp:displayObject()
	self.tipsNode = cc.Node:create()
	lbl:addChild(self.tipsNode)
	
	self.closeBtn = view:getChildAutoType("closeBtn")
	self.closeBtn:removeClickListener()
	self.closeBtn:addClickListener(function()
		if self.upAnimation then return RollTips.show(Desc.Emblem_Desc5) end
		self:closeView()
	end,99)
	self.frame = view:getChildAutoType("frame")
	self.closeButton = self.frame:getChildAutoType("closeButton")
	self.closeButton:removeClickListener()
	self.closeButton:addClickListener(function()
		if self.upAnimation then return RollTips.show(Desc.Emblem_Desc5) end
		self:closeView()
	end,99)

	for i = 1,3 do
		self["emblem"..i] = EmblemCell.new(view:getChildAutoType("emblem"..i))
		self["emblem"..i]:setData(self.data)
		if self.data.category ~= 0 then
			self["emblem"..i]:setCategoryPos(1)
		end
		if self.data.star ~= 0 then
			self["emblem"..i]:setStarType(1)
			self["emblem"..i]:setStarPos(2)
		end
		self["emblem"..i].itemCell.view:getChild("frameLoader"):setVisible(false)
	end
	self:bindEvents()
	self:updateData()
	self:updateExpProgressBar()
	self:updateList()
	self:setCost(0)
end
function EmblemStarUpView:bindEvents()
	self.btn_add:addClickListener(function()
		self:onClickAdd()
	end)

	self.btn_confirm:addClickListener(function()
		local items = self:doReckonItem()
		local state = false
		for key,value in pairs(items) do
			if value.color and value.color >= 6 then
				state = true
			end
		end
		if state then
			local info = {
				text = Desc.Emblem_Desc4,
				type="yes_no",
				onYes= function()
					self:onClickConfirm(items)
				end,
			}
			Alert.show(info)
		else
			self:onClickConfirm(items)
		end
	end)

	self.btn_cancel:addClickListener(function()
		self:onClckCancel()
	end)
end

function EmblemStarUpView:updateData()
	self:calculateMaxAddExp()
	self:updateListData()
	self:updateShowAttr()
end
function EmblemStarUpView:updateShowAttr()
	if self.curStarTemp > self.curStar then
		self.view:getController("levelState"):setSelectedIndex(1)
		self.emblem3:setStar(self.curStarTemp)
		self.emblem3:setStarType(self.curStarTemp ~= 0 and 1 or 0)
		self.emblem3:setStarPos(self.curStarTemp ~= 0 and 2 or 0)

		self.emblem2:setStar(self.curStar)
		self.emblem2:setStarType(self.curStar ~= 0 and 1 or 0)
		self.emblem2:setStarPos(self.curStarTemp ~= 0 and 2 or 0)
	else
		self.view:getController("levelState"):setSelectedIndex(0)
		self.emblem1:setStar(self.data.star)
		self.emblem1:setStarType(self.data.star ~= 0 and 1 or 0)
		self.emblem1:setStarPos(self.data.star ~= 0 and 2 or 0)
	end
	
	for key,value in pairs(self.attribute) do
		value.starAdd =  self.curStarTemp > self.curStar and (1 + self.curStarTemp * self.upgradeConstCfg.StarAdd / 10000) * value.baseVal or nil
	end
	
	for key,value in pairs(self.spineStr) do
		if value.skeletonNode then
			value.skeletonNode:removeFromParent()
			value.skeletonNode = nil
		end
	end
	self.spineStr = {}
	self.fightAttrList:setData(self.attribute)
end
-- 计算当前可增加的最大经验值
function EmblemStarUpView:calculateMaxAddExp()
	local star = self.curStar
	while star < self.maxStarLevel do
		local needExp = self.upgradeCfg[self.rank][star+1]["needExp"]
		self.maxAddExp = self.maxAddExp + needExp
		star = star + 1
	end
end

-- 更新滚动框列表数据
function EmblemStarUpView:updateListData()
	local itemCfgs = {}
	local itemMap = {}
	local allItems = EmblemModel:getBag(false) -- 获取所有未穿戴的纹章
	-- 相同纹章放一起(code、star相同)
	for _, v in pairs(allItems) do
		if v.uuid ~= self.data.uuid then
			local key = tostring(v.code) .. tostring(v.star) ..tostring(v.exp) ..tostring(v.category)..tostring(v.pos)
			if not itemMap[key] then
				itemMap[key] = {data = clone(v), list = {}}
			end
			table.insert(itemMap[key]["list"], v)
		end
	end
	for _, t in pairs(itemMap) do
		table.sort(t.list, function(a, b)
			return a.exp < b.exp
		end)
		table.insert(itemCfgs, t)
	end
	table.sort(itemCfgs, function(a, b)
		if a.data.color == b.data.color then
			if a.data.star == b.data.star then
				if a.data.exp == b.data.exp then
					return a.data.pos < b.data.pos
				else
					return a.data.exp < b.data.exp
				end
			else
				return a.data.star < b.data.star
			end
		else
			return a.data.color < b.data.color
		end
	end)
	local materialList = {}
	for key,value in pairs(self.upgradeConstCfg.material) do
		local itemList = ModelManager.PackModel:getPackByType(GameDef.BagType.Special):getItemsByCode(value.id)
		for k,v in pairs(itemList) do
			local material = {}
			material.material = true
			material.itemId = v.__data.id
			material.codeId = v.__data.code
			material.exp = value.exp
			material.num = v.__data.amount
			material.bagType = v.__bagType
			table.insert(materialList,material)
		end
	end
	table.sort(materialList,function(a,b)
		return a.codeId > b.codeId
	end)
	for key,value in pairs(materialList) do
		table.insert(itemCfgs,1,value)
	end
	self.itemCfgs = itemCfgs
	local counts = {}
	local hasNums = {}
	for i, t in ipairs(itemCfgs) do
		counts[i] = 0
		if t.list then
			hasNums[i] = #t.list
		else
			hasNums[i] = t.num
		end
	end
	self.counts = counts
	self.hasNums = hasNums
end
function EmblemStarUpView:itemListHander(index,obj)
	local itemCfgs = self.itemCfgs
	local counts = self.counts
	local hasNums = self.hasNums
	index = index + 1
	obj.index = index
	local showSubCtrl = obj:getController("cShowSub")
	obj:getController("isItem"):setSelectedIndex(itemCfgs[index].material and 1 or 0)
	local itemCell = nil
	if itemCfgs[index].material then
		itemCell = obj:getChildAutoType("itemCell")
		local item = BindManager.bindItemCell(itemCell)
		item:setData(itemCfgs[index].codeId, itemCfgs[index].amount, 3)
	else
		itemCell = obj:getChildAutoType("EmblemCell")
		local EmblemCell = EmblemCell.new(itemCell)
		EmblemCell:setCategoryPos(3)
		EmblemCell:setStarType(0)
		EmblemCell:setData(itemCfgs[index].data)
		obj:getChildAutoType("list_star"):setNumItems(itemCfgs[index].data.star)
	end
	counts[index] = counts[index] or 0
	local longTouchTag = false
	local btn_sub = obj:getChildAutoType("btn_sub")
	local txt_num = obj:getChildAutoType("txt_num")
	local expStr = obj:getChildAutoType("exp")

	local addExp = 0
	if itemCfgs[index].material then 
		addExp = addExp + itemCfgs[index].exp
--		obj:getChildAutoType("name"):setText("")
	else 
		local rank = itemCfgs[index]["data"]["color"] -- 品质
		local star = itemCfgs[index]["data"]["star"] -- 星级
		local giveExp = self.upgradeCfg[rank][star]["giveExp"] -- 吞噬一个该类型纹章提供的经验
		local exp = itemCfgs[index]["list"][1]["exp"] -- 该纹章已有的经验
		addExp = addExp + giveExp + exp
		local conf = self.t_Emblem[itemCfgs[index].data.code]
--		obj:getChildAutoType("name"):setText(conf.name)
	end
	expStr:setText(addExp .. Desc.common_expType1)
	if counts[index] > 0 then
		showSubCtrl:setSelectedIndex(1)
		txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
	else
		showSubCtrl:setSelectedIndex(0)
		txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
	end
	itemCell:removeClickListener()
	itemCell:addLongPressListener(function(context)
		local oldPos = cc.p(obj:displayObject():getPosition())
		oldPos = obj:displayObject():getParent():convertToWorldSpace(oldPos)
		local lastY = oldPos.y
		longTouchTag = Scheduler.schedule(function()
			local pos = cc.p(obj:displayObject():getPosition())
			pos = obj:displayObject():getParent():convertToWorldSpace(pos)
			local y = pos.y
			if math.abs(lastY - y) > 10 then -- 长按时移动滚动框，停止定时器
				Scheduler.unschedule(longTouchTag)
			else
				local num = math.ceil(hasNums[index] / 15)
				counts[index] = counts[index] + num
				if counts[index] > hasNums[index] then
					num = num - (counts[index] - hasNums[index])
					counts[index] = hasNums[index]
				end
				if not self:checkAndFixAddNum(index, num) then -- 选择的数量不合法，停止定时器，注意此处可能会改变counts[index]的值
					Scheduler.unschedule(longTouchTag)
				end
				if counts[index] == hasNums[index] then -- 需要再判断一次是否达到最大选择数量
					Scheduler.unschedule(longTouchTag)
				end
				if counts[index] > 0 then
					showSubCtrl:setSelectedIndex(1)
					txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
				else
					showSubCtrl:setSelectedIndex(0)
					txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
				end
			end
		end,0.2,0)
	end,1,function (context)Scheduler.unschedule(longTouchTag) end)
	itemCell:addClickListener(function()
		if counts[index] >= hasNums[index] then
			return
		end
		counts[index] = counts[index] + 1
		self:checkAndFixAddNum(index, 1)
		if counts[index] > 0 then
			showSubCtrl:setSelectedIndex(1)
			txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
		else
			showSubCtrl:setSelectedIndex(0)
			txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
		end
	end,99)
	btn_sub:addClickListener(function()
		if counts[index] <= 0 then
			return
		end
		counts[index] = counts[index] - 1
		self:checkAndFixAddNum(index, -1)
		if counts[index] < 0 then
			counts[index] = 0
		end
		if counts[index] > 0 then
			showSubCtrl:setSelectedIndex(1)
			txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
		else
			showSubCtrl:setSelectedIndex(0)
			txt_num:setText(string.format("%d/%d", counts[index], hasNums[index]))
		end
	end,99)
end
-- 更新滚动框
function EmblemStarUpView:updateList()
	self.itemObjList = {}
	self.selectItemlList = {}
	self.itemList:setVirtual()
	self.itemList:setItemRenderer(function(index,obj)
		table.insert(self.itemObjList,obj)
		self:itemListHander(index,obj)
	end)
	self.itemList:setNumItems(#self.itemCfgs)
end

-- 检查增加或者减少的数量是否合法，不合法自动修正，合法返回true
-- 每次修改self.counts都要检查
function EmblemStarUpView:checkAndFixAddNum(index, addNum)
	local bIsValid = true
	if self.bCurIsMaxStarLevel then -- 当前已是最大星级
		self.counts[index] = 0
		RollTips.show(Desc.Emblem_Desc1)
		return false
	end
	if addNum == 0 then
		return true
	end
	local addExp = 0 -- 此次选择增加的经验
	local oldSelectedNum = self.counts[index] - addNum -- 原来选了几个
	local itemCfg = self.itemCfgs[index]
	if not itemCfg.material then -- 选择的是纹章
		local rank = itemCfg["data"]["color"] -- 品质
		local star = itemCfg["data"]["star"] -- 星级
		local giveExp = self.upgradeCfg[rank][star]["giveExp"] -- 吞噬一个该类型纹章提供的经验
		if addNum > 0 then -- 添加选择数量
			local canAddNum = 0 -- 最多可选择个数
			for i = oldSelectedNum + 1, oldSelectedNum + addNum do
				if self.curExpTemp + addExp >= self.maxAddExp then -- 增加的经验达到上限
					bIsValid = false
					break
				end
				if i > 0 then
					local exp = itemCfg["list"][i]["exp"] -- 该纹章已有的经验
					addExp = addExp + giveExp + exp
					canAddNum = canAddNum + 1
				end
			end
			self.counts[index] = oldSelectedNum + canAddNum
			self.curExpTemp = self.curExpTemp + addExp
		else -- 减少选择数量
			for i = oldSelectedNum, oldSelectedNum + addNum + 1, -1 do
				if i > 0 then
					local exp = itemCfg["list"][i]["exp"] -- 该纹章已有的经验
					addExp = addExp + giveExp + exp
				end
			end
			self.counts[index] = oldSelectedNum + addNum
			addExp = -addExp
			self.curExpTemp = self.curExpTemp + addExp
		end
	else -- 选择的是升星粉尘
		if addNum > 0 then -- 添加选择数量
			local canAddNum = 0 -- 最多可选择个数
			for i = oldSelectedNum + 1, oldSelectedNum + addNum do
				if self.curExpTemp + addExp >= self.maxAddExp then -- 增加的经验达到上限
					bIsValid = false
					break
				end
				if i > 0 then
					addExp = addExp + itemCfg.exp
					canAddNum = canAddNum + 1
				end
			end
			self.counts[index] = oldSelectedNum + canAddNum
			self.curExpTemp = self.curExpTemp + addExp
		else -- 减少选择数量
			for i = oldSelectedNum, oldSelectedNum + addNum + 1, -1 do
				if i > 0 then
					addExp = addExp + itemCfg.exp
				end
			end
			self.counts[index] = oldSelectedNum + addNum
			addExp = -addExp
			self.curExpTemp = self.curExpTemp + addExp
		end
	end
	local amount = (self.curExpTemp - self.curExp) * self.upgradeConstCfg["UpgradeCost"]
	self:setCost(amount)-- 需要的金币
	self:updateExpProgressBar()
	self:calculationCount(addExp)
	return bIsValid
end 
function EmblemStarUpView:calculationCount(addExp)
	if addExp == 0 then return end
	local lbl = cc.Label:create()
	lbl:setColor(cc.c3b(0, 255, 0))
	lbl:setAnchorPoint(cc.p(0, 0))
	lbl:setSystemFontSize(20)
	lbl:setString(string.format(Desc.Emblem_addExp, addExp >= 0 and "+" or "",addExp))
	self.tipsNode:addChild(lbl)
	lbl:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.FadeOut:create(1.2),
			cc.MoveBy:create(0.5, cc.p(0, 50))
		),
		cc.RemoveSelf:create(true)
	))
end
-- 更新经验条
function EmblemStarUpView:updateExpProgressBar(state)
	if self.bCurIsMaxStarLevel then -- 已达到最大星级
		local needExp = self.upgradeCfg[self.rank][self.maxStarLevel]["needExp"]
		self.expProgressBar:setMin(0)
		self.expProgressBar:setMax(needExp)
		self.expProgressBar:setValue(needExp)
		self.protitle:setText("MAX")
	else -- 可升星	
		local curStarTemp = self.curStarTemp
		local levelUp = false
		local star = self.curStar -- 当前星级
		self.curStarTemp = star
		local extraExp = self.curExpTemp -- 溢出的经验
		local needExp = self.upgradeCfg[self.rank][star + 1]["needExp"] -- 升星需要的经验
		local time = 0.3 * (1 - self.expProgressBar:getValue() / self.expProgressBar:getMax())
		while extraExp >= needExp do
			if star >= self.maxStarLevel - 1 then -- 经验溢出
				-- extraExp = needExp
				self.curStarTemp = self.maxStarLevel
				break
			end
			extraExp = extraExp - needExp
			star = star + 1
			needExp = self.upgradeCfg[self.rank][star + 1]["needExp"]
			self.curStarTemp = star
		end
		if self.curStarTemp > curStarTemp then
			levelUp = true
		end
		self.expProgressBar:setMin(0)
		local curValue = self.expProgressBar:getValue()
		if state and levelUp then
			local arr = {}
			table.insert(arr,cc.DelayTime:create(time))
			table.insert(arr,cc.CallFunc:create(function()
				self.expProgressBar:setMax(needExp)
				self.protitle:setText(extraExp .. "/" .. needExp)
				self.expProgressBar:setValue(extraExp)
			end))
			self.expProgressBar:tweenValue(needExp,time)
			self.expProgressBar:displayObject():stopAllActions()
			self.expProgressBar:displayObject():runAction(cc.Sequence:create(arr))
		else
			self.expProgressBar:setMax(needExp)
			self.expProgressBar:setValue(extraExp)
			self.protitle:setText(extraExp .. "/" .. needExp)
		end
		
		self.extraExp = extraExp
		self.needExp = needExp
	end
	self:updateShowAttr()
end

-- 设置消耗金币
function EmblemStarUpView:setCost(amount)
	self.amount = amount
	self.costItem:setData(CodeType.MONEY, 1, amount, false)
end
-- 确认升星按钮点击回调
function EmblemStarUpView:resetData()
	self.attribute = clone(self.t_Emblem[self.data.code].attribute)
	for key,value in pairs(self.attribute) do
		value.baseVal = value.val
		value.val = (1 + self.data.star * self.upgradeConstCfg.StarAdd / 10000) * value.val
	end
	self.curExp = self.data.exp -- 当前经验
	self.curExpTemp = self.curExp -- 当前临时经验(选择材料、纹章后会改变)

	self.curStar = self.data.star -- 当前星级
	self.curStarTemp = self.curStar -- 当前临时星级(选择材料、纹章后会改变)
	self.extraExp = self.curExp
end
function EmblemStarUpView:onClickConfirm(items)
	if not next(items) then return end	
	if self.upAnimation then return RollTips.show(Desc.Emblem_Desc5) end
	local goldCount = ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Gold)
	if self.amount > goldCount then
		local moneyName = Desc["common_moneyType"..GameDef.MoneyType.Gold]
		local tips = string.format(Desc.common_notEnough, moneyName)
		RollTips.show(tips) 
		return
	end
	local severData = false
	local function resetData()
		self:resetData()
		self.selectItemlList = {}
		self:updateData()
		self:updateList()
		self:setCost(0)
		PackModel:getEmblemBag():setLevelExpByUUID(self.data.uuid,self.data.star,self.data.exp)
		PackModel:getDressEmblemBag():setLevelExpByUUID(self.data.uuid,self.data.star,self.data.exp)
		Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
		Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange,severData)
		self.upAnimation = false
	end
	local function ReqUseItem(callBack)
		RPCReq.Heraldry_UseItem({heraldryUuid = self.data.uuid,items = items},function(data)
			severData = data
			self.data.exp = self.extraExp
			self.data.star = self.curStarTemp
			if self.data.star == self.maxStarLevel then
				self.data.exp = 0	
				self.protitle:setText("MAX")	
				self.bCurIsMaxStarLevel = true
			end
			if callBack then
				callBack()
			else
				resetData()
			end
			if data.power and data.power > 0 then
				RollTips.showAddFightPoint(data.power, true)
			end
		end)
	end
	if self.view:getController("levelState"):getSelectedIndex() == 1 then
		self.upAnimation = true
		self.spinenode:setVisible(true)
		self.spinenode.skeletonNode:setAnimation(0,"ui_wenzhangshengxing_1",false)
		self.spinenode.skeletonNode:stopAllActions()
		self.spinenode.skeletonNode:setCompleteListener(function(name)
			if name == "ui_wenzhangshengxing_1" then
				self.spinenode:setVisible(false)
			end
		end)
		local arr = {}
		table.insert(arr,cc.DelayTime:create(0.3))
		table.insert(arr,cc.CallFunc:create(function()
			ReqUseItem(function()
				for i = 1,#self.spineStr do
					self.spineStr[i].skeletonNode:stopAllActions()
					local arr = {}
					table.insert(arr,cc.DelayTime:create(0.1 * i))
					table.insert(arr,cc.CallFunc:create(function()
						self.spineStr[i].skeletonNode:setVisible(true)
						self.spineStr[i].skeletonNode:setAnimation(0,"ui_wenzhangshengxing_2",false)
						if i == #self.spineStr then
							local arr1 = {}
							table.insert(arr1,cc.DelayTime:create(0.5))
							table.insert(arr1,cc.CallFunc:create(function()
								resetData()
							end))
							self.view:displayObject():runAction(cc.Sequence:create(arr1))
						end
					end))
					self.spineStr[i].skeletonNode:runAction(cc.Sequence:create(arr))
				end
			end)
		end))
		self.spinenode.skeletonNode:runAction(cc.Sequence:create(arr))
		
	else
		ReqUseItem()
	end
end

-- 一键添加按钮点击回调
function EmblemStarUpView:onClickAdd()
	if self.bCurIsMaxStarLevel then return RollTips.show(Desc.Emblem_Desc1) end
	if self.upAnimation then return RollTips.show(Desc.Emblem_Desc5) end
	if #self.itemCfgs == 0 then return  RollTips.show(Desc.Emblem_Desc6) end
	local realNum = self.needExp - self.extraExp
	if realNum == 0 then return RollTips.show(Desc.Emblem_Desc1) end

	local addExp = 0
	for key,value in pairs(self.itemCfgs) do
		if addExp < realNum then
			if value.list then
				if self.hasNums[key] >= 1 and self.counts[key] + 1 <= self.hasNums[key] then
					for i = self.counts[key] + 1,self.hasNums[key] do
						local v = value.list[i]
						local giveExp = self.upgradeCfg[v.color][v.star]["giveExp"] -- 吞噬一个该类型纹章提供的经验
						addExp = addExp + v.exp + giveExp
						self.counts[key] = self.counts[key] + 1
						if addExp >= realNum then
							break
						end
					end
				end
			else
				if self.hasNums[key] >= 1 and self.counts[key] + 1 <= self.hasNums[key] then
					for i = self.counts[key] + 1,self.hasNums[key] do
						addExp = addExp + value.exp
						self.counts[key] = self.counts[key] + 1
						if addExp >= realNum then
							break
						end
					end
				end
			end
		end
	end
	for key,value in pairs(self.counts) do
		if value > 0 then
			local obj = self:getItemObj(key)
			if obj then
				local showSubCtrl = obj:getController("cShowSub")
				local txt_num = obj:getChildAutoType("txt_num")
				showSubCtrl:setSelectedIndex(1)
				txt_num:setText(string.format("%d/%d", self.counts[key], self.hasNums[key]))
			end
		end
	end
	self.curExpTemp = self.curExpTemp + addExp
	local amount = (self.curExpTemp - self.curExp) * self.upgradeConstCfg["UpgradeCost"]
	self:setCost(amount)-- 需要的金币
	self:updateExpProgressBar(true)
	self:calculationCount(addExp)
end
function EmblemStarUpView:doReckonItem()
	local items = {}
	for key,value in pairs(self.counts) do
		if value > 0 then
			local itemCfg = self.itemCfgs[key]
			if itemCfg.material then
				local item = {}
				item.itemId = itemCfg.itemId
				item.amount = value
				item.itemCode = itemCfg.codeId
				item.bagType = itemCfg.bagType
				table.insert(items,item)
			else
				for i = 1,value do--服务器要求拆分发送
					local item = {}
					item.itemId = itemCfg.list[i].itemId
					item.amount = 1
					item.itemCode = itemCfg.data.code
					item.bagType = itemCfg.data.bagType
					item.color = itemCfg.data.color
					table.insert(items,item)
				end
			end
		end
	end
	return items
end
function EmblemStarUpView:getItemObj(index)
	for key,value in pairs(self.itemObjList) do
		if value.index == index then
			return value
		end
	end
	return
end
-- 一键取消按钮点击回调
function EmblemStarUpView:onClckCancel()
	for i, t in ipairs(self.itemCfgs) do
		self.counts[i] = 0
	end
	self.curExpTemp = self.curExp
	self.curStarTemp = self.curStar
	self:updateExpProgressBar()
	self:updateList()
	self:setCost(0)
end
function EmblemStarUpView:_exit()
end
return EmblemStarUpView