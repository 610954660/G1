local EmblemCell = require "Game.Modules.Emblem.EmblemCell"
local EmblemRecastView = class("EmblemRecastView", Window)

function EmblemRecastView:ctor()
	self._packName = "Emblem"
	self._compName = "EmblemRecastView"
	self._rootDepth = LayerDepth.PopWindow

	self.data = self._args.data
	self.tempCategory = self._args.data.categoryShow

	self.emblem = false -- 纹章
	self.cItem1 = false -- 种族
	self.cItem2 = false -- 种族
	self.cItem3 = false -- 种族
	self.cItem4 = false -- 种族
	self.showList = {}
	self.cItemList = {} -- 种族item列表
	self.cItemValue = {} -- 种族item值列表
	self.cItemSelectedCtrls = {} -- 种族item是否选中ctrl
	self.oldCategoryNode = false -- 纹章原种族图标node
	self.oldCategoryImgPos = false -- 纹章种族图标所在位置（节点空间坐标）

	self.bPlayRecastAnimation = false -- 是否正在播放重铸动画

	self.lastIdx = 1

	self.actNode = false
--	self.data = {pos = 2,star = 2,code = 923,exp = 0,category = 3,color = 3,uuid = "vZ6VZyQFavrQBUqa",heroUuid = false}

	self.btn_recast = false
	self.btn_save = false
	self.btn_cancel = false

	self.pageCtrl = false
	self.bHasSaveResult = true -- 是否保存重铸结果，点击保存或取消按钮会置为true
end
function EmblemRecastView:_initUI()
	local view = self.view
	self.emblem = EmblemCell.new(view:getChildAutoType("emblem"))
	self.emblem:setCategoryPos(1)
    self.emblem:setStarType(2)
	self.emblem:setData(self.data)

	self.oldCategoryNode = self.emblem.view:displayObject()
	self.oldCategoryImgPos = cc.p(self.oldCategoryNode:getPosition())
	self.cItem1 = view:getChildAutoType("cItem1")
	self.cItem2 = view:getChildAutoType("cItem2")
	self.cItem3 = view:getChildAutoType("cItem3")
	self.cItem4 = view:getChildAutoType("cItem4")
	self.btn_recast = view:getChildAutoType("btn_recast")
	self.btn_save = view:getChildAutoType("btn_save")
	self.btn_cancel = view:getChildAutoType("btn_cancel")
	self.pageCtrl = view:getController("c1")
	self.pageCtrl:setSelectedIndex(self.tempCategory == false and 0 or 1)

	self.cItemList = {self.cItem1, self.cItem2, self.cItem3, self.cItem4}

	self.actNode = cc.Node:create()
	view:displayObject():addChild(self.actNode)

	self:setCategoryItems()
	self:bindEvents()

	local list = ModelManager.HeroPalaceModel:getAllHeroInfo()
	self.heroList = {}
	for key,value in pairs(list) do
		if value.uuid then
			table.insert(self.heroList,ModelManager.CardLibModel:getHeroByUid(value.uuid))
		end
	end
	self.heroListObj = view:getChildAutoType("heroList")
	self.heroListObj:setItemRenderer(handler(self,self.heroListHandle))
	if self.tempCategory and self.tempCategory >= 1 and self.tempCategory <= 5 then
		self:updataList(self.tempCategory)
	else
		self:updataList(self.data.category)
	end
	self.hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(10000095)
	local emblemConst = DynamicConfigData.t_EmblemConst[1].resetCost[1]
	-- local item = DynamicConfigData.t_item
	local costBarItem = BindManager.bindCostItem(view:getChildAutoType("costItem"))
	costBarItem:setData(CodeType.ITEM,emblemConst.id,emblemConst.cout, false)

end
function EmblemRecastView:heroListHandle(index, obj)
	local heroCell = BindManager.bindHeroCell(obj)
	heroCell:setData(self.showList[index + 1])
end
function EmblemRecastView:updataList(category)
	self.showList = {}
	for key,value in pairs(self.heroList) do
		if value.heroDataConfiger.category == category then
			table.insert(self.showList,value)
		end
	end
	self.heroListObj:setData(self.showList)
end
-- 设置种族item
function EmblemRecastView:setCategoryItems()
	self.cItemValue = {}
	for i = 1, 5 do
		if i ~= self.data.category then
			table.insert(self.cItemValue, i)
		end
	end
	for i = 1, 4 do
		local cItem = self.cItemList[i]
		self.cItemSelectedCtrls[i] = cItem:getController("selectedCtrl")
		self.cItemSelectedCtrls[i]:setSelectedIndex(self.tempCategory == self.cItemValue[i] and 1 or 0)
		cItem:getChildAutoType("img_category"):setURL(PathConfiger.getCardSmallCategory(self.cItemValue[i]))
	end
end

function EmblemRecastView:bindEvents()
	self.btn_save:addClickListener(handler(self, self.onClickSave))
	self.btn_cancel:addClickListener(handler(self, self.onClickCancel))
	self.btn_recast:addClickListener(handler(self, self.onClickRecast))
end

-- 保存按钮点击回调
function EmblemRecastView:onClickSave()
	if self.bPlayRecastAnimation then
		RollTips.show(Desc.Emblem_Desc2)
		return
	end

	RPCReq.Heraldry_SaveRace({heraldryUuid = self.data.uuid},function(data)
		-- 更新数据
		self.data.category = self.tempCategory
		self.emblem:setData(self.data)
		self:setCategoryItems()
		self.bHasSaveResult = true
		self.pageCtrl:setSelectedIndex(0)
		self.tempCategory = false
		self._args.data.categoryShow = false
		PackModel:getEmblemBag():setCategoryByUUID(self.data.uuid,self.data.category)
		PackModel:getDressEmblemBag():setCategoryByUUID(self.data.uuid,self.data.category)
		Dispatcher.dispatchEvent("Emblem_refreshBagInfo")
		Dispatcher.dispatchEvent(EventType.Emblem_emblemEquipChange, data)
	end)
end

-- 取消按钮点击回调
function EmblemRecastView:onClickCancel()
	if self.bPlayRecastAnimation then
		RollTips.show(Desc.Emblem_Desc2)
		return
	end
	RPCReq.Heraldry_CancelRace({heraldryUuid = self.data.uuid},function(data)
		self.bHasSaveResult = true
		self.pageCtrl:setSelectedIndex(0)
		self.tempCategory = false
		self._args.data.categoryShow = false
		self:setCategoryItems()
	end)
end

-- 重铸按钮点击回调
function EmblemRecastView:onClickRecast()
	if self.bPlayRecastAnimation then
		RollTips.show(Desc.Emblem_Desc2)
		return
	end

	RPCReq.Heraldry_ResetRace({heraldryUuid = self.data.uuid},function(data)
		self.bHasSaveResult = false
		self.tempCategory = data.categoryShow
		self._args.data.categoryShow = data.categoryShow
		self:playRandomSelectedAnimation(data.categoryShow)
	end)
end

-- 播放随机选择种族动画
function EmblemRecastView:playRandomSelectedAnimation(newCategory)
	self.actNode:stopAllActions()
	self.bPlayRecastAnimation = true
	local idx = 1
	for i, category in ipairs(self.cItemValue) do
		if category == newCategory then
			idx = i
			break
		end
	end

	local optionsNum = #self.cItemValue -- 总的选项数
	local curIdx = self.lastIdx -- 当前选中的选项下标
	local addNum = idx - self.lastIdx -- 差值
	if addNum < 0 then
		addNum = optionsNum + addNum
	end
	local delayTime = 0.045 -- 默认轮询间隔时间（秒）

	-- RollTips.show(string.format("应选中第%d项", idx))

	local ts = {}
	for i = 1, optionsNum * 6 do
		local t = delayTime
		if i < 8 then -- 模拟加速
			t = t + 0.01 * (8 - i)
		end
		if i > optionsNum * 6 - 6 then -- 模拟减速
			t = t + 0.03 * (i - (optionsNum * 6 - 6))
		end
		ts[i] = t
	end
	local actions = {}
	for k, time in ipairs(ts) do
		local act = cc.Sequence:create(
			cc.DelayTime:create(time),
			cc.CallFunc:create(function()
				self.cItemSelectedCtrls[self.lastIdx]:setSelectedIndex(0)
				self.lastIdx = self.lastIdx + 1
				if self.lastIdx > optionsNum then
					self.lastIdx = 1
				end
				self.cItemSelectedCtrls[self.lastIdx]:setSelectedIndex(1)

			end)
		)
		table.insert(actions, act)
	end
	-- 根据差值，在动作序列中插入额外动作，以调整抽奖结果
	if addNum >= 1 then
		for i = 1, addNum do
			local act = cc.Sequence:create(
				cc.DelayTime:create(delayTime),
				cc.CallFunc:create(function()
					self.cItemSelectedCtrls[self.lastIdx]:setSelectedIndex(0)
					self.lastIdx = self.lastIdx + 1
					if self.lastIdx > optionsNum then
						self.lastIdx = 1
					end
					self.cItemSelectedCtrls[self.lastIdx]:setSelectedIndex(1)
				end)
			)
			table.insert(actions, 10, act)
		end
	end
	local finallyAction = cc.CallFunc:create(function()
		self.bPlayRecastAnimation = false
		self.pageCtrl:setSelectedIndex(1)
		self:updataList(self.tempCategory)
	end)
	table.insert(actions, finallyAction)
	local action = cc.Sequence:create(unpack(actions))
	self.actNode:runAction(action)
end

-- 播放重铸动画
function EmblemRecastView:playRecastAnimation()
	self.bPlayRecastAnimation = true

	local moveTime = 1

	local curCategoryImgNode = self.cItemList[self.lastIdx]:getChildAutoType("img_category"):displayObject() -- 当前选中种族item的种族图标node
	local pos = cc.p(curCategoryImgNode:getPosition()) -- 当前选中种族item的种族图标node位置(节点空间坐标)
	local oldCategoryImgWorldPos = self.oldCategoryNode:getParent():convertToWorldSpace(self.oldCategoryImgPos) -- 纹章的种族图标node的位置(世界空间坐标)
	local cTargetNodePos = curCategoryImgNode:getParent():convertToNodeSpace(oldCategoryImgWorldPos) -- 当前选中种族item的种族图标node要移动到的目标位置(节点空间坐标)

	local curCategoryImgWorldPos = curCategoryImgNode:getParent():convertToWorldSpace(pos) -- 当前选中种族item的种族图标node位置(世界空间坐标)
	local oTargetNodePos = self.oldCategoryNode:getParent():convertToNodeSpace(curCategoryImgWorldPos) -- 纹章的种族图标node要移动到的目标位置(节点空间坐标)

	local act1 = cc.Spawn:create(
		cc.MoveTo:create(moveTime, cTargetNodePos),
		cc.ScaleTo:create(moveTime, 0.5, 0.5)
	)
	local act2 = cc.Spawn:create(
		cc.MoveTo:create(moveTime, oTargetNodePos),
		cc.ScaleTo:create(moveTime, 0.65, 0.65)
	)

	curCategoryImgNode:runAction(act1)
	self.oldCategoryNode:runAction(act2)

	local finishAction = cc.Sequence:create(
		cc.CallFunc:create(function()
			self.cItemSelectedCtrls[self.lastIdx]:setSelectedIndex(0)
		end),
		cc.DelayTime:create(moveTime + 0.1),
		cc.CallFunc:create(function()
			-- 恢复位置和大小
			curCategoryImgNode:setPosition(pos)
			self.oldCategoryNode:setPosition(self.oldCategoryImgPos)
			curCategoryImgNode:setScale(1)
			self.oldCategoryNode:setScale(0.4)
			-- 切换按钮
			self.pageCtrl:setSelectedIndex(0)
			self.bPlayRecastAnimation = false
		end)
	)
	self.actNode:runAction(finishAction)
end

function EmblemRecastView:closeView()
	ViewManager.close("EmblemRecastView")
end
function EmblemRecastView:_exit()
end
return EmblemRecastView