
local EditBoxView,Super = class("EditBoxView", Window)

function EditBoxView:ctor()
	LuaLogE("PlayerHeadView ctor")
	self._packName = "Player"
	self._compName = "EditBox"
	self._rootDepth = LayerDepth.PopWindow
	self.sureBtn = false
	self.inputText = false
	self.cancelBtn = false
	-- self._isFullScreen = true
end



function EditBoxView:_initUI()
	LuaLogE("EditBoxView _initUI")

	self:setTitle(Desc.player_editName)
	
	self.inputText = self.view:getChildAutoType("edittext")
	self.inputText:setText(PlayerModel.username)
	self.inputText:setMaxLength(50)
	self.inputText:onChanged(function (content)
        self.inputText:setText(StringUtil.limitStringLen(content, 12))
	end);
	
	self.sureBtn = self.view:getChildAutoType("Btn")

	self.sureBtn:addClickListener(function()
		if (self.inputText:getText() == "") then
			RollTips.show(Desc.input_tips1);
			return;
		end
		if (StringUtil.isOnlyNumberOrCharacter(self.inputText:getText())) then
			RollTips.show(Desc.input_tips2);
			return;
		end

		local newText=StringUtil.filterString(self.inputText:getText())
		if newText ~= self.inputText:getText() then  
			RollTips.show(Desc.input_tips3); 
			return 
		end


		self:sendRename()
		self:closeView()
			
	end)
	
	self.cancelBtn = self.view:getChildAutoType("cancel")

	self.cancelBtn:addClickListener(function()
			self:closeView()

		end)
	local descText = self.view:getChildAutoType("descText")
	if PlayerModel.nameFlag then
		descText:setText(Desc.player_renamecode6:format(DynamicConfigData.Const.RenameDiamondCost))
	else
		descText:setText(Desc.player_renamecode7)
	end
		
end

function EditBoxView:_initEvent( ... )
	--self:addEventListener(EventType.login_chooseServer,self)
end

function EditBoxView:sendRename( ... )
	local nametext = self.inputText:getText();
	
	print(33,"nametext = ",nametext)
	if nametext == PlayerModel.username then
		--RPCReq.GamePlay_Modules_Rename_OneselfRename({playerName = nametext})

	elseif nametext ~= "" then
		RPCReq.GamePlay_Modules_Rename_OneselfRename({playerName = nametext}, function()
			
		end)
	end
	
end


return EditBoxView