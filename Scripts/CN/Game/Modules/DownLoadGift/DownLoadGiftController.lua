local DownLoadGiftController = class("DownLoadGiftController", Controller)

function DownLoadGiftController:GamePlay_UpdateData (_,params)
    -- printTable(8848,"GamePlay_UpdateData",params)
    if params.gamePlayType == GameDef.GamePlayType.DownloadReward then
        DownLoadGiftModel:initData(params.gp.downloadReward)
		DownLoadGiftModel:upDateRed()
    end
end

function DownLoadGiftController:resDownLoad_status(_,params)
    DownLoadGiftModel:upDateRed()
end

return DownLoadGiftController