
--added by xhd 
--邮件控制器
local EmailController = class("EmailController",Controller)

--通知有新邮件
function EmailController:Mail_HasNewMail()
	print(1,"通知有新邮件")
    ModelManager.EmailModel:setHaveNewEmail(true)
	ModelManager.EmailModel:updateNewMailRed()
	Dispatcher.dispatchEvent("init_emailView")
	RedManager.updateValue("V_MAIL_NEW", true);
end

--更新单个邮件 单个领取状态更新
function EmailController:Mail_MailSync( _,params )
	print(1,"Mail_MailSync 更新单个邮件")
	-- printTable(1,params)
	local data = {}
	data.mailId = params.mailId
	data.hasGet = params.hasGet
	data.hasRead = params.hasRead
	ModelManager.EmailModel:setEmailsStatus(data)
    printTable(1,data)
    Dispatcher.dispatchEvent("update_EmailList")
end

--通知有可领取邮件
function EmailController:Mail_HasMailItemNotGet( _,params )
	-- print(1,"Mail_HasMailItemNotGet 通知有可领取邮件")
	GlobalUtil.delayCallOnce("TaskModel:Mail_HasMailItemNotGet",function()
		print(1,"Mail_HasMailItemNotGet 通知有可领取邮件")
		if params.hasItem then
			ModelManager.EmailModel:updateNewMailRed()
			RedManager.updateValue("V_MAIL_NEW", true);
		end
	end, self, 0.1)

	-- body
end

--一键领取之后邮件状态更新
function EmailController:Mail_UpdateStatus( _,params )
	--print(1,"Mail_UpdateStatus")
	--printTable(1,params)
	
	ModelManager.EmailModel:setEmailsStatus(params.mailStatus)
	ModelManager.EmailModel:updateNewMailRed()
	RedManager.updateValue("V_MAIL_NEW", true);
	Dispatcher.dispatchEvent("update_EmailList")
end

return EmailController