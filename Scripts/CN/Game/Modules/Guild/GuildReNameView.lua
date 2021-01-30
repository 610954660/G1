--added by wyang 公会管理列表
local GuildReNameView,Super = class("GuildReNameView",Window)
function GuildReNameView:ctor( ... )
	self._packName = "Guild"
	self._compName = "GuildReNameView"
	self._rootDepth = LayerDepth.PopWindow
	self.txt_input=false;
	self.btn_exit=false;
	self.btn_sure=false;
end

-------------------常用------------------------
--UI初始化
function GuildReNameView:_initUI( ... )
	local txt_input=self.view:getChild('txt_input');
	self.txt_input = BindManager.bindTextInput(txt_input)
	self.txt_input:setMaxLength(6)
	self.btn_exit=self.view:getChild('btn_exit');
	local btn_sure=self.view:getChild('btn_sure');
	local  maxApplyNum ,createCost ,renameCost= GuildModel:getGuildCreateCost();
	self.btn_sure = BindManager.bindCostButton(btn_sure)
	self._cost = {type =CodeType.MONEY, code = 2, amount = renameCost }
	self.btn_sure:setData(self._cost)
end

--UI初始化
function GuildReNameView:_initEvent(...)
	self.btn_exit:addClickListener(
		function(...)
			self.txt_input:setText('');
			self:closeView();
        end
	)
	self.btn_sure:addClickListener(
		function(...)
			local str=self.txt_input:getText();
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
			if StringUtil.utf8len(str) ==0 then
				RollTips.show(Desc.guild_checkStr25)
				return;
			end
			--StringUtil.getStringPixelLength(str)
			if StringUtil.utf8len(str) >7 then
				RollTips.show(Desc.guild_checkStr26)
				return 
			end
			 if StringUtil.containShieldCharacter(str) then
                    RollTips.show(Desc.guild_checkStr34)
                    return
				end
			local info=GuildModel.guildList
			if info.name==str then
				RollTips.show(Desc.guild_checkStr27)
				return
			end
			GuildModel:setGuildName(str)
        end
    )
end


--initEvent后执行
function GuildReNameView:_enter( ... )

end

--页面退出时执行
function GuildReNameView:_exit( ... )
--	self.itemcellArrs = {}

end

-------------------常用------------------------

return GuildReNameView