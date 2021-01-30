--道具tips
--added by wyang
local ItemTipsBtnPanel = class("ItemTipsBtnPanel",View)
function ItemTipsBtnPanel:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsBtnPanel"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = false
   
	
	self.list_btns = false
	
	self._data = args.data
	self._btnData = {}
end

function ItemTipsBtnPanel:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsBtnPanel:_initUI( ... )
	self.list_btns = self.view:getChildAutoType("list_btns")
	
	self.list_btns:setItemRenderer(function (index,obj)
			local data = self._btnData[index + 1]
			obj:setTitle(data.title)
			obj:removeClickListener(333)
			obj:addClickListener(function ( ... )
				self:onClick(data.name)
			end,333)
		end)
	print(1,self._data)
	local itemInfo = self._data:getItemInfo()
	if self._data:getBagType() == GameDef.BagType.Normal or self._data:getBagType() == GameDef.BagType.Special  then
		
		if itemInfo.useType ~= 0 then
			table.insert(self._btnData, {name = "shiyongBtn", title = Desc.itemtips_btnUse})
		end
		if itemInfo.sell == 1 then
			--table.insert(self._btnData, {name = "sellBtn", title = "出售"})  --暂时不做出售功能，因为具体功能里都有分解了
		end
		if #itemInfo.source > 0 then
			table.insert(self._btnData, {name = "laiyuanBtn", title = Desc.itemtips_btnSource})
		end
	elseif self._data:getBagType() == GameDef.BagType.Equip then
		if itemInfo.useType ~= 0 then
			table.insert(self._btnData, {name = "shiyongBtn", title = Desc.itemtips_btnWear})
		end
		if #itemInfo.source > 0 then
			table.insert(self._btnData, {name = "laiyuanBtn", title = Desc.itemtips_btnSource})
		end
	elseif self._data:getBagType() == GameDef.BagType.HeroComponent then
		if itemInfo.useType ~= 0 then
			table.insert(self._btnData, {name = "hechengBtn", title = Desc.itemtips_btnCompose})
		end
		if #itemInfo.source > 0 then
			table.insert(self._btnData, {name = "laiyuanBtn", title = Desc.itemtips_btnSource})
		end
	end
	
	self.list_btns:setData(self._btnData)
	self.list_btns:resizeToFit(self.list_btns:getNumItems())
end

function ItemTipsBtnPanel:onClick(itemName)
	local itemInfo = self._data:getItemInfo()
	if(itemName == "fenjieBtn") then
		ViewManager.open("BagSplitView",self._data)
		ViewManager.close("ItemTips")
	elseif(itemName == "laiyuanBtn") then
		ViewManager.open("ItemNotEnoughView", {type = 3, code = itemInfo.code, amount = 1})
		ViewManager.close("ItemTips")
	elseif(itemName == "sellBtn") then
		ViewManager.open("ItemTipsItemSellView",self._data)
		ViewManager.close("ItemTips")	
	elseif(itemName == "shiyongBtn") then
		
		if itemInfo.useType == 1 or itemInfo.useType == 3 then
			--直接使用一个，调用使用接口
			local params = {}
			 params.bagType =self._data:getBagType()
			 params.itemId = self._data:getItemId()
			 params.amount = 1
			 params.onSuccess = function( res )
				print(1,res)
			 end
			 RPCReq.Bag_UseItem(params, params.onSuccess)
		elseif itemInfo.useType == 2 or itemInfo.useType == 5 then
			ViewManager.open("ItemTipsItemUseView", self._data)
		elseif itemInfo.useType == 4 then
			--特殊处理 门票打开竞技场
		    if itemInfo.jump~="" then
		    	ModuleUtil.openModule(itemInfo.jump,true)
			elseif self._data:getItemCode() ==10000006 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self._data:getItemCode() ==10000007 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self._data:getItemCode() ==10000014 then
				--ViewManager.open("ArenaPerformView")
				ModuleUtil.openModule(ModuleId.Arena)
			elseif (self._data:getItemCode() >=10000008 and self._data:getItemCode() <=10000012) or (self._data:getItemCode() >=10000017 and self._data:getItemCode() <=10000020) then
				--ViewManager.open("EquipmentforgeView",{page = 0})
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self._data:getItemCode() ==10000013 then
				ModuleUtil.openModule(ModuleId.Hero)
				--ViewManager.open("EquipmentforgeView",{page = 0})
			elseif self._data:getItemCode() ==10000021 then
				ModuleUtil.openModule(ModuleId.Maze)
			elseif self._data:getItemCode() ==10000066 then
				ModuleUtil.openModule(ModuleId.Elves_Upgrade)
		   elseif self._data:getItemCode() >=20001101 and self._data:getItemCode() <=20004227 then
				--ViewManager.open("CardBagView")
				ModuleUtil.openModule(ModuleId.Hero)
			elseif itemInfo.type ==  GameDef.ItemType.HeroTicket then --召唤券
				if self._data:getItemCode() ==10000004 then --普通GetCard
					--ViewManager.open("GetCardsView",{page=1})
					ModuleUtil.openModule(ModuleId.GetCard,{page=1})
				elseif self._data:getItemCode() ==10000005 then--高级
					ModuleUtil.openModule(ModuleId.GetCard,{page=2})
				elseif self.itemData:getItemCode() ==10000053 then--特异
					ModuleUtil.openModule(ModuleId.GetCard,{page=3})
				end
			elseif itemInfo.type == GameDef.ItemType.FairyLandItem then
				--秘境随机道具
				--ViewManager.open("FairyLandView")
				ModuleUtil.openModule(ModuleId.FairyLand.id)
			elseif itemInfo.type == GameDef.ItemType.FairyLandItemEx then
				--秘境手动道具
				ModuleUtil.openModule(ModuleId.FairyLand.id, true, {type = GameDef.ItemType.FairyLandItemEx})
				--ViewManager.open("FairyLandView", {type = GameDef.ItemType.FairyLandItemEx})
			end
		end
		ViewManager.close("ItemTips")		
	elseif(itemName == "chouzhuBtn") then
		 print(1,"重铸按钮被点击")
		 local params = {}
		 params.bagType = self._data:getBagType()
		 params.itemId = self._data:getItemId()
		 params.onSuccess = function( res )
			print(1,res)
		 end
		 RPCReq.Bag_RecastItem(params, params.onSuccess)
		ViewManager.close("ItemTips")	
	elseif(itemName == "hechengBtn") then
		local itemInfo = self._data:getItemInfo()
		local comCode=self._data.__data.code;
		local _hasNum=self._data.__data.amount;
		local itemCom= DynamicConfigData.t_heroCombine[comCode] 
		local _needNum=0
		if itemCom then
			_needNum=itemCom.amount;
		end
		printTable(8,"合成按钮被点击",self._data,_hasNum,_needNum)
			
		if _hasNum<_needNum then
			RollTips.show(DescAuto[322]) -- [322]='数量不足,无法合成'
		elseif _hasNum >=_needNum then
			if itemInfo.useType == 1 then --只合成一组
				ModelManager.CardLibModel:combineCard(comCode,1)
			else
				--可以选择合成多少组(至少要能合成一组才打开窗口)
				ViewManager.open("CardCombineSureView",self._data)
			end
		end
		ViewManager.close("ItemTips")
	end
	
end

-- [子类重写] 准备事件
function ItemTipsBtnPanel:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsBtnPanel:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsBtnPanel:_exit()
end


return ItemTipsBtnPanel
