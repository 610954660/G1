--Name : ArenaController.lua
--Author : generated by FairyGUI
--Date : 2020-3-4
--Desc : 

local ArenaController = class("ArenaController",Controller)

function ArenaController:init()

end

function ArenaController:Arena_open()
	ViewManager.open("ArenaPerformView")
end

function ArenaController:Arena_getChallengeList()
	ModelManager.ArenaModel:requestChallengeInfo(function()
		ViewManager.open("ChallengeView")
	end);
end




return ArenaController