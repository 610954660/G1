﻿--Date :2021-01-29
--Author : generated by FairyGUI
--Desc : 

local CollectWordsLimitGift2View,Super = class("CollectWordsLimitGift2View", View)

function CollectWordsLimitGift2View:ctor()
	--LuaLog("CollectWordsLimitGift2View ctor")
	self._packName = "CollectWordsActivity"
	self._compName = "CollectWordsLimitGift2View"
	--self._rootDepth = LayerDepth.Window
	
end

function CollectWordsLimitGift2View:_initEvent( )
	
end

function CollectWordsLimitGift2View:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CollectWordsActivity.CollectWordsLimitGift2View
	self.banner = viewNode:getChildAutoType('banner')--GLoader
	self.list_gift = viewNode:getChildAutoType('list_gift')--GList
	self.moneyComp = viewNode:getChildAutoType('moneyComp')--GLabel
	self.moneyCompCtrl = viewNode:getController('moneyCompCtrl')--Controller
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	--{autoFieldsEnd}:CollectWordsActivity.CollectWordsLimitGift2View
	--Do not modify above code-------------
end

function CollectWordsLimitGift2View:_initListener( )
	
	self.list_gift:setItemRenderer(function(index, obj)

	end)

end

function CollectWordsLimitGift2View:_initUI( )
	self:_initVM()
	self:_initListener()

end




return CollectWordsLimitGift2View