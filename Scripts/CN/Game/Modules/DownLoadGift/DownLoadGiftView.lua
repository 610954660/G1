-- added by wyz
-- 下载有礼
local DownLoadGiftView = class("DownLoadGiftView",Window)

function DownLoadGiftView:ctor()
    self._packName = "DownLoadGift"
    self._compName = "DownLoadGiftView"
    self._rootDepth = LayerDepth.PopWindow

    self.txt_value = false
    self.list_reward = false
    self.btn_down   = false
    self.btn_take   = false
    self.btn_stop   = false
    self.btn_close  = false
end

function DownLoadGiftView:_initUI()
    self.txt_value  = self.view:getChildAutoType("txt_value")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.btn_down   = self.view:getChildAutoType("btn_down")
    self.btn_stop   = self.view:getChildAutoType("btn_stop")
    self.btn_take   = self.view:getChildAutoType("btn_take")
    self.btn_close  = self.view:getChildAutoType("btn_close")
	
    local progressBar = self.view:getChildAutoType("progressBar")
    progressBar:setMax(100)
    if (FileCacheManager.getIntForKey("DownLoadGift",1) == 2 or ModelManager.ResDownloadModel.status == 2) then -- 下载完成
        ModelManager.DownLoadGiftModel.downIndex = 2     -- 领取奖励
        self.txt_value:setText(string.format(Desc.DownLoadGift_value,string.format("%.4g",100)))
        progressBar:setValue(100)
    else --没下完 默认下载中
        if ModelManager.ResDownloadModel._maxVal == 0 then ModelManager.ResDownloadModel._maxVal = 1 end
        progressBar:setValue((ModelManager.ResDownloadModel._curVal/ModelManager.ResDownloadModel._maxVal)*100)
        self.txt_value:setText(string.format(Desc.DownLoadGift_value,string.format("%.4g",(ModelManager.ResDownloadModel._curVal/ResDownloadModel._maxVal)*100)))
    end
    self.view:getController("c1"):setSelectedIndex(ModelManager.DownLoadGiftModel.downIndex)

    self.btn_close:addClickListener(function()
        self:closeView()
    end)
end

function DownLoadGiftView:_initEvent()
    self:refreshPanel()
end

function DownLoadGiftView:refreshPanel()
    local rewardData = DynamicConfigData.t_DownloadReward[1].reward
    -- 奖励列表
    self.list_reward:setItemRenderer(function(idx,obj)
        local reward = rewardData[idx+1]
        local itemCell = BindManager.bindItemCell(obj)
        itemCell:setData(reward.code,reward.amount,reward.type)
    end)
    self.list_reward:setNumItems(#rewardData)

    local ctrl  = self.view:getController("c1")
    -- 领取
    self.btn_take:removeClickListener(100)
    self.btn_take:addClickListener(function()
        -- 加个判断 防止多次领取
        if ModelManager.DownLoadGiftModel.state then
            RollTips.show(Desc.DownLoadGift_takeTips)
            return 
        end
        RPCReq.GamePlay_Modules_DownloadReward_GetDownloadReward({},function()
			ModelManager.DownLoadGiftModel.state = true
            Dispatcher.dispatchEvent(EventType.DownLoadGift_Entrance)
            ViewManager.close("DownLoadGiftView")
        end)
    end,100)

    -- 下载
    self.btn_down:removeClickListener(100)
    self.btn_down:addClickListener(function()
        ModelManager.DownLoadGiftModel.downIndex = 1
        ctrl:setSelectedIndex(ModelManager.DownLoadGiftModel.downIndex)
        Dispatcher.dispatchEvent(EventType.resDownLoad_start)
    end,100)

    -- 暂停
    self.btn_stop:removeClickListener(100)
    self.btn_stop:addClickListener(function()
        ModelManager.DownLoadGiftModel.downIndex = 0
        ctrl:setSelectedIndex(ModelManager.DownLoadGiftModel.downIndex)
        Dispatcher.dispatchEvent(EventType.resDownLoad_stop)
    end,100)
end

--下载状态 code=1时为正在下载 curSize当前下载了多少KB allSize总大小 KB
--code=2时为下载完成
function DownLoadGiftView:resDownLoad_status(_, params)
	
    if params.code == 3 then
        RollTips.show(Desc.DownLoadGift_fail)
        return 
    end
    local ctrl  = self.view:getController("c1")
    -- 进度条
    local progressBar = self.view:getChildAutoType("progressBar")
    local progressVal = 0
    if ModelManager.ResDownloadModel._maxVal == 0 then
        return 
    end
    progressVal = ((ModelManager.ResDownloadModel._curVal + params.curSize)/ModelManager.ResDownloadModel._maxVal)
    if (FileCacheManager.getIntForKey("DownLoadGift",1) == 2 or ModelManager.ResDownloadModel.status == 2) then
        ModelManager.DownLoadGiftModel.downIndex = 2
        ctrl:setSelectedIndex(2)
        progressBar:setMax(100)
        progressBar:setValue(100)
        self.txt_value:setText(string.format(Desc.DownLoadGift_value,string.format("%.4g",100)))
        ModelManager.DownLoadGiftModel:upDateRed()
	else
		progressBar:setMax(100)
        progressBar:setValue(progressVal*100)
        if progressVal > 1 then progressVal = 1 end
		self.txt_value:setText(string.format(Desc.DownLoadGift_value,string.format("%.4g",progressVal*100)))
    end
end

return DownLoadGiftView