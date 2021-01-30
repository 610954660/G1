﻿--Date :2021-01-29
--Author : generated by FairyGUI
--Desc : 

local NewYearActivityResultView,Super = class("NewYearActivityResultView", Window)

function NewYearActivityResultView:ctor()
	--LuaLog("NewYearActivityResultView ctor")
	self._packName = "NewYearActivity"
	self._compName = "NewYearActivityResultView"
	--self._rootDepth = LayerDepth.Window
	
end

function NewYearActivityResultView:_initEvent( )
	self.btn_get:addClickListener(function()

	end)

	self.btn_rego:addClickListener(function()
		ViewManager.close("NewYearActivityResultView")
	end)

	self.mask:addClickListener(function()
		ViewManager.close("NewYearActivityResultView")
	end)
end

function NewYearActivityResultView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:NewYearActivity.NewYearActivityResultView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GLabel
	self.btn_get = viewNode:getChildAutoType('btn_get')--GButton
	self.btn_rego = viewNode:getChildAutoType('btn_rego')--GButton
	self.mask = viewNode:getChildAutoType('mask')--GComponent
	self.showCtr = viewNode:getController('showCtr')--Controller
	self.spineParent = viewNode:getChildAutoType('spineParent')--GLoader
	self.spineParentDown = viewNode:getChildAutoType('spineParentDown')--GLoader
	self.spineParentUp = viewNode:getChildAutoType('spineParentUp')--GLoader
	self.txt_desc = viewNode:getChildAutoType('txt_desc')--GTextField
	--{autoFieldsEnd}:NewYearActivity.NewYearActivityResultView
	--Do not modify above code-------------
end

function NewYearActivityResultView:_initUI( )
	self:_initVM()
	self.win = self._args.win
	self.score = self._args.score
	local spineDown =  SpineUtil.createSpineObj(self.spineParentDown,cc.p(0,0), "gongnengjiesuo_down", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)
	local spineUp =  SpineUtil.createSpineObj(self.spineParentUp,cc.p(0,0), "gongnengjiesuo_up", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)
	self.showCtr:setSelectedIndex(0)
	if self.win then 
		self.txt_desc:setText(Desc.NewYearActivity_str11,self.score)
	else
		self.txt_desc:setText(Desc.NewYearActivity_str12)
	end
end

function NewYearActivityResultView:battleBoss()
	local callBack = function(type)
		if(type == "begin") then
			local params = {}
			params.activityId = GameDef.ActivityType.NewYear
			params.bossId = self.id
			params.onSuccess = function (data)
				printTable(6,"挑战大Boss data",data)
				self.bossData.status = data.status
				local battleData = FightManager.getBettleData(GameDef.BattleArrayType.NewYear)
				self.result =  battleData.result
				print(6,"战斗结果",self.result)
			end
			printTable(6,"挑战大Boss",params)
			RPCReq.Activity_NewYear_Challenge(params,params.onSuccess)
		elseif(type == "end") then 
			ViewManager.open("ReWardView",{page=0, isWin=self.result,showLose=true})
		end
	end
	Dispatcher.dispatchEvent(EventType.battle_requestFunc,callBack, {fightID=self.bossInfo.fightId,configType=GameDef.BattleArrayType.NewYear})
end

return NewYearActivityResultView