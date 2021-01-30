local UpgradeController = class("UpgradeController",Controller)



function UpgradeController:ctor()
	self.data = false
	self.schedulerID = false
end

function UpgradeController:init()

end


function UpgradeController:player_updateRoleInfo(_,info)
	if not info.isUpgrade then return end
	
	Scheduler.unschedule(self.schedulerID)
	self.schedulerID = Scheduler.schedule(function()
			--local topView = ViewManager.getLayerTopWindow(nil,LayerDepth.Guide,"RollTips")
			if ViewManager.getView("BattleBeginView") then return end
			if ViewManager.getView("ReWardView") then return end
			if ViewManager.getView("AwardShowView") then return end
			if ViewManager.getView("AwardView") then return end
			if PlayerModel:get_awardData() then return end
			--if topView.window._compName ~= "BattlebeginView" and topView.window._compName ~= "ReWardView" and topView.window._compName ~= "AwardShowView" then
				ViewManager.open("UpgradeView",{beLevel = info.beforeLevel, curLevel = info.level})
				Scheduler.unschedule(self.schedulerID)
			--end
		end,0.2)
	
	
end


return UpgradeController