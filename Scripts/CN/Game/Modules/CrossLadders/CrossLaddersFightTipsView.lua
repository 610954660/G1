--Date :2021-01-05
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersFightTipsView,Super = class("CrossLaddersFightTipsView", Window)

function CrossLaddersFightTipsView:ctor()
	--LuaLog("CrossLaddersFightTipsView ctor")
	self._packName = "CrossLadders"
	self._compName = "CrossLaddersFightTipsView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossLaddersFightTipsView:_initEvent( )
	
end

function CrossLaddersFightTipsView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLadders.CrossLaddersFightTipsView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_cancel = viewNode:getChildAutoType('btn_cancel')--GButton
	self.btn_ok = viewNode:getChildAutoType('btn_ok')--GButton
	self.btn_tips = viewNode:getChildAutoType('btn_tips')--btn_tips
		self.btn_tips.txt_tips = viewNode:getChildAutoType('btn_tips/txt_tips')--GTextField
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itemCell = viewNode:getChildAutoType('itemCell')--GButton
	self.txt_limitTimes = viewNode:getChildAutoType('txt_limitTimes')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossLadders.CrossLaddersFightTipsView
	--Do not modify above code-------------
end

function CrossLaddersFightTipsView:_initListener( )
	
	self.btn_ok:addClickListener(function()
		CrossLaddersModel:reqSkyLadder_ChallengeStart(self._args.playerId,self._args.rank,self._args.otherData,self._args.myOldRank)
	end)

	self.btn_cancel:addClickListener(function()
		ViewManager.close("CrossLaddersFightTipsView")
	end)
	
	-- local dayStr = DateUtil.getOppostieDays()
	-- local isfresh = FileCacheManager.getIntForKey("CrossLadders_isCheckTips" .. dayStr,0)
	local dayStr = DateUtil.getOppostieDays()
    local index = FileCacheManager.getIntForKey("CrossLadders_isCheckTips" .. dayStr,0)
    local ctrl = self.btn_tips:getController("button")
    ctrl:setSelectedIndex(index)
    self.btn_tips:addClickListener(function()
        local selectIndex = ctrl:getSelectedIndex()
        print(8848,">>>selectIndex>>>",selectIndex)
        CrossLaddersModel:setCheckTips(selectIndex)
    end)
	
	local conf = DynamicConfigData.t_SkyLadder[1]
	local ticketCode = conf.ticketCode
	
	self.itemCell:addClickListener(function()

	end)
	local itemCell = BindManager.bindItemCell(self.itemCell)
	itemCell:setData(ticketCode,1,CodeType.ITEM)
	itemCell:setNoFrame(true)

end

function CrossLaddersFightTipsView:_initUI( )
	self:_initVM()
	self:_initListener()

end




return CrossLaddersFightTipsView