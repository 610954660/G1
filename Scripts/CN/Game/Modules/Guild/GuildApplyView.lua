--added by wyang 公会申请窗口
local GuildApplyView, Super = class("GuildApplyView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildApplyView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildApplyView"
    self._rootDepth = LayerDepth.PopWindow

    self.img_head = false
    self.txt_guildName = false
    self.txt_masterName = false
    self.txt_num = false
    self.txt_levelnum = false
    self.txt_num1 = false
    self.txt_notice = false
    self.txt_num2 = false
    self.txt_num3 = false
    self.txt_num4 = false
    self.btn_apply = false
    self.Btn_close = false
end

-------------------常用------------------------
--UI初始化
function GuildApplyView:_initUI(...)
    local info = self._args[1]
    self.img_head = self.view:getChildAutoType("img_head")
    self.txt_guildName = self.view:getChildAutoType("txt_guildName")
    self.txt_masterName = self.view:getChildAutoType("txt_masterName")
    self.txt_num = self.view:getChildAutoType("txt_num")
    self.txt_levelnum = self.view:getChildAutoType("txt_levelnum")
    self.txt_num1 = self.view:getChildAutoType("txt_num1")
    self.txt_notice = self.view:getChildAutoType("txt_notice")
    self.txt_num2 = self.view:getChildAutoType("txt_num2")
    self.txt_num3 = self.view:getChildAutoType("txt_num3")
    self.txt_num4 = self.view:getChildAutoType("txt_num4")
    self.btn_apply = self.view:getChildAutoType("btn_apply")
    self.Btn_close = self.view:getChildAutoType("Btn_close")
    self:showTextAll(info)
end

function GuildApplyView:showTextAll(info)
    self.img_head:setURL(GuildModel:getGuildHead(info.icon))
    self.txt_guildName:setText(info.name)
    self.txt_masterName:setText(info.leaderName)
    self.txt_num:setText(info.activeScore)
    self.txt_levelnum:setText(info.level)
    self.txt_num1:setText(info.id)
    self.txt_notice:setText(info.announcement)
    local configInfo = DynamicConfigData.t_guildLevel[info.level]
    local maxNum = configInfo.limitNum
    local curNum = info.memberNum
    if info.memberNum == nil then
        curNum = 0
    else
        curNum = info.memberNum
    end
    self.txt_num2:setText(curNum .. "/" .. maxNum)
    self.txt_num3:setText(info.joinLimitInfo.level)
    self.txt_num4:setText(GuildModel.settingLv[info.joinLimitInfo.approveType].desc)
    if self._args[2] == 2 then --从公会界面打开不显示按钮
        self.Btn_close:setVisible(false)
        self.btn_apply:setVisible(false)
    else
        self.Btn_close:setVisible(true)
        self.btn_apply:setVisible(true)
    end
    local level = PlayerModel.level
    if info.joinLimitInfo.approveType == 0 then
        self.btn_apply:setTitle(Desc.guild_checkStr2)
        self.btn_apply:removeClickListener(100)
        self.btn_apply:addClickListener(
            function(...)
                -- local isOpenView ,remain= GuildModel:getGuildisOpenTimeView()
                -- if isOpenView==true then
                -- 	local info = {}
                -- 	info.text = "您刚推出公会,需要"..remain.."分钟后可加入新公会"
                -- 	info.type = "yes_no"
                -- 	info.mask = true
                -- 	info.onYes = function()
                -- 	end
                -- 	Alert.show(info)
                -- else
                -- end
                if level < info.joinLimitInfo.level then
                    RollTips.show(Desc.guild_checkStr41)
                elseif curNum >= maxNum then
                    -- body
                    RollTips.show(Desc.guild_checkStr42)
                else
                    printTable(155, "加入公会请求3")
                    GuildModel:joinGuildReq(self._args[1].id)
                end
            end
        ,100)
    elseif info.joinLimitInfo.approveType == 1 then
        printTable(155, "加入公会请求2", info)
        self.btn_apply:setTitle(Desc.guild_checkStr3)
        self.btn_apply:removeClickListener(100)
        self.btn_apply:addClickListener(
            function(...)
                GuildModel:joinGuildReq(self._args[1].id)
            end
        ,100)
    elseif info.joinLimitInfo.approveType == 2 then
        self.btn_apply:setTitle(Desc.guild_checkStr4)
        self.btn_apply:removeClickListener(100)
        self.btn_apply:addClickListener(
            function(...)
                RollTips.show(Desc.guild_checkStr4)
            end
        ,100)
    end
end

--事件初始化
function GuildApplyView:_initEvent(...)
    printTable(155, "加入公会请求1")
    self.Btn_close:addClickListener(
        function(...)
            ViewManager.close("GuildApplyView")
        end
    )
end

function GuildApplyView:_enter(...)

end

--initEvent后执行
function GuildApplyView:guild_Apply_upData(_,data)
    self:showTextAll(data)
end

--页面退出时执行
function GuildApplyView:_exit(...)
    print(1, "GuildApplyView _exit")
end

-------------------常用------------------------

return GuildApplyView
