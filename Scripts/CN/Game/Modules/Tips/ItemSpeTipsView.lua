--自选礼包tips特殊处理  
--备注  这个不能使用tips不然形成层级套环
--added by xhd
local ItemSpeTipsView = class("ItemSpeTipsView",View)
local ItemCell = require "Game.UI.Global.ItemCell"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function ItemSpeTipsView:ctor( ... )
	self._packName = "ToolTip"
    self._compName = "ItemSpeTipsView"
    self._rootDepth = LayerDepth.Tips
	self.data = self._args
	self.itemData = self._args.data
	self.blackBg = false
    self._isFullScreen = true
end

-- function ItemSpeTipsView:_initEvent( ... )
-- 	-- body
-- 	--特殊处理
--     local top=ViewManager.getLayerTopWindow(LayerDepth.AlertWindow)
--     if top then
--     	top.window:setVisible(false)
--     end
-- end

-- function ItemSpeTipsView:_checkOpenBlur()
-- 	return false
-- end

function ItemSpeTipsView:spe_windowEvent( _,flag )
	print(1,"spe_windowEvent",flag)
	--特殊处理
    local top=ViewManager.getLayerTopWindow(LayerDepth.AlertWindow)
    if top then
    	top.window:setVisible(not flag)
    end
    self.view:setVisible(not flag)
end

-- [子类重写] 初始化UI方法
function ItemSpeTipsView:_initUI( ... )
	self.blackBg = self.view:getChildAutoType("blackbgAlpha")
	self.blackBg:addClickListener(function ( ... )
		ViewManager.close("ItemSpeTipsView")
	end)
	self.heroOrItemCtrl = self.view:getController("heroOrItemCtrl")
	local itemInfo = nil
	if self.itemData then
		itemInfo = self.itemData:getItemInfo()
	end
	if itemInfo and itemInfo.type == 19 then --特殊道具 自选礼包
		self.nameLabel = self.view:getChildAutoType("nameLabel")
		self.itemCell = self.view:getChildAutoType("itemCell")
		-- self.txt_desc = self.view:getChildAutoType("txt_desc")
		self.txt_title = self.view:getChildAutoType("txt_title")
		self.categoryChoose = self.view:getChildAutoType("categoryChoose")
		self.list = self.view:getChildAutoType("list")
		local bgLoader = self.view:getChildAutoType("bgLoader")
        
        self.list:setItemRenderer(function(index,obj)
        	local heroCell = obj:getChildAutoType("heroCell")
        	
        	local itemName = obj:getChildAutoType("itemName")
        	local itemNum = obj:getChildAutoType("itemNum")
        	local itemCell = obj:getChildAutoType("itemCell")
        	local typeCtrl = obj:getController("typeCtrl")
            local data =  self.list._dataTemplate[index+1]
            -- printTable(1,"data",data)
			if data.type == GameDef.GameResType.Hero then --卡牌英雄
				self.txt_title:setText(DescAuto[319]) -- [319]="可以从下列探员中选中一位获得"
				typeCtrl:setSelectedIndex(0)
				local heroCellObj = BindManager.bindHeroCellShow(heroCell)
				local tempdata = {}
				tempdata.code = data.code
				tempdata.category = DynamicConfigData.t_hero[data.code].category
				tempdata.star = DynamicConfigData.t_hero[data.code].heroStar
				tempdata.level = 1
				tempdata.name = DynamicConfigData.t_hero[data.code].heroName
				heroCellObj:setData(tempdata)
				
				itemName:setText(tempdata.name)
				itemNum:setText("x"..data.amount)
				obj:removeClickListener(100)
				obj:addClickListener(function ( ... )
					local categoryHeros = DynamicConfigData.t_HeroTotems[tempdata.category]
					local _cardInfoList = {}
					for _,v in pairs(categoryHeros) do
						if  tonumber(data.code)==v.hero then
							table.insert(_cardInfoList, v)
						end
					end
                    self:spe_windowEvent("",true)
					ViewManager.open("HeroInfoView",{index = 1,heroId =tonumber(data.code),heroList = _cardInfoList })
				end,100)
		    else
		    	typeCtrl:setSelectedIndex(1)
		    	local itemcellObj = BindManager.bindItemCell(itemCell)
				local itemData = ItemsUtil.createItemData({data = data})
				itemcellObj:setIsBig(false)
				--itemcellObj:setClickable(false)
				itemcellObj:setItemData(itemData,CodeType.ITEM)
				itemName:setText(itemData:getName())
				itemName:setColor(itemData:getItemTipsColor())
				itemNum:setText("x"..data.amount)
				self.txt_title:setText(itemInfo.usageDesc)
		    end
		end
		)
		self.list:setVirtual();


		self.nameLabel:setText(self.itemData:getName())
		self.nameLabel:setColor(self.itemData:getItemTipsColor())
		local itemcellObj = BindManager.bindItemCell(self.itemCell)
		itemcellObj:setIsBig(false)
		itemcellObj:setClickable(false)
		itemcellObj:setItemData(self.itemData,CodeType.ITEM)
		bgLoader:setURL(PathConfiger.getItemTipsHeadBg(self.itemData:getColorId()))
		-- self.txt_desc:setText(self.itemData:getDescStr())
		
		--获取第一个道具检测 是英雄自选包 还是道具自选包
		local config = self.itemData:geteEfectEx()
		if config and #config>0 then
			if config[1].type == 4 then --是英雄自选
				self.heroOrItemCtrl:setSelectedIndex(0)
				-- 种族切页
				local data = {}
				local categoryArr = {}
				local tempIndex = 0
				for idx = 1, 5 do
					data[idx] = {}
					for i,v in ipairs(config) do
					    if v.type == GameDef.GameResType.Hero then --卡牌英雄
					    	local category = DynamicConfigData.t_hero[v.code].category
					    	if idx == category then
					    		if tempIndex ==0 then
					    			tempIndex = idx
					    		end
					    		table.insert(data[idx],v)
					    	end
					    end
					end
				end
				for k,v in pairs(data) do
					if v[1] then
						table.insert(categoryArr,k)
					end
				end

				-- printTable(1,"1111",data)
				-- printTable(1,"222",categoryArr)
                                
                local list  = self.categoryChoose:getChildAutoType("list")
                list:setItemRenderer(function(index,obj)
                	local c1Ctrl = obj:getController("c1")
                	local c2Ctrl = obj:getController("c2")
                	c2Ctrl:setSelectedIndex(1)
                	if index ==0 then
                		obj:setSelected(true)
                	end
                	local tempData = list._dataTemplate[index+1]
                	c1Ctrl:setSelectedIndex(tempData-1)
                	obj:removeClickListener(11)
                	obj:addClickListener(function( ... )
                		self:changeCategory(tempData,data);
                	end)
                end)
                --默认     
				self:changeCategory(categoryArr[1],data);
                list:setData(categoryArr)
			else
				self.heroOrItemCtrl:setSelectedIndex(1)
				self.list:setData(config)
			end
		end
	end
end

function ItemSpeTipsView:changeCategory( idx,data)
	-- local config = self.itemData:geteEfectEx()
	-- local data ={}
	-- for i,v in ipairs(config) do
	--     if v.type == GameDef.GameResType.Hero then --卡牌英雄
	--     	local category = DynamicConfigData.t_hero[v.code].category
	--     	if idx == category then
	--     		table.insert(data,v)
	--     	end
	--     end
	-- end
	self.list:setData(data[idx])
end



-- [子类重写] 添加后执行
function ItemSpeTipsView:_enter()
end

-- [子类重写] 移除后执行
function ItemSpeTipsView:_exit()
	-- local top=ViewManager.getLayerTopWindow(LayerDepth.AlertWindow)
 --    if top then
 --    	top.window:setVisible(true)
 --    end
end


return ItemSpeTipsView
