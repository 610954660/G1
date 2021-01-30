local LoginSendController = class("LoginSendController", Controller)

function LoginSendController:GamePlay_UpdateData (_,param)
   -- printTable(8848,"param>>>>>>>>>>",param)
	if param.gamePlayType == GameDef.GamePlayType.LoginToSend then
		LoginSendModel:initData(param.gp.loginToSend)
	end
end

return LoginSendController