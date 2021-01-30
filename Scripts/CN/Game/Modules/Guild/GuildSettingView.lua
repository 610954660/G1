--added by wyang 公会管理列表
local GuildSettingView, Super = class("GuildSettingView", Window)
function GuildSettingView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildSettingView"
    self._rootDepth = LayerDepth.PopWindow
    self.btn_editNotice = false
    self.guildlName = false
    self.txt_notice = false
    self.img_head = false
    self.curHeadId = false
    self.curneedLevel = 5
    self.curneedRule = 0
    self.Btn_close=false
end

-------------------常用------------------------
--UI初始化
function GuildSettingView:_initUI(...)
    local info = GuildModel.guildList
    self.curneedLevel = info.joinLimitInfo.level
    self.curneedRule = info.joinLimitInfo.approveType
    self.btn_editNotice = self.view:getChild("btn_editNotice")
    self.guildlName = self.view:getChild("txt_guildName")
    self.guildlName:setText(info.name)
    self.txt_notice = self.view:getChild("txt_notice")
    self.txt_notice:setText(info.announcement)
    self.Btn_close = self.view:getChild("Btn_close")
    --self.txt_notice:setTouchable(false)
    self.img_head = self.view:getChild("img_head")
    self.curHeadId = info.icon
    self.img_head:setURL(GuildModel:getGuildHead(info.icon))
    self:setRuleText()
    self:setLevelText()
    local reGuildName = self.view:getChild("btn_reGuildName")
    reGuildName:addClickListener(
        function(...)
            ViewManager.open("GuildReNameView")
        end
    )
    
    self.Btn_close:addClickListener(
        function(...)
            ViewManager.close("GuildSettingView")
        end
    )
    local btnReplace = self.view:getChild("btn_replace")
    btnReplace:addClickListener(
        function(...)
            ViewManager.open("GuildHeadView", {self.curHeadId})
        end
    )
    local btnLevelLetf = self.view:getChild("btn_levelLetf")
    btnLevelLetf:addClickListener(
        function(...)
            self.curneedLevel = self.curneedLevel - 5
            if self.curneedLevel <= 10 then
                self.curneedLevel = 10
            end
            self:setLevelText()
        end
    )

    local btnLevelrigth = self.view:getChild("btn_levelrigth")
    btnLevelrigth:addClickListener(
        function(...)
            self.curneedLevel = self.curneedLevel + 5
            if self.curneedLevel >= 100 then
                self.curneedLevel = 100
            end
            self:setLevelText()
        end
    )

    local btnRuhuiLeft = self.view:getChild("btn_ruhuiLeft")
    btnRuhuiLeft:addClickListener(
        function(...)
            self.curneedRule = self.curneedRule - 1
            if self.curneedRule < 0 then
                self.curneedRule = 2
            end
            self:setRuleText()
        end
    )

    local btnRuhuiright = self.view:getChild("btn_ruhuiright")
    btnRuhuiright:addClickListener(
        function(...)
            self.curneedRule = self.curneedRule + 1
            if self.curneedRule > 2 then
                self.curneedRule = 0
            end
            self:setRuleText()
        end
    )

    local btn_manage = self.view:getChild("btn_manage")
    btn_manage:addClickListener(
        function(...)
            local str = self.txt_notice:getText()
			if (StringUtil.isOnlyNumberOrCharacter(str)) then
				RollTips.show(Desc.input_tips2);
				return;
            end
            local newText=StringUtil.filterString(str)
            if newText ~= str then  
                RollTips.show(Desc.input_tips3); 
                return 
            end
            str = newText
            local info = {}
            info["level"] = self.curneedLevel
            info["approveType"] = self.curneedRule
            GuildModel:setGuildInfo(self.curHeadId, str, info)
        end
    )
    -- self.btn_editNotice:addClickListener(
    --     function(...)
    --         self.txt_notice:setTouchable(true);
    --     end
    -- )
end

function GuildSettingView:setLevelText(...)
    local text = self.view:getChild("n50")
    text:setText(self.curneedLevel)
end

function GuildSettingView:setRuleText(...)
    local text = self.view:getChild("n54")
    text:setText(GuildModel.settingLv[self.curneedRule].desc)
end

--工会基础信息刷新刷新
function GuildSettingView:guild_up_guildBaseInfo()
    local info = GuildModel.guildList
    self.guildlName:setText(info.name)
end

function GuildSettingView:guild_up_headId(_, id)
    self.curHeadId = id
    self.img_head:setURL(GuildModel:getGuildHead(id))
end

--initEvent后执行
function GuildSettingView:_enter(...)
end

--页面退出时执行
function GuildSettingView:_exit(...)
    --	self.itemcellArrs = {}
end

-------------------常用------------------------

return GuildSettingView
