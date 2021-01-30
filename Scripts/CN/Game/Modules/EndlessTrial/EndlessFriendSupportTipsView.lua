-- added by wyz
-- 无尽试炼 好友助阵点击提示

local EndlessFriendSupportTipsView = class("EndlessFriendSupportTipsView",Window)

function EndlessFriendSupportTipsView:ctor()
	self._packName 	= "EndlessTrial"
	self._compName 	= "EndlessFriendSupportTipsView"
	self._rootDepth = LayerDepth.WindowUI

	self.stateCtrl 	= false 	-- 控制器

	self.btn_ok 	= false 	-- 确定按钮
	self.btn_close 	= false 	-- 取消按钮

	self.playerCell_1 = false

	self.args = false

end

function EndlessFriendSupportTipsView:_initUI()
	self.args = self._args
	self.stateCtrl 	= self.view:getController("stateCtrl")
	self.btn_ok 	= self.view:getChildAutoType("btn_ok")
	self.btn_close 	= self.view:getChildAutoType("btn_close")
	self.playerCell_1 = self.view:getChildAutoType("playerCell_1")
end

function EndlessFriendSupportTipsView:_initEvent()
	self.stateCtrl:setSelectedIndex(self.args.index)
	if self.args.index == 0 or self.args.index == 1 then
		local playerCell_1 = BindManager.bindHeroCell(self.playerCell_1)
		if self.args.data and self.args.index == 0 then -- 自己的
			playerCell_1:setData(self.args.data)
		else -- 好友的
			playerCell_1:setData(self.args.data.hero)
		end
	end

	self.btn_ok:removeClickListener(66)
	self.btn_ok:addClickListener(function(idx,obj)
		
		if self.args.index == 0 then  -- 自己的
			local reqInfo = {
				uuid 	= self.args.data.uuid
			}
			RPCReq.TopChallenge_SetHelperHero(reqInfo,function(param)
				ModelManager.EndlessTrialModel.helpHeroState = true
				EndlessTrialModel:setHelpHeroUid(self.args.data.uuid)
				Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshFriendPanel)
			end)
		else -- 好友的
			local reqInfo = {
				playerId = self.args.data.playerId,
				uuid 	 = self.args.data.hero.uuid,
			}
			RPCReq.TopChallenge_ChooseFriendHelperHero(reqInfo,function(param)
				local friendListData = {}
				table.insert(friendListData,self.args.data)
				EndlessTrialModel:setFriendHelpHero(friendListData)
				Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshFriendPanel)
				Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshMainViewPanel)
			end)
		end
		ViewManager.close("EndlessFriendSupportTipsView")
	end,66)

	self.btn_close:removeClickListener(66)
	self.btn_close:addClickListener(function(idx,obj)
		ViewManager.close("EndlessFriendSupportTipsView")
	end,66)
end

return EndlessFriendSupportTipsView