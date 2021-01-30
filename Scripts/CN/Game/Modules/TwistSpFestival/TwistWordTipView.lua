--Date :2021-01-21
--Author : generated by FairyGUI
--Desc : 

local TwistWordTipView,Super = class("TwistWordTipView", Window)

function TwistWordTipView:ctor()
	--LuaLog("TwistWordTipView ctor")
	self._packName = "TwistSpFestival"
	self._compName = "TwistWordTipView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function TwistWordTipView:_initEvent( )
	
end

function TwistWordTipView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:TwistSpFestival.TwistWordTipView
	self.btn_Edit = viewNode:getChildAutoType('btn_Edit')--GButton
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.content = viewNode:getChildAutoType('content')--GRichTextField
	self.open = viewNode:getChildAutoType('open')--GGroup
	self.playerName = viewNode:getChildAutoType('playerName')--GTextField
	self.rewardList = viewNode:getChildAutoType('rewardList')--GList
	self.title = viewNode:getChildAutoType('title')--GTextField
	self.wordType = viewNode:getController('wordType')--Controller
	self.writer = viewNode:getChildAutoType('writer')--GTextField
	--{autoFieldsEnd}:TwistSpFestival.TwistWordTipView
	--Do not modify above code-------------
end

function TwistWordTipView:_initListener( )
	
	self.rewardList:setItemRenderer(function(index, obj)
			local acConfig=TwistSpFestivalModel:getAciveConfig()
			local rewardData=acConfig.reward[index+1]
			local itemcell=BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = rewardData})
			itemcell:setItemData(itemData)
	end)
	self.btn_Edit:addClickListener(function ()
		ViewManager.open("TwistWordEditView")
		ViewManager.close("TwistWordTipView")
	end)

end

function TwistWordTipView:_initUI( )
	self:_initVM()
	self:_initListener()
	TwistSpFestivalModel:getBarrage(function (data)
			self:setData(data)
	end)

end

function TwistWordTipView:setData(data)
	local acConfig=TwistSpFestivalModel:getAciveConfig()
	self.rewardList:setNumItems(#acConfig.reward)
	self.content:setText(acConfig.desc)
	self.title:setText(acConfig.title)
	self.writer:setText(acConfig.writer)
	self.playerName:setText("to:"..PlayerModel.username)
end



return TwistWordTipView