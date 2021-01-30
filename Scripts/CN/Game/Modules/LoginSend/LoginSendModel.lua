
local LoginSendModel = class("LoginSendModel",BaseModel)

function LoginSendModel:ctor()
    self.state = true  -- 领取状态
    self.data = false 
    self.openLv = false 
    self:initListeners();
end

function LoginSendModel:initData(data)
    self.data = {}
    self.data = data
    self:upDateInfo()
end

-- function LoginSendModel:player_updateRoleInfo()
--     self:upDateInfo()
-- end

-- function LoginSendModel:module_open_hint()
--     self:upDateInfo()
-- end

function LoginSendModel:upDateInfo()
    if self.data then
        if not ModuleUtil.getModuleOpenTips(ModuleId.LoginSend.id) then
            self.state = self.data.state or false
			Dispatcher.dispatchEvent(EventType.mainui_updateLeftTopBtns)
        end
        if not self.state then
            -- 判断是不是今天首次登录
            local dayStr = DateUtil.getOppostieDays()
            local isShow = FileCacheManager.getBoolForKey("LoginSendView_isShow" .. dayStr,false)
            if not isShow then
                ModuleUtil.openModule(ModuleId.LoginSend.id,false)
            end
        end
    end
    self:upDateRed()
    Dispatcher.dispatchEvent(EventType.LoginSend_Entrance)
end

function LoginSendModel:upDateRed()
    RedManager.updateValue("M_LOGINSEND", not self.state)
end

function LoginSendModel:loginPlayerDataFinish()

end

-- 进入游戏
-- function LoginSendModel:public_enterGame()
--     print(8848,">>>>>>>3333333333333333>>>")
--     -- 判断有没有领取过
--     if not self.state then
--         ModuleUtil.openModule(ModuleId.LoginSend.id,false)
--     end
-- end


return LoginSendModel