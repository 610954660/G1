--爱心幸运度窗口
--added by xhd
local GetAixinCardsView,Super = class("GetAixinCardsView",Window)

function GetAixinCardsView:ctor( ... )
    self._packName = "GetCards"
	self._compName = "GetAixinCardsView"
	self.txt = false
	self.heroName = false
	self.zhaohuanBtn = false
	self._rootDepth = LayerDepth.PopWindow
end

function GetAixinCardsView:_initUI( ... )
	-- self:setBg("bg_common.jpg")
	self.txt = self.view:getChildAutoType("txt")
	self.heroName = self.view:getChildAutoType("heroName")
	self.zhaohuanBtn = self.view:getChildAutoType("zhaohuanBtn")
	self.progressBar = self.view:getChildAutoType("progressBar")
	self.aixinNum = self.view:getChildAutoType("aixinNum")
	self.costNum = self.view:getChildAutoType("costNum")
	-- self.costItemLeft = self.view:getChildAutoType("costItemLeft")
	-- self.costItemObj1 = BindManager.bindCostItem(self.costItemLeft)
	-- self:setBg("getcard.jpg")
	self:updateAixin()
	-- local cost = {type=2,code= 4,amount= 1000,}
	-- self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
end

function GetAixinCardsView:updateAixin( ... )
	if tolua.isnull(self.view) then
		return 
	end
	if GetCardsModel:getLuckyValue() >= 1000 then
		self.costNum:setColor(cc.c3b(90,221,122))
		self.view:getTransition("t0"):play(function( ... )
		end)
	else
		self.costNum:setColor(cc.c3b(244,54,54))
		self.view:getTransition("t0"):stop()
	end
	self.progressBar:setValue(GetCardsModel:getLuckyValue())
	self.aixinNum:setText(GetCardsModel:getLuckyValue())
end


function GetAixinCardsView:_initEvent( ... )
	self.zhaohuanBtn:addClickListener(function ( ... )
		 -- print(1,"GetCardsModel:getLuckyValue()",GetCardsModel:getLuckyValue())
		 if not ModuleUtil.hasModuleOpen(ModuleId.AixinCards.id) then
			local str1 = ModuleUtil.getModuleOpenTips(ModuleId.AixinCards.id) or ""
         	RollTips.show(str1..Desc.GetCard_Text1)
         	return
         end
		
		 if GetCardsModel:getLuckyValue() >=1000 then --幸运值
			if CardLibModel:isBagFull(1) then 
				RollTips.show(Desc.getCard_bagFull)
				return 
			end
		 	local params = {}
 		    params.id = 5
	 		params.onSuccess = function (res )
	 	        local data = {}
	 	        data.specialType = 1
	 	        data.resultList = res.resultList
	 		    data.itemCode = 0
				 data.id = 5
				self:updateAixin()
	 		    ViewManager.close("GetAixinCardsView")
	 			ViewManager.open("GetSuccess1View",data)
	 		end
	 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 else
		 	--提示
		 	RollTips.show(Desc.love_no_enough)
		 end
	end)
end

--initUI执行之前
function GetAixinCardsView:_enter( ... )

end

--页面退出时执行
function GetAixinCardsView:_exit( ... )
	print(1,"GetAixinCardsView _exit")
end

return GetAixinCardsView