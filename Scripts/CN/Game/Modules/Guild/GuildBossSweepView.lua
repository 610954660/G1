--added公会boss扫荡界面
local GuildBossSweepView, Super = class("GuildBossSweepView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildBossSweepView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildBossSweepView"
    self._rootDepth = LayerDepth.PopWindow
    self.btn_ok = false
    self.txt_hurt = false
    self.img_box = false
    self.txt_limitcount = false
end

-------------------常用------------------------
--UI初始化
function GuildBossSweepView:_initUI(...)
    self.chapterContr=self.view:getController('c1');
    self.btn_ok = self.view:getChildAutoType("btn_ok")
    self.txt_hurt = self.view:getChildAutoType("txt_hurt")
    self.img_box = self.view:getChildAutoType("img_box")
    self.txt_limitcount = self.view:getChildAutoType("txt_limitcount")
    self:showSweepView()
end

function GuildBossSweepView:showSweepView()
    self.chapterContr:setSelectedIndex(0)
    local copyCode = self._args.copyCode
    local hurt = GuildModel:getBossHurt(copyCode)
    local configInfo = DynamicConfigData.t_bossReward
    local configData = configInfo[copyCode]
    local curBoxIdex=1
    local rewardIcon=10002000
    for i = 1, #configData, 1 do
        local configItem = configData[i]
        if hurt>=configItem.damageMin   and hurt <= configItem.damageMax then
            curBoxIdex=i
            rewardIcon=configItem.rewardIcon
        elseif hurt>configData[#configData].damageMin then
            curBoxIdex=#configData
            rewardIcon=configItem.rewardIcon
        end
    end
    self.txt_hurt:setText(hurt)
    self.txt_limitcount:setText("X"..(curBoxIdex-1))
    self.img_box:setURL(PathConfiger.getItemIcon(rewardIcon))
end

--事件初始化
function GuildBossSweepView:_initEvent(...)
    -- self.btn_no:addClickListener(
    --     function(...)
    --         self:closeView()
    --     end
    -- )
    self.btn_ok:addClickListener(
        function(...)
            GuildModel:QuickChallengeGuildBoss(self._args.copyCode)
        end
    )
    
end

function GuildBossSweepView:materialCopy_updata(_, data)
    printTable(5, "点击扫荡1")
    if data and data.type then
        local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(data.type)
        if remainTimes<=0 then 
            self:closeView()
        end
    end
end

--initEvent后执行
function GuildBossSweepView:_enter(...)
    print(1, "GuildBossSweepView _enter")
end

--页面退出时执行
function GuildBossSweepView:_exit(...)
    print(1, "GuildBossSweepView _exit")
end

-------------------常用------------------------

return GuildBossSweepView
