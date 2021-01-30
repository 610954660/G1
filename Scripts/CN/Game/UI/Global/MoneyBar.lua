--added by wyang
--道具框封裝
--local MoneyBar = class("MoneyBar")
local MoneyBar,Super = class("MoneyBar",BindView)

function MoneyBar:ctor(view)
	self.list_money = false
	self.showMoneyType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
		} --显示的货币类型，从左到右排列
end


function MoneyBar:_initUI( ... )
	self.list_money = self.view:getChildAutoType("list_money")
	self.list_money:setItemRenderer(
		function(index, obj)
			local type = self.showMoneyType[index + 1].type
			local code = self.showMoneyType[index + 1].code
			local iconType = self.showMoneyType[index + 1].iconType or type;
			local addBtnCtrl = obj:getController("c1")
			local img_red = obj:getChildAutoType("btn_add/img_red")
			local redType = ""
			local mid  = 0
			if type == GameDef.ItemType.Money and code == GameDef.MoneyType.Diamond then
				addBtnCtrl:setSelectedIndex(0)
				local btn_add = obj:getChildAutoType("btn_add")
				btn_add:removeClickListener()
				btn_add:addClickListener(function(context)
					if code == GameDef.MoneyType.Diamond then
						ModuleUtil.openModule(ModuleId.Recharge.id)
					end
				end)
			elseif type ==  GameDef.ItemType.Money and code == GameDef.MoneyType.Gold then
				redType = "M_GOLDTREE"
				mid = ModuleId.GoldTree.id
				addBtnCtrl:setSelectedIndex(0)
				local btn_add = obj:getChildAutoType("btn_add")
				btn_add:removeClickListener()
				btn_add:addClickListener(function(context)
					if code == GameDef.MoneyType.Gold then
						ModuleUtil.openModule(ModuleId.GoldTree.id);
					end
				end)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.HeroScore then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.GuildMoney then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.EndlessRoad then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.Maze then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.SpecialCoin then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.PvpCoin then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.Detective then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.HigherPvpCoin then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.Money and code == GameDef.MoneyType.GuildPackScore then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,type)
			elseif type == GameDef.ItemType.HeroComponent and code == 10000054 then
				addBtnCtrl:setSelectedIndex(0)
				self:jumpSource(obj,code,GameDef.GameResType.Item)
			elseif type == GameDef.GameResType.Item and code == 10000017 then
				addBtnCtrl:setSelectedIndex(0)
				local btn_add = obj:getChildAutoType("btn_add")
				btn_add:removeClickListener()
				btn_add:addClickListener(function(context)
					ViewManager.close("EquipmentforgeView")
					ModuleUtil.openModule(ModuleId.EquipmentDecompose.id);
				end)
			elseif type == GameDef.GameResType.Item and code == 10000120 then
				addBtnCtrl:setSelectedIndex(0)
				local btn_add = obj:getChildAutoType("btn_add")
				btn_add:removeClickListener()
				btn_add:addClickListener(function(context)
					ViewManager.open("GLOLExchangeView")
				end)
			else
				local cost = {type = type, code = code, amount = 0}
				local itemInfo = ItemConfiger.getInfoByCode(cost.code, GameDef.GameResType.Item)
				if itemInfo and #itemInfo.source ~= 0 then
					addBtnCtrl:setSelectedIndex(0)
					local btn_add = obj:getChildAutoType("btn_add")
					btn_add:removeClickListener()
					btn_add:addClickListener(function(context)
						ViewManager.open("ItemNotEnoughView", cost)
					end)
				else
					addBtnCtrl:setSelectedIndex(1)
				end
			end
			RedManager.register(redType, img_red, mid)
			if type == GameDef.ItemType.Money then
				obj:getChildAutoType("title"):setText(MathUtil.toSectionStr(ModelManager.PlayerModel:getMoneyByType(code)))
			else
				local config = DynamicConfigData.t_item[code]
				if config then
					obj:getChildAutoType("title"):setText(MathUtil.toSectionStr(ModelManager.PackModel:getItemsFromAllPackByCode(code)))
				end
			end
			local costIcon = BindManager.bindCostIcon(obj:getChildAutoType("icon"))
			
			if iconType == GameDef.ItemType.Money then
				--:setURL(PathConfiger.getMoneyIcon(code))
				costIcon:setData(CodeType.MONEY, code)
			else
				--local url = ItemConfiger.getItemIconByCode(code, type,true)
				--local url = PathConfiger.getItemIcon(config.icon)
				--obj:getChildAutoType("icon"):setURL(url)
				costIcon:setData(CodeType.ITEM, code)
			end
		end
	)
	self:money_change()
end

function MoneyBar:setData(typeList)
    self.showMoneyType = typeList
	self:money_change()
end



function MoneyBar:money_change(_,data)
	if not tolua.isnull(self.list_money) then
		self.list_money:setNumItems(#self.showMoneyType)
		self.list_money:resizeToFit(#self.showMoneyType)
	end
end

function MoneyBar:pack_herocomp_change(_,data)
	self:money_change()
end

function MoneyBar:pack_item_change(_,data)
	self:money_change()
end

function MoneyBar:pack_equip_change(_,data)
	self:money_change()
end

function MoneyBar:pack_special_change(_,data)
	self:money_change()
end


--退出操作 在close执行之前 
function MoneyBar:_onExit()
    print(1,"MoneyBar __onExit")
end

-- 货币获取途径
function MoneyBar:jumpSource(obj,code,type)
	local btn_add = obj:getChildAutoType("btn_add")
	btn_add:removeClickListener()
	btn_add:addClickListener(function(context)
		local cost = {
			code = code,
			type = type,
		}
		ViewManager.open("ItemNotEnoughView", cost)
	end)
end

return MoneyBar