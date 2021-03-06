--Date :2020-11-25
--Author : generated by FairyGUI
--Desc : 

local DetectiveTrialEndView,Super = class("DetectiveTrialEndView", Window)

function DetectiveTrialEndView:ctor()
	--LuaLog("DetectiveTrialEndView ctor")
	self._packName = "DetectiveTrial"
	self._compName = "DetectiveTrialEndView"
	--self._rootDepth = LayerDepth.Window
	
end

function DetectiveTrialEndView:_initEvent( )
	
end

function DetectiveTrialEndView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:DetectiveTrial.DetectiveTrialEndView
	self.txt_rank = viewNode:getChildAutoType('txt_rank')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:DetectiveTrial.DetectiveTrialEndView
	--Do not modify above code-------------
end

function DetectiveTrialEndView:_initUI( )
	self:_initVM()
	local data = DetectiveTrialModel:gettleEndInfo()
	self.txt_tips:setText(Desc.DetectiveTrial_fightTipsTitle)
	self.txt_rank:setText(string.format(Desc.DetectiveTrial_fightRank,data.beatCount))
end






return DetectiveTrialEndView