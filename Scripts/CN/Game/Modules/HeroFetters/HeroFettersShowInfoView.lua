local HeroFettersShowInfoView,Super = class("HeroFettersShowInfoView", Window)

function HeroFettersShowInfoView:ctor(data,obj)
	self._packName = "HeroFetters"
	self._compName = "HeroFettersShowInfoView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self._args = data
	self.severData = HeroFettersModel:getSeverData()[self._args.id]
end

function HeroFettersShowInfoView:_initEvent()
	
end

function HeroFettersShowInfoView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:HeroFetters.HeroFettersShowInfoView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_change = viewNode:getChildAutoType('btn_change')--leftBtn
		self.btn_change.icon1 = viewNode:getChildAutoType('btn_change/icon1')--GLoader
		self.btn_change.str = viewNode:getChildAutoType('btn_change/str')--GRichTextField
	self.btn_change1 = viewNode:getChildAutoType('btn_change1')--leftBtn
		self.btn_change1.icon1 = viewNode:getChildAutoType('btn_change1/icon1')--GLoader
		self.btn_change1.str = viewNode:getChildAutoType('btn_change1/str')--GRichTextField
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.group = viewNode:getChildAutoType('group')--group
		self.group.itemCell1 = viewNode:getChildAutoType('group/itemCell1')--GComponent
		self.group.itemCell2 = viewNode:getChildAutoType('group/itemCell2')--GComponent
		self.group.itemCell3 = viewNode:getChildAutoType('group/itemCell3')--GComponent
		self.group.rightList = viewNode:getChildAutoType('group/rightList')--GList
		self.group.strList = viewNode:getChildAutoType('group/strList')--GList
	self.leftItem = viewNode:getChildAutoType('leftItem')--heroItem
		self.leftItem.img1 = viewNode:getChildAutoType('leftItem/img1')--GLoader
		self.leftItem.img2 = viewNode:getChildAutoType('leftItem/img2')--GLoader
		self.leftItem.img3 = viewNode:getChildAutoType('leftItem/img3')--GLoader
		self.leftItem.img4 = viewNode:getChildAutoType('leftItem/img4')--GLoader
		self.leftItem.img_red = viewNode:getChildAutoType('leftItem/img_red')--GImage
		self.leftItem.name = viewNode:getChildAutoType('leftItem/name')--GRichTextField
		self.leftItem.starList = viewNode:getChildAutoType('leftItem/starList')--GList
	self.nextReward = viewNode:getController('nextReward')--Controller
	self.yy1 = viewNode:getChildAutoType('yy1')--GImage
	self.yy2 = viewNode:getChildAutoType('yy2')--GImage
	--{autoFieldsEnd}:HeroFetters.HeroFettersShowInfoView
	--Do not modify above code-------------
end

function HeroFettersShowInfoView:_initUI()
	self:_initVM()

	self.changeIndex = self.group:getController("changeIndex")
	self.group.strList:setItemRenderer(function(index,obj)
		obj:getChild("storyStr"):setText(self._args.story)
		local size = obj:getChild("storyStr"):getSize()
		obj:setSize(size.width,size.height)
	end)
	self.group.strList:setNumItems(1)
	self.group.rightList:setItemRenderer(function(index,obj)
		local conditionsIndex = self._args.conditions[index + 1]
		local data = DynamicConfigData.t_HeroFetterCondition[conditionsIndex]
		obj:getChild("str1"):setText(data.conDesc)
		local curNum = self.severData and self.severData.condition[conditionsIndex].curNum or 0
		local maxNum = table.nums(self._args.fetterGroup)
		obj:getChild("incomeList"):setItemRenderer(function(index,obj1)
			local id = data.income[index + 1]
			local attrName = DynamicConfigData.t_combat[id.key].name
			attrName = string.gsub(attrName," ","")
			if id.key < 100 then
				obj1:getChild("str2"):setText(attrName .. string.format(Desc.HeroFettersDesc1,id.value))
			else
				obj1:getChild("str2"):setText(attrName .. string.format(Desc.HeroFettersDesc1,id.value / 100) .."%")
			end
			if curNum >= maxNum then
				obj1:getController("state"):setSelectedIndex(1)
			end
		end)
		obj:getChild("incomeList"):setData(data.income)

		local costItem = BindManager.bindCostItem(obj:getChild("btn_gold"))
		costItem:setNoTips(true)
		obj:getChild("btn_gold"):addClickListener(function()
			RPCReq.HeroFetter_GetConditionReward({groupId = self._args.id  ,conditionId = self._args.conditions[index + 1]},function(data)
			end)
		end,99)
		local reward = data.reward[1]
		costItem:setIconType("item")
		costItem:setData(reward.type, reward.code, reward.amount,true,false,true)
		obj:getChild("percent"):setText("0".."/"..table.nums(self._args.fetterGroup))
		if self.severData and self.severData.condition then
			obj:getChild("percent"):setText(curNum.."/"..maxNum)
			if curNum >= maxNum then
				obj:getController("stateIndex"):setSelectedIndex(1)
				obj:getChild("btn_gold"):getChild("img_red"):setVisible(true)
			end
			if self.severData and self.severData.condition[conditionsIndex].hasGotReward then
				obj:getController("alreadyHas"):setSelectedIndex(1)
			end
		end
	end)
	self.group.rightList:setData(self._args.conditions)
	local function scaleAction(index)
		local node = self.group:displayObject()
		node:stopAllActions()
		local arr = {}
		table.insert(arr,cc.ScaleTo:create(0.05,0,1))
		table.insert(arr,cc.DelayTime:create(0.05))
		table.insert(arr,cc.CallFunc:create(function()
			self.changeIndex:setSelectedIndex(index)
		end))
		table.insert(arr,cc.ScaleTo:create(0.05,1,1))
		node:runAction(cc.Sequence:create(arr))
		if index == 0 then
			self.btn_change:getController("state"):setSelectedIndex(3)
			self.btn_change1:getController("state"):setSelectedIndex(0)
			self.btn_change:setSortingOrder(99)
			self.yy2:setSortingOrder(99)
			self.yy1:setSortingOrder(100)
		else
			self.btn_change:getController("state"):setSelectedIndex(2)
			self.btn_change1:getController("state"):setSelectedIndex(1)
			self.btn_change:setSortingOrder(101)
			self.yy1:setSortingOrder(99)
			self.yy2:setSortingOrder(100)
		end
	end
	self.btn_change1:setSortingOrder(100)
	
	
	self.btn_change:getController("state"):setSelectedIndex(3)
	self.btn_change1:getController("state"):setSelectedIndex(0)
	self.btn_change:addClickListener(function()
		local index = self.changeIndex:getSelectedIndex()
		if index== 1 then return end
		scaleAction(1)
	end)
	self.btn_change1:addClickListener(function()
		local index = self.changeIndex:getSelectedIndex()
		if index== 0 then return end
		scaleAction(0)
	end)
	
	local item = require"Game.Modules.HeroFetters.ItemHandle".new(self.leftItem)
	item:setData(self._args)

	for key,value in pairs(self._args.fetterGroup) do
		local heroCell = BindManager.bindHeroCell(self.group["itemCell"..key])
		heroCell.view:getController("levelCtr"):setSelectedIndex(1)
		local config = DynamicConfigData.t_hero[value]
		local showData = {}
		showData.code = value
		showData.level = 100
		showData.star = (self.severData and self.severData.hero[value]) and self.severData.hero[value].highestStar or 5
		showData.category = config.category
		heroCell:setData(showData)
		if self.severData and self.severData.hero[value] then
		else
			heroCell.grayCtrl:setSelectedIndex(2)
		end
	end
	if table.nums(self._args.fetterGroup) == 2 then
		self.group:getController("heroNum"):setSelectedIndex(1)
	end
	self:_refreshView()
end

function HeroFettersShowInfoView:refresh_HeroFettersShow()
	self.severData = HeroFettersModel:getSeverData()[self._args.id]
	self.group.rightList:setData(self._args.conditions)
end
function HeroFettersShowInfoView:_refreshView()

end

function HeroFettersShowInfoView:onExit_()

end

return HeroFettersShowInfoView