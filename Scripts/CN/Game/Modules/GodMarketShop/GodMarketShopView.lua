local GodMarketShopView, Super = class("GodMarketShopView", Window)
function GodMarketShopView:ctor(args)
	self._packName = "GodMarketShop"
	self._compName = "GodMarketShopView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.severData = {}
	self.buyRecords = {}
	self.actShopData = false
	
	self.activityType = GameDef.ActivityType.GodMarketShop
	self.config = DynamicConfigData.t_GodMarketStore
end

function GodMarketShopView:_initUI()
	GodMarketShopModel:onViewOpen()

	self.shopList = self.view:getChildAutoType("list_goods")
	self.shopList:setItemRenderer(handler(self,self.shopListHandle))
	self.costItem = self.view:getChildAutoType("costItem")
	self.txt_price = self.view:getChildAutoType("txt_price")
	
	self.act_dhtime = self.view:getChildAutoType("txt_countdowm")
	self:refushInit()
end

function GodMarketShopView:refushInit()
	self.severData = GodMarketShopModel:getShopData()
	local actData = ModelManager.ActivityModel:getActityByType(self.activityType)
	self.moduleId = actData and actData.showContent.moduleId or 1

	self.showData = self.config[self.moduleId]
	self.buyRecords = self.severData.buyRecords or {}
	self.shopList:setData(self.showData)
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
	end
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
	self.actShopData = ModelManager.ActivityModel:getActityByType(self.activityType) or false
	if not self.actShopData then return end
	self.act_dhtime:setText(StringUtil.formatTime(math.floor(self.actShopData.realEndMs / 1000 - ServerTimeModel:getServerTimeMS() / 1000),"d",Desc.common_TimeDesc))
	
	local num = ModelManager.PlayerModel:getMoneyByType(self.showData[1].price[1].code)
	local costItem = BindManager.bindCostItem(self.costItem)
	costItem:setGreenColor( "#FFFFFF")
    costItem:setData(self.showData[1].price[1].type,self.showData[1].price[1].code,num,false,true)
end
function GodMarketShopView:update()
	self.act_dhtime:setText(StringUtil.formatTime(math.floor(self.actShopData.realEndMs / 1000 - ServerTimeModel:getServerTimeMS() / 1000),"d",Desc.common_TimeDesc))
end

function GodMarketShopView:shopListHandle(index,obj)
	local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
	local itemData = ItemsUtil.createItemData({data = self.showData[index  + 1].reward[1]})
	itemcell:setItemData(itemData)

	local costItem = BindManager.bindCostItem(obj:getChildAutoType("costItem"))
	local price = self.showData[index  + 1].price[1]
	costItem:setGreenColor( "#FFFFFF")
    costItem:setData(price.type,price.code,price.amount,true)
	
	local reward = self.showData[index  + 1].reward[1]
	local name = obj:getChildAutoType("txt_shengyu")
    local item = DynamicConfigData.t_item[reward.code]
    name:setText(ItemConfiger.getItemNameByCode(reward.code))
    if item.color == 1 then
        name:setColor(cc.c3b(69,69,69))
    else
        name:setColor(ColorUtil.getItemColor(item.color))
    end
	local count = self.buyRecords[index + 1] and self.buyRecords[index + 1].count or 0
	local num = self.showData[index + 1].limit - count
	obj:getChildAutoType("txt_limitTimes"):setText(string.format(Desc.shop_shengyu1,num))

	obj:addClickListener(function()
		local refreshCallBack = function ()
			self:refushInit()
		end
		ViewManager.open("GodMarketShopTipsView", {activityType = self.activityType, refreshCallBack =refreshCallBack,  showData = self.showData[index + 1],buyRecords = self.severData.buyRecords[index + 1]})
	end,99)
	if num <= 0 then
		obj:getController("soldCtrl"):setSelectedIndex(1)
	else
		obj:getController("soldCtrl"):setSelectedIndex(0)
	end
	--折扣显示(如果没配这个字段就不显示了)
	if self.showData[index + 1].discount then
		obj:getChildAutoType("zhekou"):setVisible(self.showData[index + 1].discount ~= 10)
		obj:getChild("txt_desc"):setText(string.format(Desc.shop_zhe2,self.showData[index + 1].discount))
	else
		obj:getChildAutoType("zhekou"):setVisible(false)
	end
end
function GodMarketShopView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end
return GodMarketShopView