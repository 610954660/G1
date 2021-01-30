
-- added by zn
-- 新手设置昵称
local NameCtrl = require "Game.ConfigReaders.NameConfiger";

local GuideSetNameView = class("GuideSetNameView", View)

function GuideSetNameView: ctor()
    self._packName = 'GuideRoleChose';
    self._compName = "GuideSetNameView";

    self.btn_cancel = false;
    self.btn_sure = false;
    self.btn_random = false;
    self.txt_input = false;
    self.txt_hint = false;
    self.btn_male = false;
    self.btn_female = false;
    self.sex = 1--self._args.sex;
	self._rootDepth = LayerDepth.PopWindow
end

function GuideSetNameView: _initUI()
	PHPUtil.reportStep(ReportStepType.ENTER_CREATE_ROLE)
    self.btn_cancel = self.view:getChild('btn_cancel');
    self.btn_sure = self.view:getChild('btn_sure');
    self.btn_random = self.view:getChild('btn_random');
    self.txt_input = self.view:getChild('txt_input');
    self.txt_hint = self.view:getChild('txt_hint');
    self.btn_male = self.view:getChildAutoType("male");
    self.btn_female = self.view:getChildAutoType("female");
    -- self.txt_input:setText(NameCtrl.randomName(self.sex));
    self.txt_input:setMaxLength(50);
    self.txt_input:onChanged(function (content)
        self.txt_input:setText(StringUtil.limitStringLen(content, 12))
		self.txt_hint:setVisible(#content == 0)
    end);

end

function GuideSetNameView: _initEvent()
    self.btn_male:addClickListener(function ()
        self.sex = 1;
    end)

    self.btn_female:addClickListener(function ()
        self.sex = 2;
    end)

    self.btn_random:addClickListener(function ()
        self.txt_input:setText(NameCtrl.randomName(self.sex));
		self.txt_hint:setVisible(false)
    end)

    self.btn_cancel:addClickListener(function ()
        self:closeView();
    end)

    self.btn_sure:addClickListener(function ()
        if (self.txt_input:getText() == "") then
            RollTips.show(Desc.input_tips1);
            return;
        end
		if (StringUtil.isOnlyNumberOrCharacter(self.txt_input:getText())) then
			RollTips.show(Desc.input_tips2);
			return;
        end
        local newText=StringUtil.filterString(self.txt_input:getText())
        if newText ~= self.txt_input:getText() then  
            RollTips.show(Desc.input_tips3); 
            return 
        end
		PHPUtil.reportStep(ReportStepType.CLICK_CR_BTN)
        local name = self.txt_input:getText();
        RPCReq.GamePlay_Modules_Rename_sex({sex=self.sex}, function (param1)

            printTable(2233, "修改性别==========", param1);
            -- 修改性别
            PlayerModel.sex = self.sex;

            RPCReq.GamePlay_Modules_Rename_OneselfRename({playerName = name}, function (param)
                LuaLogE(DescAuto[154], param); -- [154]="修改姓名=========="
				PHPUtil.reportStep(ReportStepType.CREATE_ROLE_SUCCESS)
                RollTips.show(DescAuto[155]); -- [155]='成功创建角色'
				SDKUtil.recordRoleInfo(AgentConfiger.SDK_RECORD_CREATE_ROLE)
                
                PlayerModel.username = name
                PlayerModel.nameFlag = true
				--提交玩家数据到api中心
				PHPUtil.updatePlayer()
                
                Dispatcher.dispatchEvent(EventType.guide_setNameSuccess);
                Dispatcher.dispatchEvent(EventType.player_rename_success, name)
                self:closeView();
                ViewManager.close("GuideRoleChoseView");
            end)
            
        end)
    end)
end

return GuideSetNameView;
