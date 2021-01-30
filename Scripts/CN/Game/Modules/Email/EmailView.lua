--added by xiehande
--邮件系统子页
local EmailView = class("EmailView", Window)
local TimeLib = require "Game.Utils.TimeLib"

function EmailView:ctor()
	self._packName = "Email"
    self._compName = "EmailView"
	self._rootDepth = LayerDepth.Window

    self.selectedIndex = 0 --选中
    self.Data = false
end

--重写方法 初始化UI
function EmailView:_initUI( ... )
	self.itemcellArr = {}
	self.haveMailCtrl = self.view:getController("haveMail") --是否存在邮件控制器
	self.emailList = self.view:getChildAutoType("emailList") --邮件列表
	self.btnJustGet = self.view:getChildAutoType("btnJustGet") --一键领取
	self.btnDelete = self.view:getChildAutoType("btnDelete") --一键删除
	self.txtMailCount = self.view:getChildAutoType("txtMailCount") --数量

    
end


--事件初始化
function EmailView:_initEvent( ... )
	
	
	print(999,"EmailView _initEvent")

	self.emailList:setVirtual()
	self.emailList:setItemRenderer(function(index,obj)
		self:emailListRenderer(index,obj)
	end)

	-- 一键提取
	self.btnJustGet:addClickListener(function()
		self:onBtnJustGetClick()
	end)

	-- 一键删除
	self.btnDelete:addClickListener(function()
		self:onBtnDeleteClick()
	end)
	EmailModel:resetLastPageData()
	EmailModel:reqMailGetMail()

end

function EmailView:emailListRenderer(index,obj)
	local mailId = self.Data[index + 1]
	local hasRead = EmailModel:isEmailHasRead(mailId)
	local hasItem = EmailModel:isEmailHasItem(mailId)
	local hasGet = EmailModel:isEmailHasGet(mailId)
	local title = EmailModel:getEmailTitle(mailId)
	local mailType = EmailModel:getEmailType(mailId)
	local createTime = EmailModel:getEmailCreateTime(mailId)
	local contentText = EmailModel:getEmailContent(mailId)
	local remainDay = EmailModel:getEmailReaminDay(mailId)

	local emailItem = obj:getChildAutoType("emailItem")
	local txtTitle = emailItem:getChildAutoType("txtTitle") --邮件标题
	local txtDate = emailItem:getChildAutoType("txtDate") --邮件时间
	local txtType = emailItem:getChildAutoType("txtType") --邮件来源
	local txtBanner = emailItem:getChildAutoType("txtBanner") --邮件简略
	local redDot = obj:getChildAutoType("img_red") --红点

	printTable(999,"邮件数据",title)
	obj:getController("type"):setSelectedIndex(hasItem and 1 or 0)
	emailItem:getController("type"):setSelectedIndex(hasItem and 1 or 0)

	if hasItem then
		local showItem = EmailModel:getRarestItem(mailId)
		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		itemCell:setData(showItem.code,showItem.amount,showItem.type)
		obj:getController("readStatus"):setSelectedIndex(hasGet and 1 or 0)
		emailItem:getController("readStatus"):setSelectedIndex(hasGet and 1 or 0)
	else
		obj:getController("readStatus"):setSelectedIndex(hasRead and 1 or 0)
		emailItem:getController("readStatus"):setSelectedIndex(hasRead and 1 or 0)
	end
	contentText = StringUtil.trim(contentText)
	contentText = StringUtil.expendEnter(contentText)
	if StringUtil.utf8len(contentText) > 20 then
		contentText = StringUtil.utf8sub(contentText,0,20).."......"
	end

	txtTitle:setText(title)
	if mailType >1 then
		txtType:setText(Desc.Email_Text3)
	else
		txtType:setText(Desc.Email_Text4)
	end
	
	txtDate:setText(string.format(Desc.Email_Text5,TimeLib.msToString(createTime,"%Y.%m.%d"),remainDay))
	txtBanner:setText(contentText)

	obj:removeClickListener(100)
	emailItem:addClickListener(function()
		self:setClickEmailFunc(index + 1)
	end,100)

	obj:getChildAutoType("btnGet"):addClickListener(function()
		self:onMailGetClick(index + 1)
	end,1)

	obj:getChildAutoType("btnDelete"):addClickListener(function()
		self:onMailDeleteClick(index + 1)
	end,1)
	RedManager.register("V_MAIL_ITEM"..(index + 1), redDot)
end

function EmailView:setClickEmailFunc(index)
	self.selectedIndex = index
	local mailID = self.Data[index]
	local hasRead = EmailModel:isEmailHasRead(mailID)
	local hasItem = EmailModel:isEmailHasItem(mailID)
	if not hasItem then
		if not hasRead then
			EmailModel:reqMailSetMailHasRead(mailID)
			return
		end
	end
	ViewManager.open("EmailContentView",{mailId = mailID})
end

function EmailView:onMailGetClick(index)
	EmailModel:reqMailGetItem(self.Data[index])
end

function EmailView:onMailDeleteClick(index)
	EmailModel:reqMailDeleteMail(self.Data[index])
end

function EmailView:onBtnJustGetClick()
	if EmailModel:existGetMail() then
		EmailModel:reqMailOneKeyExtract()
	else
		RollTips.show(Desc.Email_no_award)
	end
end

function EmailView:onBtnDeleteClick()
	if EmailModel:existHasRead() then
		local info =
		{
			text = Desc.Email_Text6,
			type ="yes_no",
			onYes = function()
				EmailModel:reqMailClearMail()
			end,
		}
		Alert.show(info)
	else
		RollTips.show(Desc.Email_no_email)
	end
end

--更新右边邮件内容
function EmailView:updateEmailContentLayer( ... )
	print(1,"updateEmailContentLayer")
	if not self.mailId then
		return
	end
	
	local contentText = EmailModel:getEmailContent(self.mailId)
	self.contentLabel:addEventListener(FUIEventType.ClickLink, function(data)
		RollTips.showWebPage("", data:getDataValue())
	end, 11);
	self.contentLabel:setText(contentText)
	
	local mailData = EmailModel:getEmailDataByMailId(self.mailId)

	if mailData.titleId then
		self.txt_title:setText(DynamicConfigData.Mail[tonumber(mailData.titleId)].desc);
	elseif (mailData.title) then
		self.txt_title:setText(mailData.title)
	end
		
	
	
	self.contentScrollPanel:getScrollPane():scrollTop()

	local hasGet = EmailModel:isEmailHasGet(self.mailId)
	local hasItem = EmailModel:isEmailHasItem(self.mailId)
	if  hasItem then
		self.typeCtrl:setSelectedIndex(0)
	else
		self.typeCtrl:setSelectedIndex(1)
	end
	local ctrl = self.view:getController("hasGet");
	if hasItem and not hasGet then
		self.deleteBtn:setVisible(false)
		ctrl:setSelectedIndex(0);
		self.receiveBtn:setVisible(true)
	else
		self.deleteBtn:setVisible(true)
		ctrl:setSelectedIndex(1);
		self.receiveBtn:setVisible(false)
	end
	self.itemData = EmailModel:getEmailItemTb(self.mailId)
	self.itemList:setData(self.itemData)
end


--更新邮件列表
function EmailView:update_EmailList()
	local emailTb = EmailModel:getEmailIdTb(true)
	local emailNum = #emailTb
	self.Data = emailTb
	self.emailList:setData(emailTb)
	if emailNum <= 0 then
		self.haveMailCtrl:setSelectedIndex(0)
	else
		self.haveMailCtrl:setSelectedIndex(1)
		self.txtMailCount:setText(string.format("%s/%s",emailNum,200))
	end
end

function EmailView:update_EmailList2( ... )
	local emailTb = EmailModel:getEmailIdTb(true)
	local emailNum = #emailTb
	self.Data = emailTb
	self.emailList:setData(self.Data)
end


--页面退出时执行
function EmailView:_exit( ... )
	self.itemcellArr = {}
	self.itemcellArr = nil
	print(1,"EmailView _exit")
end


return EmailView