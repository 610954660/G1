
-- added by wyz 
-- 精灵背包
local PackConfiger = require "Game.ConfigReaders.PackConfiger"
local ElvesBagView = class("ElvesBagView",Window)

function ElvesBagView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesBagView"
    self.list_bag = false
    self.itemcellArr = {}
    self.listData   = false
    self.numVal = false
    
end

function ElvesBagView:_initUI()
    for k,v in pairs(GameDef.FightAttrType) do

    end
    self.numVal = self.view:getChildAutoType("txt_numVal")
    self.list_bag   = self.view:getChildAutoType("list_bag")
    self.list_bag:setVirtual()
	self.list_bag:setItemRenderer(function (index,obj)
		local data = self.listData[index+1]
		local __data = data.__data
		local __itemInfo = data.__itemInfo
		printTable(8848,">>>data>>>",data)
		local img_red = obj:getChildAutoType("img_red")
		
		local itemCom = DynamicConfigData.t_ElfCombine[__data.code] or {}
		local _needNum = itemCom.amount or 0
		local _hasNum  = __data.amount
		local isHave = ModelManager.ElvesSystemModel:isHaveElvesById(__itemInfo.icon,true)
		if (_hasNum >= _needNum) and (not isHave) then
			img_red:setVisible(true)
		else
			img_red:setVisible(false)
		end

		local itemcell = BindManager.bindItemCell(obj)
		itemcell:setIsMid(true)
		self.itemcellArr[index+1] = itemcell
		-- itemcell:setIsBig(true)
		-- itemcell:setAmountVisible(false)
		itemcell:setItemData(self.listData[index+1],CodeType.ITEM, "elves")
	end
	)
	self.list_bag:setVirtual()
    self.listData = ModelManager.PackModel:getElvesBag():sort_bagDatas()
    -- printTable(8848,"self.listData>>>>>",self.listData)
	self.list_bag:setData(self.listData)
	self.list_bag:setSelectedIndex(0)
	if self.itemcellArr[1]  then
		self.itemcellArr[1]:onClickCell()
	end
end

function ElvesBagView:_initEvent()
    self:pack_elves_change()
end

function ElvesBagView:_refresh()
	self.list_bag:setSelectedIndex(0)
	if self.itemcellArr[1] then
		self.itemcellArr[1]:onClickCell()
	end
end

-- 监听符文背包道具变化
function ElvesBagView:pack_elves_change( ... )

	-- do return end
	self.listData = ModelManager.PackModel:getElvesBag():sort_bagDatas()
	-- printTable(8848,">>>>>>>>>>>>>>DAD>>>>",self.listData)
	self.list_bag:setData(self.listData)
	self.numVal:setText(#self.listData.."/"..PackConfiger.getPackInfoByType(GameDef.BagType.Elf).maxCapacity)
	
end

return ElvesBagView