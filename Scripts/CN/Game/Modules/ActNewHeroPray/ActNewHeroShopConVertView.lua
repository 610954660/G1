--Date :2021-01-28
--Author : added by xhd
--Desc : 新英雄皮肤售卖

local ActNewHeroShopConVertView,Super = class("ActNewHeroShopConVertView", Window)
function ActNewHeroShopConVertView:ctor()
	--LuaLog("ActNewHeroShopConVertView ctor")
	self._packName = "ActCommonBoss"
	self._compName = "ActCommonShopConVertView"
	--self._rootDepth = LayerDepth.Window
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self.severData = {}
	self.buyRecords = {}
	self.actShopData = false
end

function ActNewHeroShopConVertView:_initUI()
	if RedManager.getTips("V_ACTIVITY_" .. GameDef.ActivityType.NewHeroSummonExchange) then
		local dayStr = DateUtil.getOppostieDays()
		FileCacheManager.setBoolForKey("setActConvertShopRedFirst_isShow" .. dayStr, true)
		ActNewHeroPrayModel:setActConvertShopRedFirst()
	end

	self.shopList = self.view:getChildAutoType("list_goods")
	self.shopList:setItemRenderer(handler(self,self.shopListHandle))
	self.costItem = self.view:getChildAutoType("costItem")
	self.txt_price = self.view:getChildAutoType("txt_price")
	
	self.act_dhtime = self.view:getChildAutoType("txt_countTimer")

	self.config = DynamicConfigData.t_NewHeroStoreConfig

	self.banner = self.view:getChildAutoType("banner")
	self.banner:setURL("UI/TwistEgg/img_shop_banner.png")
    self.view:getChildAutoType("titleImg"):setURL("UI/activity/newHero/title.png")
	self:refushInit()
end

function ActNewHeroShopConVertView:refushInit()
	self.severData = ActNewHeroPrayModel:getExchangeShopData()
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewHeroSummonExchange)
	self.moduleId = ActNewHeroPrayModel:getConVertModuleId()

	self.showData = self.config[self.moduleId]
	self.buyRecords = self.severData.buyRecords or {}
	self.shopList:setData(self.showData)
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
	end
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
	self.actShopData = ActNewHeroPrayModel:getActData()
	self.act_dhtime:setText(StringUtil.formatTime(math.floor(self.actShopData.realEndMs / 1000 - ServerTimeModel:getServerTimeMS() / 1000),"d",Desc.common_TimeDesc))
	
	local num = ModelManager.PlayerModel:getMoneyByType(self.showData[1].price[1].code)
	local costItem = BindManager.bindCostItem(self.costItem)
	costItem:setGreenColor( "#FFFFFF")
    costItem:setData(self.showData[1].price[1].type,self.showData[1].price[1].code,num,false,true)
end
function ActNewHeroShopConVertView:update()
	self.act_dhtime:setText(StringUtil.formatTime(math.floor(self.actShopData.realEndMs / 1000 - ServerTimeModel:getServerTimeMS() / 1000),"d",Desc.common_TimeDesc))
end
function ActNewHeroShopConVertView:NewHeroPray_updateConvertView()
	self:refushInit()
end
function ActNewHeroShopConVertView:shopListHandle(index,obj)
	local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
	local itemData = ItemsUtil.createItemData({data = self.showData[index  + 1].reward[1]})
	itemcell:setItemData(itemData)

	local costItem = BindManager.bindCostItem(obj:getChildAutoType("costItem"))
	local price = self.showData[index  + 1].price[1]
	costItem:setGreenColor( "#6AFF60")
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
		ViewManager.open("ActNewHeroShopTipsView", {showData = self.showData[index + 1],buyRecords = self.buyRecords[index + 1]})
	end,99)
	if num <= 0 then
		obj:getController("soldCtrl"):setSelectedIndex(1)
	else
		obj:getController("soldCtrl"):setSelectedIndex(0)
	end
	obj:getChildAutoType("zhekou"):setVisible(false)
	-- obj:getChildAutoType("zhekou"):setVisible(self.showData[index + 1].discount ~= 10)
	-- obj:getChild("txt_desc"):setText(string.format(Desc.shop_zhe2,self.showData[index + 1].discount))
end
function ActNewHeroShopConVertView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end
return ActNewHeroShopConVertView