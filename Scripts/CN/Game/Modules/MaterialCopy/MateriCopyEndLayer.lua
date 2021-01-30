local MateriCopyEndLayer,Super = class("MateriCopyEndLayer", View)
local ItemCell = require "Game.UI.Global.ItemCell"

function MateriCopyEndLayer:ctor()
	--LuaLogE("PataEndLayer ctor")
	self._packName = "Pata"
	self._compName = "PataEndLayer"

	self._rootDepth = LayerDepth.Window

	self.win = false
	self.lose = false
	self.rewardList = false
	self.bg = false
end

function MateriCopyEndLayer:_initUI()
	--LuaLogE("PataEndLayer _initUI")

	self.bg = self.view:getChildAutoType("bg")
	self.win = self.view:getChildAutoType("win")
	self.lose = self.view:getChildAutoType("lose")
	self.rewardList =  self.view:getChildAutoType("rewardList")

	self:updateView()
end

function MateriCopyEndLayer:updateView()
	local isSuccess = ModelManager.MaterialCopyModel.__curCopyIsWin;
	local floor = ModelManager.PataModel:getCurFloor()
	self.win:setVisible(isSuccess)
	self.lose:setVisible(not isSuccess)
	self.bg:addClickListener(function ( ... )
		ViewManager.close("MateriCopyEndLayer")
	end)

	if isSuccess then
		local copyCode=ModelManager.MaterialCopyModel.__curCopyType;
		local dif=ModelManager.MaterialCopyModel.__curCopyDiff;
		local copyData=DynamicConfigData.t_copy;
		local copyInfo=copyData[copyCode];
		--printTable(5,"结算》》》》》》》》》",copyCode,dif,copyInfo)
		local rewardPre=copyInfo[dif].gameRes;
		--printTable(5,"结算》》》》》》》》》111",rewardPre)
		self.rewardList:setItemRenderer(function(index,obj)
		    local itemcell = BindManager.bindItemCell(obj)
       		local award = rewardPre[index + 1]
        	itemcell:setData(award.code, award.amount, award.type)
				-- obj:addClickListener(function( ... )
				-- 	itemcell:onClickCell()
				-- end)
			end
		)
		self.rewardList:setData(rewardPre)
	end
end




function MateriCopyEndLayer:_initEvent( ... )

end

function MateriCopyEndLayer:_exit()
	Dispatcher.dispatchEvent(EventType.pata_showNext)
end

return MateriCopyEndLayer
