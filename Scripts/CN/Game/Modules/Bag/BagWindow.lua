--added by xhd 背包系统
local BagWindow,Super = class("BagWindow",Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local PackConfiger = require "Game.ConfigReaders.PackConfiger"
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
local lastInterTime = 0.1
local maxInterTime = 0.5
function BagWindow:ctor( ... )
	self._packName = "Bag"
	self._compName = "BagView"
	self.bagTypeCtrl = false
	self.bagList1 = false
	self.bagList2 = false
	self.bagList3 = false
	self.bagList4 = false
	self.bagList5 = false
	
	self.listData1 = false
	self.listData2 = false
	self.listData3 = false
	self.listData4 = false
	self.listData5 = false

	self._isFullScreen = true
	self._showParticle = true
	self._willOpenInBattle=true --如果战斗中打开要减慢速度
	
	self.itemcellArrs = false
	self.list_type = false
	
	self.cur_type = 0 --当前选择的类型

	self.schedulerArr = {}

	self.aniFlagArr = {false,false,false,false,false}
	
	--按钮上的红点数据
	self.redTypes = {
		{redType="V_BAG_NOR", moduleId = ModuleId.Bag.id},
		{redType="V_BAG_EQUIP", moduleId = ModuleId.Bag_Equip.id},
		{redType="V_BAG_SPECIAL", moduleId = ModuleId.Bag_Spec.id},
		{redType="V_BAG_HEROCOMP", moduleId = ModuleId.Bag_Split.id},
		{redType="V_BAG_JEWELRY", moduleId = ModuleId.Bag_Jwerly.id},
	}
end

-------------------常用------------------------
--UI初始化
function BagWindow:_initUI( ... )
	self.bagTypeCtrl = self.view:getController("bagTypeCtrl")
	self.bagList1 = FGUIUtil.getChild(self.view,"bagList1","GList")
	self.bagList2 = FGUIUtil.getChild(self.view,"bagList2","GList")
	self.bagList3 = FGUIUtil.getChild(self.view,"bagList3","GList")
	self.bagList4 = FGUIUtil.getChild(self.view,"bagList4","GList")
	self.bagList5 = self.view:getChildAutoType("bagList5");
    self.numVal = self.view:getChildAutoType("numVal")
	
	self.list_type = self.view:getChildAutoType("list_type")
	self.list_type:setItemRenderer(function (index,obj)
		local img_red = obj:getChildAutoType("img_red") --名称
		local redTypeData = self.redTypes[index + 1]
		if(redTypeData) then
			RedManager.register(redTypeData.redType, img_red,redTypeData.moduleId)
		end
		obj:removeClickListener(33)
		obj:addClickListener(function( ... )
			if ModuleUtil.moduleOpen(self.redTypes[index + 1].moduleId, true) then
				self.cur_type = index
				self.bagTypeCtrl:setSelectedIndex(index)
				self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
			else
				self.list_type:setSelectedIndex(self.cur_type)
			end
		end,33)
	end)
	self.list_type:setNumItems(5)

	self.itemcellArrs = {{},{},{},{},{}}
end

--事件初始化
function BagWindow:_initEvent( ... )
	self.bagList1:setVirtual()
	self.bagList1:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[1] = true
		
	end)
	self.bagList1:setItemRenderer(function (index,obj)
		obj:setScale(1,1)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listData1[index+1],CodeType.ITEM, "bag")
		self.itemcellArrs[1][index+1] = itemcell
		local img_red = obj:getChildAutoType("img_red") --名称
		local config = DynamicConfigData.t_item[self.listData1[index+1]:getItemInfo().code]
		local fashionRedDot = false 
		if config.type == GameDef.ItemType.FashioDebris then --时装碎片红点
			local fashionComposeInfo = FashionConfiger.getFashionComposeConfigerByFashionId(config.effect)
			local needNum = fashionComposeInfo and fashionComposeInfo.consume and fashionComposeInfo.consume[1] and fashionComposeInfo.consume[1].amount
			local haveNum = itemcell:getItemData():getItemAmount()
			fashionRedDot = needNum and haveNum >= needNum or false
		end
		local dayStr = DateUtil.getOppostieDays()
		local hasClickToay = FileCacheManager.getBoolForKey("HasClickItem"..config.code.."_"..dayStr,false)  --当天点过这个物品就不能再显示红点了
		local type19Show = config.type ==19 and hasClickToay == false
		img_red:setVisible(config.type == 4 or type19Show  or config.type == GameDef.ItemType.ElfSkin or fashionRedDot)

		local maxNum = #self.listData1<18 and #self.listData1 or 18
        local interTime = maxInterTime/maxNum
        if interTime >= lastInterTime then
        	interTime = lastInterTime
        end
        if not self.aniFlagArr[1] then
        	obj:setVisible(false)
        	self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
	        	    if obj and  (not tolua.isnull(obj)) then
	        	    	obj:setVisible(true)
		        		obj:getTransition("t0"):play(function( ... )
					    end);
	        	    end
	        end)
        end
		
		obj:removeClickListener(33)
		obj:addClickListener(function(context)
			img_red:setVisible(false)
			FileCacheManager.setBoolForKey("HasClickItem"..config.code.."_"..dayStr,true)
		end,33)
	

	end
	)
    
    self.bagList2:setVirtual()
    self.bagList2:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[2] = true
	end)
	self.bagList2:setItemRenderer(function (index,obj)
		obj:setScale(1,1)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listData2[index+1],CodeType.ITEM, "bag")
		self.itemcellArrs[2][index+1] = itemcell
		-- 展示升星进度
		local data = self.listData2[index+1].__data
		local conf = DynamicConfigData.t_equipEquipment[data.code];
		local splitCtrl = obj:getController("splitCtrl");
		splitCtrl:setSelectedIndex(1);
		local img_category = obj:getChildAutoType("img_category")
		local img_categoryBg = obj:getChildAutoType("img_categoryBg")
		if (img_category) then img_category:setVisible(false) end
		if (img_categoryBg) then img_categoryBg:setVisible(false) end
		local progressBar = obj:getChildAutoType("progressBar")
		local need = conf.levelUpExp
		local next = conf.next
		local extraData = data.specialData and data.specialData.equipment or {};
		local extraExp = extraData.starExp or 0;
		local txt_title = progressBar:getChildAutoType("title");
		if (next == 0) then
			progressBar:setMax(1);
			progressBar:setValue(1)
			txt_title:setText(Desc.equipmentforge_str2);
		elseif (need == 0) then
			progressBar:setMax(1);
			progressBar:setValue(1)
			txt_title:setText(Desc.equipmentforge_str1);
		elseif (need > 0) then
			progressBar:setMax(need);
			progressBar:setValue(extraExp)
			local rate = math.ceil(extraExp / need * 10000) / 100;
			txt_title:setText(rate.."%");
		end


		local maxNum = #self.listData2<18 and #self.listData2 or 18
        local interTime = maxInterTime/maxNum
        if interTime >= lastInterTime then
        	interTime = lastInterTime
        end

        if not self.aniFlagArr[2] then
        	obj:setVisible(false)
	        self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
	        	    if obj and  (not tolua.isnull(obj)) then
	        	    	obj:setVisible(true)
		        		obj:getTransition("t0"):play(function( ... )
					    end);
	        	    end
	        end)
        end

	end
	)
	
	self.bagList3:setVirtual()
	self.bagList3:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[3] = true
	end)
	self.bagList3:setItemRenderer(function (index,obj)
		obj:setScale(1,1)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listData3[index+1],CodeType.ITEM, "bag")
		self.itemcellArrs[3][index+1] = itemcell


		if self.listData3[index+1].__itemInfo.type == GameDef.ItemType.HeroCard  then
           obj:getChildAutoType("img_red"):setVisible(true)
		else
           obj:getChildAutoType("img_red"):setVisible(false)
		end

		local maxNum = #self.listData3<18 and #self.listData3 or 18
        local interTime = maxInterTime/maxNum
        if interTime >= lastInterTime then
        	interTime = lastInterTime
		end
		
        if not self.aniFlagArr[3] then
        	 obj:setVisible(false)
	        self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
	        	    if obj and  (not tolua.isnull(obj)) then
	        	    	obj:setVisible(true)
		        		obj:getTransition("t0"):play(function( ... )
					    end);
	        	    end
	        end)
        end

	end
	)
	
	self.bagList4:setVirtual()
	self.bagList4:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[4] = true
	end)
	self.bagList4:setItemRenderer(function (index,obj)
		obj:setScale(1,1)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listData4[index+1],CodeType.ITEM, "bag")
		local itemCode = itemcell:getItemData():getItemCode()
		if itemcell:getItemData():getItemAmount()>=DynamicConfigData.t_heroCombine[itemCode].amount then
           obj:getChildAutoType("img_red"):setVisible(true)
		else
           obj:getChildAutoType("img_red"):setVisible(false)
		end
		self.itemcellArrs[4][index+1] = itemcell
        
		local maxNum = #self.listData4<18 and #self.listData4 or 18
        local interTime = maxInterTime/maxNum
        if interTime >= lastInterTime then
        	interTime = lastInterTime
		end

        if not self.aniFlagArr[4] then
        	obj:setVisible(false)
	        self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
	        	    if obj and  (not tolua.isnull(obj)) then
	        	    	obj:setVisible(true)
		        		obj:getTransition("t0"):play(function( ... )
					    end);
	        	    end
	        end)
        end

	end
	)

	self.bagList5:setVirtual()
	self.bagList5:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[5] = true
	end)
	self.bagList5:setItemRenderer(function (index,obj)
		obj:setScale(1,1)
		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		itemcell:setItemData(self.listData5[index+1],CodeType.ITEM, "bag")
		-- local itemCode = itemcell:getItemData():getItemCode()
		-- if itemcell:getItemData():getItemAmount()>=DynamicConfigData.t_heroCombine[itemCode].amount then
        --    obj:getChildAutoType("img_red"):setVisible(true)
		-- else
        --    obj:getChildAutoType("img_red"):setVisible(false)
		-- end
		self.itemcellArrs[5][index+1] = itemcell
		-- if self.schedulerArr[index] then
  --       	Scheduler.unschedule(self.schedulerArr[index])
  --       	self.schedulerArr[index] = false
  --       end
       
		local maxNum = #self.listData5<18 and #self.listData5 or 18
		local interTime = maxInterTime/maxNum
		if interTime >= lastInterTime then
			interTime = lastInterTime
		end

        if not self.aniFlagArr[5] then
        	obj:setVisible(false)
        	self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
	        	    if obj and  (not tolua.isnull(obj)) then
	        	    	obj:setVisible(true)
		        		obj:getTransition("t0"):play(function( ... )
					    end);
	        	    end
	        end)
        end

	end
	)
	
	self.bagTypeCtrl:setSelectedIndex(0)
	self:ChangePage(self.bagTypeCtrl:getSelectedIndex())
end

--initEvent后执行
function BagWindow:_enter( ... )
	print(1,"BagWindow _enter")
end

function BagWindow:ChangePage( type )
	for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
	end
	local index = type + 1
	self:updateItem(type)
    self.aniFlagArr[index] = false
    self["bagList"..index]:setSelectedIndex(0)
    if #self["listData"..index] > 0 and self.itemcellArrs[index][1] then
		self.itemcellArrs[index][1]:onClickCell()
	else
		ViewManager.close("ItemTipsBagView")
	end
end

function BagWindow:updateItem( type )
	print(1,"updateItem")
	if (type ~= self.bagTypeCtrl:getSelectedIndex()) then
		return;
	end
	if type==0 then
		self.listData1 = ModelManager.PackModel:getNormalBag():sort_bagDatas()
		self.bagList1:setData(self.listData1)
		self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData1,"/"..PackConfiger.getPackInfoByType(BagType.Normal).maxCapacity))
		-- self.bagList1:setSelectedIndex(0)
		-- if self.itemcellArrs[1] and self.itemcellArrs[1][1] then
		-- 	self.itemcellArrs[1][1]:onClickCell()
		-- else
		-- 	ViewManager.close("ItemTipsBagView")
		-- end
	elseif type==1 then
		self.listData2 = ModelManager.PackModel:getEquipBag():sort_bagDatas()
		self.bagList2:setData(self.listData2)
		self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData2,"/"..PackConfiger.getPackInfoByType(BagType.Equip).maxCapacity))
		-- self.bagList2:setSelectedIndex(0)
		-- if self.itemcellArrs[2] and  self.itemcellArrs[2][1] then
		-- 	self.itemcellArrs[2][1]:onClickCell()
		-- else
		-- 	ViewManager.close("ItemTipsBagView")
		-- end
		
	elseif type==2 then
		self.listData3 = ModelManager.PackModel:getSpecialBag():sort_bagDatas()
		self.bagList3:setData(self.listData3)
		self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData3,"/"..PackConfiger.getPackInfoByType(BagType.Special).maxCapacity))
		-- self.bagList3:setSelectedIndex(0)
		-- if self.itemcellArrs[3] and self.itemcellArrs[3][1] then
		-- 	self.itemcellArrs[3][1]:onClickCell()
		-- else
		-- 	ViewManager.close("ItemTipsBagView")
		-- end
		
	elseif type==3 then
		self.listData4 = ModelManager.PackModel:getHeroCompBag():sort_bagDatas()
		self.bagList4:setData(self.listData4)
		self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData4,"/"..PackConfiger.getPackInfoByType(BagType.HeroComponent).maxCapacity))
		-- self.bagList4:setSelectedIndex(0)
		-- if self.itemcellArrs[4] and self.itemcellArrs[4][1]  then
		-- 	self.itemcellArrs[4][1]:onClickCell()
		-- else
		-- 	ViewManager.close("ItemTipsBagView")
		-- end
	elseif type==4 then
		self.listData5 = ModelManager.PackModel:getJewelryBag():sort_bagDatas()
		self.bagList5:setData(self.listData5)
		self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData5,"/"..PackConfiger.getPackInfoByType(BagType.Jewelry).maxCapacity))
		-- if (self.view:isVisible() and #self.listData5 > 0 and self.itemcellArrs[5][1])  then
		-- 	self.bagList5:setSelectedIndex(0)
		-- 	self.itemcellArrs[5][1]:onClickCell()
		-- else
		-- 	ViewManager.close("ItemTipsBagView")
		-- end
	end
end

--普通道具消息监听方法
function BagWindow:pack_item_change( ... )
	print(1,"pack_item_change")
	self:updateItem(0)
end

--装备道具消息监听方法
function BagWindow:pack_equip_change( ... )
	print(1,"pack_equip_change")
	self:updateItem(1)
end

--装备道具消息监听方法
function BagWindow:equipUpstar_refresh()
	self:updateItem(1)
end

--装备道具消息监听方法
function BagWindow:pack_special_change( ... )
	print(1,"pack_special_change")
	self:updateItem(2)
end

--装备道具消息监听方法
function BagWindow:pack_herocomp_change( ... )
	print(1,"pack_herocomp_change")
	self:updateItem(3)
end

--装备道具消息监听方法
function BagWindow:pack_jewelry_change( ... )
	print(1,"pack_herocomp_change")
	self:updateItem(4)
end
--页面退出时执行
function BagWindow:_exit( ... )
	self.itemcellArrs = {}
	print(1,"BagWindow _exit")
	Scheduler.scheduleNextFrame(function()
		ViewManager.close("ItemTipsBagView")
	end)
    for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
	end
	BattleModel:updateGameSpeed()
end

-------------------常用------------------------

return BagWindow