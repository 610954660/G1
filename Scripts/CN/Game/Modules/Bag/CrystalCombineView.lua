--水晶合成
--added by wyang
local CrystalCombineView = class("CrystalCombineView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function CrystalCombineView:ctor(...)
    self._packName = "Bag"
    self._compName = "CrystalCombineView"
    self._rootDepth = LayerDepth.PopWindow
    self._hasNum = false
    self._needNum = false
    self._AddNum = 1
	self.itemData = self._args
	self.costItem = false
end

function CrystalCombineView:init(...)
    -- body
end

-- [子类重写] 初始化UI方法
function CrystalCombineView:_initUI(...)
    local view = self.view
	local itemData = self._args
    local comCode = itemData.__data.code
    self._hasNum = itemData.__data.amount
	if itemData:getItemInfo().type == GameDef.ItemType.CrystalUpgrade then --这个是水晶碎片
		local itemCom = DynamicConfigData.t_CrystalUpgrade[comCode]
		self._needNum = 0
		if itemCom then
			self._needNum = itemCom.amount
		end
	else
		--[[local itemCom = DynamicConfigData.t_heroCombine[comCode]
		self._needNum = 0
		if itemCom then
			self._needNum = itemCom.amount
		end--]]
	end
    local itemCell_1 = view:getChild("itemCell_1")
    local itemcell = BindManager.bindItemCell(itemCell_1)
	itemcell:setIsMid(true)
    itemcell:setData(itemData:getItemInfo().code, 0, CodeType.ITEM)
	
	
	local config = DynamicConfigData.t_CrystalUpgrade[itemData:getItemInfo().code]
	if config then
		local itemCell_2 = view:getChild("itemCell_2")
		local itemcell2 = BindManager.bindItemCell(itemCell_2)
		itemcell2:setIsMid(true)
		itemcell2:setData(config.itemList[1].code, 0, config.itemList[1].type)
	end
	
	local costItem = view:getChild("costItem")
	self.costItem = BindManager.bindCostItem(costItem)
	--name:setText(itemData.__itemInfo.name)
	--printTable(8,"合成按钮被点击",itemData.__itemInfo.name)

    --local maxNum= math.floor( self._hasNum/self._needNum  ) 
    self._AddNum= 1--self._hasNum >= self._needNum and 1 or 0

    self:showTextNum();
end

function CrystalCombineView:showTextNum(arg1, arg2, arg3)
	local num = self.view:getChild("txt_num")
    num:setText(self._AddNum .. "")
	self.costItem:setData(CodeType.ITEM,self.itemData:getItemInfo().code,  self._AddNum * self._needNum)
end
-- [子类重写] 准备事件
function CrystalCombineView:_initEvent(...)
    local btnCom = self.view:getChild("btn_com")
    btnCom:addClickListener(
        function(...)
			if self._hasNum < self._needNum then
				RollTips.show(Desc.itemtips_crystalNotEnough)
				return
			end
			local params = {}
			params.bagType =GameDef.BagType.Normal
			params.itemId = self.itemData:getItemId()
			params.amount = self._AddNum
			params.onSuccess = function( res )
				print(1,res)
			 end
			 RPCReq.Bag_UseItem(params, params.onSuccess)
		
            ViewManager.close("CrystalCombineView")
        end
    )
    local closeButton1 = self.view:getChild("closeButton1")
    closeButton1:addClickListener(
        function(...)
            ViewManager.close("CrystalCombineView")
        end
	)
	local addpoint = self.view:getChild("addpoint")
    addpoint:addClickListener(
        function(...)
			self._AddNum=self._AddNum+1
			local maxNum= math.floor( self._hasNum/self._needNum  ) 
			if maxNum <= 0 then maxNum = 1 end
			if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(Desc.itemtips_crystalMaxNum)
			end
			self:showTextNum();
        end
	)
	local subpoint = self.view:getChild("subpoint")
    subpoint:addClickListener(
		function(...)
			self._AddNum=self._AddNum-1
            if self._AddNum<=1 then
				self._AddNum=1;
				RollTips.show(Desc.itemtips_crystalMinNum)
			end
			self:showTextNum();
        end
    )

    local btnmax = self.view:getChild("btn_max")
    btnmax:addClickListener(
        function(...)
            local maxNum= math.floor( self._hasNum/self._needNum  ) 
			if maxNum <= 0 then maxNum = 1 end
            self._AddNum=maxNum;
            if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(Desc.itemtips_crystalMaxNum)
			end
			self:showTextNum();
        end
    )
end

-- [子类重写] 添加后执行
function CrystalCombineView:_enter()
end

-- [子类重写] 移除后执行
function CrystalCombineView:_exit()
	self._AddNum=1;
end

return CrystalCombineView
