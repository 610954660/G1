--Date :2020-12-30
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersController = class("CrossLadders",Controller)

function CrossLaddersController:init()
	
end


-- #活动状态通知
-- SkyLadder_UpdateStatus 26785 {
--     request {
--        status     1:integer
--        endMs      2:integer
--     }
-- }
function CrossLaddersController:SkyLadder_UpdateStatus(_,params)
    CrossLaddersModel:initSkyLadder_UpdateStatus(params)   
end


-- SkyLadder_PlayerData 18872 {
--     request {
--        usedTimes     1:integer  #使用次数
--        buyTimes      2:integer  #购买次数
--        rank          3:integer  #排名
--        join          4:boolean  #是否有参数资格
--        likeList      5:*LikeData(rank) # 点赞次数
--     }
-- }
function CrossLaddersController:SkyLadder_PlayerData(_,params)
    CrossLaddersModel:initSkyLadder_PlayerData(params)  
end



return CrossLaddersController