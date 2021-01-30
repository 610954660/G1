
local DownLoadGiftModel = class("DownLoadGiftModel",BaseModel)

function DownLoadGiftModel:ctor()
    self.state = true      -- 礼包领取状态   默认为已领取
    self.data = {}
    self.downIndex = 1     -- 1 下载中  -- 0 暂停 -- 2 领取奖励
end

function DownLoadGiftModel:initData(data)
    -- printTable(8848,"data>>>>>>>>>>>>",data)
    self.data = {}
    self.data = data
    self.state = self.data.state or false
    self:upDateRed()
end

function DownLoadGiftModel:redCheck()
	GlobalUtil.delayCallOnce("DownLoadGiftModel:redCheck",function()
		self:upDateRed()
	end, self, 0.1)
end

function DownLoadGiftModel:upDateRed()
    if (FileCacheManager.getIntForKey("DownLoadGift",1) == 2 or ResDownloadModel.status == 2) and (not self.state) then
        RedManager.updateValue("M_DOWNLOADGIFT",true)
    else
        RedManager.updateValue("M_DOWNLOADGIFT",false)
    end
end

function DownLoadGiftModel:loginPlayerDataFinish()
    
end

return DownLoadGiftModel