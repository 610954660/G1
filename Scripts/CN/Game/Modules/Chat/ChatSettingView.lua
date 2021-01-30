---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ChatSettingView,Super = class("ChatSettingView", Window)

function ChatSettingView:ctor()
    self._packName = "Chat"
	self._compName = "ChatSettingView"
	self._rootDepth = LayerDepth.FaceWindow
	self.faceList=false;
end    

function ChatSettingView:_initUI()
	local viewRoot = self.view
	self.choose1=viewRoot:getChild("btn_choose1");
	self.choose2=viewRoot:getChild("btn_choose2");
	self.choose3=viewRoot:getChild("btn_choose3");
	self.choose4=viewRoot:getChild("btn_choose4");
	self.choose5=viewRoot:getChild("btn_choose5");
	self.choose6=viewRoot:getChild("btn_choose6");
	local chooseData=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]
	local chooseData1=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world]
	local chooseData2=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.guild]
	local chooseData3=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.system]
	local chooseData4=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.crossreal]--同城
	local chooseData5=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.worldCross]
	printTable(6,'>>>>>>>>>>>>',chooseData,chooseData1,chooseData2,chooseData3);
	self.choose1:setSelected(chooseData)
	self.choose2:setSelected(chooseData1)
	self.choose3:setSelected(chooseData2)
	self.choose4:setSelected(chooseData3)
	self.choose5:setSelected(chooseData4)
	self.choose6:setSelected(chooseData5)
	self:bindEvent();
end

function ChatSettingView:bindEvent()
	self.choose1:addClickListener(
		function()
			local chooseData=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]
			if chooseData==false then
				chooseData=true;
			else
				chooseData=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]=chooseData;
        end
	)
	self.choose2:addClickListener(
        function()
			local chooseData1=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world]
			if chooseData1==false then
				chooseData1=true;
			else
				chooseData1=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world]=chooseData1;
			printTable(7,'>>>>>>>>>',chooseData1,ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world])
        end
	)
	self.choose3:addClickListener(
        function()
			local chooseData2=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.guild]
			if chooseData2==false then
				chooseData2=true;
			else
				chooseData2=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.guild]=chooseData2;
        end
	)
	self.choose4:addClickListener(
        function()
			local chooseData3=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.system]
			if chooseData3==false then
				chooseData3=true;
			else
				chooseData3=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.system]=chooseData3;
        end
	)

	self.choose5:addClickListener(
        function()
			local chooseData3=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.crossreal]
			if chooseData3==false then
				chooseData3=true;
			else
				chooseData3=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.crossreal]=chooseData3;
        end
	)

	self.choose6:addClickListener(
        function()
			local chooseData3=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.worldCross]
			if chooseData3==false then
				chooseData3=true;
			else
				chooseData3=false;
			end
			ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.worldCross]=chooseData3;
        end
	)
end

function ChatSettingView:_enter()

end

function ChatSettingView:_exit()
	local chooseData=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]
	local chooseData1=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world]
	local chooseData2=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.guild]
	local chooseData3=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.system]
	local chooseData4=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.crossreal]
	local chooseData5=ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.worldCross]
	ModelManager.ChatModel:chatSetMessage(chooseData,chooseData1,chooseData2,chooseData3,chooseData4,chooseData5)
end


return ChatSettingView