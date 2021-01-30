--added by wyang 公会公告编辑
local GuildEditNoticeView,Super = class("GuildEditNoticeView", Window)

function GuildEditNoticeView:ctor()
	LuaLogE("PlayerHeadView ctor")
	self._packName = "Guild"
	self._compName = "GuildEditNoticeView"
	self._rootDepth = LayerDepth.PopWindow
	self.btn_ok = false
	self.txt_input = false
	self.btn_no = false
end


function GuildEditNoticeView:_initUI()
	local guildInfo=GuildModel.guildList;
	local txt_input = self.view:getChildAutoType("txt_input")
	self.txt_input = BindManager.bindTextInput(txt_input)
	self.txt_input:setText(guildInfo.notice)
	self.txt_input:setMaxLength(120)
	self.btn_ok = self.view:getChildAutoType("btn_ok")
	self.btn_no = self.view:getChildAutoType("btn_no")
	self.btn_ok:addClickListener(function()
		local noticeText = self.txt_input:getText();
		if (StringUtil.isOnlyNumberOrCharacter(noticeText)) then
			RollTips.show(Desc.input_tips2);
			return;
        elseif StringUtil.filterString(self.txt_input:getText()) ~= self.txt_input:getText() then  
			RollTips.show(Desc.input_tips3); 
		    return;
		elseif noticeText == guildInfo.notice then
			RollTips.show(Desc.guild_checkStr16)
		elseif StringUtil.containShieldCharacter(noticeText) then
			RollTips.show(Desc.chat_sensitive_word)
			printTable(9,'/////2')
		elseif StringUtil.utf8len(noticeText)>100 then
			RollTips.show(Desc.guild_checkStr17)
			printTable(9,'/////3')
		else
			GuildModel:setGuildNotice(noticeText)
		end
	end)

	self.btn_no:addClickListener(function()
			self:closeView()
		end)
end

function GuildEditNoticeView:_initEvent( ... )
	--self:addEventListener(EventType.login_chooseServer,self)
end


return GuildEditNoticeView