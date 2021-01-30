--道具tips
--added by xhd
local CardCombineSureView = class("CardCombineSureView", Window)
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local ItemCell = require "Game.UI.Global.ItemCell"
function CardCombineSureView:ctor(...)
    self._packName = "CardSystem"
    self._compName = "CardCombineView"
    self._rootDepth = LayerDepth.Tips
    self._hasNum = false
    self._needNum = false
    self._AddNum = 1
	self.itemData = self._args
end

function CardCombineSureView:init(...)
    -- body
end

-- [子类重写] 初始化UI方法
function CardCombineSureView:_initUI(...)
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
	elseif itemData:getItemInfo().type == GameDef.ItemType.FashioDebris then--时装碎片
		local fashionComposeConfig = FashionConfiger.getFashionComposeConfigerByFashionId(itemData:getItemInfo().effect)
		local consume = fashionComposeConfig.consume[1]
		self._needNum = 0
		if consume then 
			self._needNum = consume.amount
		end
	else
		local itemCom = DynamicConfigData.t_heroCombine[comCode]
		self._needNum = 0
		if itemCom then
			self._needNum = itemCom.amount
		end
	end
    local item = view:getChild("itemCell")
    local itemcell = BindManager.bindItemCell(item)
    itemcell:setItemData(itemData)
    local name = view:getChild("itemName")
	name:setText(itemData.__itemInfo.name)
	printTable(8,"合成按钮被点击",itemData.__itemInfo.name)

    local maxNum= math.floor( self._hasNum/self._needNum  ) 
    self._AddNum=maxNum;

    self:showTextNum();
end

function CardCombineSureView:showTextNum(arg1, arg2, arg3)
	local num = self.view:getChild("txt_num")
    num:setText(self._AddNum .. "")
end
-- [子类重写] 准备事件
function CardCombineSureView:_initEvent(...)
    local btnCom = self.view:getChild("btn_com")
    btnCom:addClickListener(
        function(...)
			if self.itemData:getItemInfo().type == GameDef.ItemType.CrystalUpgrade then --这个是水晶碎片
				local params = {}
				params.bagType =GameDef.BagType.Normal
				params.itemId = self.itemData:getItemId()
				params.amount = self._AddNum
				params.onSuccess = function( res )
					print(1,res)
				 end
				 RPCReq.Bag_UseItem(params, params.onSuccess)
			elseif self.itemData:getItemInfo().type == GameDef.ItemType.FashioDebris then	 --时装碎片
				local fashionComposeConfig = FashionConfiger.getFashionComposeConfigerByFashionId(self.itemData:getItemInfo().effect)
				local params = {}
				params.id = fashionComposeConfig.id
				params.amount = self._AddNum
				RPCReq.Fashion_Compose(params)
			else
				ModelManager.CardLibModel:combineCard(self._args.__data.code, self._AddNum)
			end
            ViewManager.close("CardCombineSureView")
        end
    )
    local closeButton1 = self.view:getChild("closeButton1")
    closeButton1:addClickListener(
        function(...)
            ViewManager.close("CardCombineSureView")
        end
	)
	local addpoint = self.view:getChild("addpoint")
    addpoint:addClickListener(
        function(...)
			self._AddNum=self._AddNum+1
			local maxNum= math.floor( self._hasNum/self._needNum  ) 
			if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(DescAuto[41]) -- [41]='达到最大数量'
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
				RollTips.show(DescAuto[42]) -- [42]='达到最小数量'
			end
			self:showTextNum();
        end
    )

    local btnmax = self.view:getChild("btn_max")
    btnmax:addClickListener(
        function(...)
            local maxNum= math.floor( self._hasNum/self._needNum  ) 
            self._AddNum=maxNum;
            if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(DescAuto[41]) -- [41]='达到最大数量'
			end
			self:showTextNum();
        end
    )
end

-- [子类重写] 添加后执行
function CardCombineSureView:_enter()
end

-- [子类重写] 移除后执行
function CardCombineSureView:_exit()
	self._AddNum=1;
end

return CardCombineSureView
