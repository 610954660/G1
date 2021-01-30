-- added by wyz
-- 特权购买

local PriviligeGiftView = class("PriviligeGiftView",Window)


function PriviligeGiftView:ctor()
	self._packName = "PriviligeGift" 		-- 资源包
	self._compName = "PriviligeGiftView" 	-- 资源组件
	self.list_page = false 					-- 特权列表
end

function PriviligeGiftView:_initUI()
	-- 特权列表
	self.list_page = self.view:getChildAutoType("list_page")
	RedManager.updateValue("V_PRIVILIGEGIFT", false)
end

function PriviligeGiftView:_initEvent()
	-- PriviligeGiftModel:requestPriviligeGiftData()
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("PriviligeGiftView_isShow"..dayStr, true)
	PriviligeGiftModel:updateRed()
	self:PriviligeGift_upGiftData()
end

function PriviligeGiftView:setListCell()
	local data = PriviligeGiftModel:getShowData()
	--printTable(8848,"data",data)
	self.list_page:setVirtual()
	self.list_page:setItemRenderer(function(idx,obj)
		-- LuaLogE("**********************************************************")
		-- LuaLogE(idx)
		local d = data[idx+1] 		-- 单个礼包的数据
		local txt_giftName  = obj:getChildAutoType("txt_giftName") 	-- 礼包名
		local txt_limitTime = obj:getChildAutoType("txt_limitTime") -- 礼包限制类别
		local txt_giftDec 	= obj:getChildAutoType("txt_giftDec") 	-- 礼包介绍
		local txt_price 	= obj:getChildAutoType("txt_price")		-- 礼包价格
		local btn_buy 		= obj:getChildAutoType("btn_buy")		-- 购买按钮
		local effectLoader 	= obj:getChildAutoType("effectLoader")	-- 购买按特效
		local ctrl 			= obj:getController("c1") 				-- 控制器 0 未购买 1已购买
		local buyTypeCtrl 	= obj:getController("buyType") 			-- 1 钻石	2 现金
		local mustBuyCtrl   = obj:getController("c2")               -- 0 隐藏 1 显示必买
		local list_prop 	= obj:getChildAutoType("list_prop") 	-- 奖励列表
		local redDot 		= obj:getChildAutoType("img_red") 		-- 红点
		local str 			= PriviligeGiftModel.setStaticDataDec(d.dec)
		local icon 			= obj:getChildAutoType("icon") 	

		icon:setURL("Icon/Privilige/" .. d.iconShow ..".png")
		txt_giftName:setText(d.giftName)
		txt_giftDec:setText(str)
		buyTypeCtrl:setSelectedIndex(d.buyType)
		if d.buyType == 1 then
			txt_price:setText(d.price)
		else
			txt_price:setText(string.format(Desc.privilege_price,d.price))
		end
		txt_limitTime:setText(d.uiType)

		btn_buy:setTouchable(d.limitNum >= d.buyTime)
		ctrl:setSelectedIndex(d.limitNum >= d.buyTime and 0 or 1)
		-- if (d.limitNum >= d.buyTime) then
		-- 	mustBuyCtrl:setSelectedIndex(1);
		-- else
		-- 	mustBuyCtrl:setSelectedIndex(0);
		-- end
		mustBuyCtrl:setSelectedIndex(d.id == 1 and 1 or 0);
		list_prop:setItemRenderer(function(idx2,obj2)
			local dd 	= d.giftItem[idx2+1]
			local item 	= BindManager.bindItemCell(obj2)
			item:setData(dd.code,dd.amount,dd.type)
			item:setIsHook(d.limitNum < d.buyTime)
		end)
		list_prop:setNumItems(#d.giftItem)
		
		effectLoader:displayObject():removeAllChildren()
		if d.id == 1 and d.limitNum >= d.buyTime then 
			SpineUtil.createSpineObj(effectLoader, vertex2(0,0), "animation", "Spine/ui/tequan", "vipt_tequan", "vipt_tequan",true)
		end
		btn_buy:removeClickListener(888)
		btn_buy:addClickListener(function()
			ViewManager.open("PriviligeGiftTipsView",d)
			-- local info 	= {}
			-- info.text 	 = string.format(Desc.privilege_btnBuyTip,d.price,d.giftName,d.limitNum)
			-- info.type 	 = "yes_no"
			-- info.onYes = function()
			-- 	local req = {
			-- 		id = d.id,
			-- 	}
			-- 	RPCReq.Privilege_BuyPrivilege(req, function(param)
			-- 		if not param.result then
			-- 			RollTips.show(Desc.privilege_failure)
			-- 		end
			-- 	end)
			-- end
			-- Alert.show(info)
		end,888)
	end)
	self.list_page:setNumItems(#data) --#data 
end

-- 监听方法 实时刷新数据
function PriviligeGiftView:PriviligeGift_upGiftData()
	-- PriviligeGiftModel:updateRed()
	self:setListCell()
end

return PriviligeGiftView