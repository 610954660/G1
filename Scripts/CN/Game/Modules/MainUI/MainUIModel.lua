local BaseModel = require "Game.FMVC.Core.BaseModel"
local MainUIModel = class("MainUIModel",BaseModel)
function MainUIModel:ctor()

end

--设置立绘配置
function MainUIModel:setLihuiState(static)
	FileCacheManager.setBoolForKey(PlayerModel.userid..FileDataType.MAIN_HERO_STATIC,static,false,false)
end

--查看是否全部设置成静态立绘
function MainUIModel:isLihuiStatic()
	return FileCacheManager.getBoolForKey(PlayerModel.userid..FileDataType.MAIN_HERO_STATIC,false,false,false)
end




return MainUIModel