--特异奖励预览
--added by xhd
local GetTyAwardShowView,Super = class("GetTyAwardShowView",Window)
function GetTyAwardShowView:ctor( arg )
    self._packName = "GetCards"
	self._compName = "GetTyAwardShowView"
	self._rootDepth = LayerDepth.PopWindow
    self.selectIndex = self._args.selectIndex
end

function GetTyAwardShowView:_initUI( ... )
	 self.awardList = self.view:getChildAutoType("awardList")
	 local config1,lotteryId = GetCardsModel:getLotteryChangeConfig( self.selectIndex )
	 self.awardList:setItemRenderer(function (idx, obj)
		local title = obj:getChildAutoType("title")
		print(1,"config1[idx+1][1]",config1[idx+1][1])
		title:setVar("star",tostring(config1[idx+1][1]))
		title:flushVars()
		
		local rateVal = obj:getChildAutoType("rateVal")
		print(1,config1[idx+1][2])
		print(1,config1[idx+1][2])
		print(1,config1[idx+1][2])
		local txt = (config1[idx+1][2]/100).."%"
		rateVal:setText(txt)

		local config2 = GetCardsModel:getLotChangeOne( lotteryId,config1[idx+1][1])
		local heroList = obj:getChildAutoType("heroList")
		heroList:setItemRenderer(function (idx2, obj2)
			local rateVal2 = obj2:getChildAutoType("rateVal")
			local playerCell = obj2:getChildAutoType("playerCell")
			rateVal2:setText((config2[idx2+1].probability/100).."%")
		    local reward = config2[idx2+1].reward[1]
			-- local heroId = reward.code
    		-- local heroCell = BindManager.bindHeroCell(playerCell)
			-- local data = {}
			-- data.star = DynamicConfigData.t_hero[heroId].heroStar
			-- data.category = DynamicConfigData.t_hero[heroId].category
			-- data.code = heroId
			-- data.level = 1
			-- data.amount = 1
			-- heroCell:setData(data)
			local itemCell = BindManager.bindItemCell(playerCell)
			itemCell:setData(reward.code,reward.amount,reward.type)
		end)
		heroList:setData(config2)
		heroList:resizeToFit(#config2)
	 end)
	 self.awardList:setData(config1)
end

function GetTyAwardShowView:getCurConfig(config,star)
	for i=1,#config do
		if config[i].star == star then
			return config[i]
		end
	end
end

function GetTyAwardShowView:_initEvent( ... )
   
end

--initUI执行之前
function GetTyAwardShowView:_enter( ... )

end

--页面退出时执行
function GetTyAwardShowView:_exit( ... )
	print(1,"GetTyAwardShowView _exit")
end

return GetTyAwardShowView