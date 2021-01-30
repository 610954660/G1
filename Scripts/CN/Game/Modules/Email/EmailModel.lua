--added by xhd 
--邮件模型层
local BaseModel = require "Game.FMVC.Core.BaseModel"
local MailPerPage = 50
local EmailModel = class("EmailModel", BaseModel)
-- local MailType = GameDef.MailType
-- .PMail_Mail {
-- 	mailType 	1:integer
-- 	hasRead 	2:boolean   #设置邮件false未读ture可读
-- 	hasGet		3:boolean	#附件是否已经领取 false未领取 ture已领
-- 	createTime  4:string  	#创建的时间
-- 	content		5:string 	#显示的内容
-- 	contentId 	6:integer 	#内容id
-- 	contentParam 7:*string
-- 	title 		 8:string
-- 	titleId 	 9:integer
-- 	playerId	10:string
-- 	mailId		11:string
-- 	gameRes 	12:*PMail_GameRes
-- 	items 		13:*PItem_Item
-- 	hasItem 	14:boolean #邮件有没有附近 true附件
-- }

function EmailModel:ctor( ... )
	self.__emailDataDict = {}
	self.__haveEmailNotRead = false
	self.__haveNewEmail = false
	self.selectMailId = false
	self.maxPage = 1
	self.cannotRequestFlag = false
	self.__emailIdTb = {}
	self.__emailDataDict = {}
	self.scheduleId = false
end

function EmailModel:clearScheDuleId( ... )
	if self.scheduleId then
		Scheduler.unschedule(self.scheduleId)
		self.scheduleId = false
	end
	self.maxPage = 1
	self.cannotRequestFlag = false
end


function EmailModel:clear( ... )
	self:clearScheDuleId()
	self.__emailDataDict = {}
	self.__haveEmailNotRead = false
	self.__haveNewEmail = false
	self.selectMailId = false
	self.__emailIdTb = {}
	self.__emailDataDict = {}
	self.scheduleId = false
end


function EmailModel:getSelectMailId( ... )
	return self.selectMailId
end

function EmailModel:setSelectMailId( sid )
	self.selectMailId = sid
end
--设置邮件数据
function EmailModel:setEmailData(page, data)
	print(1,"setEmailData page",page)
	local startIndex = (page - 1) * MailPerPage + 1
	for i, v in ipairs(data) do
		self.__emailIdTb[startIndex + i - 1] = v.mailId
		self.__emailDataDict[v.mailId] = v
	end
	self:updateNewMailRed();
end



function EmailModel:getEmailData( ... )
	return self.__emailDataDict
end

function EmailModel:isHaveEmail()
	return #self.__emailIdTb > 0
end

--是否还有未读邮件
function EmailModel:hasNewEmail()
	for _,v in ipairs(self.__emailIdTb) do
		local mail = self:getEmailDataByMailId(v)
			if not mail.hasRead then
				return true
			end
			if #mail.gameRes > 0 and not mail.hasGet then
				return true
			end
	end
	return false
end

--获取邮件剩余多少天过期
function EmailModel:getEmailReaminDay(mailId)
	if not self.__emailDataDict[mailId] then
		return 0
	end

	local hasItem = self:isEmailHasItem(mailId)
	local limitDay = hasItem and 30 or 7
	local currDay = TimeLib.getFormatTimeByType(tonumber(self.__emailDataDict[mailId].createTime)/1000,"d")
	print(1,"当前天数",currDay)
	local ret = limitDay - currDay
	return ret > 0 and ret or 0
end

-- 存在已读邮件
function EmailModel:existHasRead()
	for _,v in ipairs(self.__emailIdTb) do
		local mail = self:getEmailDataByMailId(v)
		if #mail.gameRes == 0 and mail.hasRead then
			return true
		end
		if #mail.gameRes > 0 and mail.hasGet then
			return true
		end
	end
	return false
end

-- 存在可领取奖励的邮件
function EmailModel:existGetMail()
	for _,v in ipairs(self.__emailIdTb) do
		local mail = self:getEmailDataByMailId(v)
		if #mail.gameRes > 0 and not mail.hasGet then
			return true
		end
	end
	return false
end


function EmailModel:getEmailIdTb(needResort)
	if(needResort) then
		table.sort(self.__emailIdTb,function(a,b)
			local mailA = self:getEmailDataByMailId(a)
			local mailB = self:getEmailDataByMailId(b)
			local hadRewardA = #mailA.gameRes > 0 and 1 or 0
			local hadRewardB = #mailB.gameRes > 0 and 1 or 0
			
			local hasReadA = mailA.hasRead and 1 or 0
			local hasReadB = mailB.hasRead and 1 or 0
			local hasGetA = mailA.hasGet and 1 or 0
			local hasGetB = mailB.hasGet and 1 or 0
			if(hasGetA == hasGetB) then
				if(hadRewardA == hadRewardB) then
					if(hasReadA == hasReadB) then
						return mailB.createTime - mailA.createTime < 0
					else
						return hasReadB - hasReadA > 0
					end
				else
					return hadRewardA - hadRewardB > 0
				end
			else
				return hasGetB - hasGetA > 0
			end
		end)
	end
	
	self:updateNewMailRed();
	return self.__emailIdTb
end

function EmailModel:getEmailDataByMailId(mailId)
	return self.__emailDataDict[mailId]
end

--获取邮件标题
function EmailModel:getEmailTitle(mailId)
	local mailData = self:getEmailDataByMailId(mailId)
	local title = nil
	if mailData then
		if mailData.titleId then
			local config = DynamicConfigData.Mail[mailData.titleId]
			title = config and config.desc or nil
		else
			title = mailData.title
		end
	end
	return title or ""
end

--获取邮件内容
function EmailModel:getEmailContent(mailId)
	local mailData = self:getEmailDataByMailId(mailId)
	local contentText = nil
	if mailData then
		local contentId = mailData.contentId
		local contentParam = clone(mailData.contentParam) or {}
		local paramsNum = #contentParam

		if contentId and DynamicConfigData.Mail[contentId] then
			local contentFormat = DynamicConfigData.Mail[contentId].desc
			local _, num = string.gsub(contentFormat, "%%[^%%]", "")
			if paramsNum < num then -- 防止报错
				for i = 1, num - paramsNum do
					table.insert(contentParam, 0)
				end
			end
			contentText = string.format(contentFormat, table.unpack(contentParam))
		else
			contentText = mailData.content
		end
	end
	return contentText or ""
end

--获取创建时间
function EmailModel:getEmailCreateTime(mailId)
	local mailData = self:getEmailDataByMailId(mailId)
	local createTime = nil
	if mailData and mailData.createTime then
		createTime = tonumber(mailData.createTime)
	end
	return createTime or 0
end

-- 邮件类型 MailType
function EmailModel:getEmailType(mailId)
	local mailData = self:getEmailDataByMailId(mailId)
	local mailType = nil
	if mailData then
		mailType = mailData.mailType
	end
	return mailType or 0
end

--邮件物品
function EmailModel:getEmailItemTb(mailId)
	local mailData = self:getEmailDataByMailId(mailId)
	local itemTb = {}
	if mailData then
		local items = mailData.items or {} 	-- 一个真正的物品，带有物品的属性
		local gameRes = mailData.gameRes or {} -- 普通物品

		for i, v in ipairs(items) do
			table.insert(itemTb, v)
		end
		for i, v in ipairs(gameRes) do
			table.insert(itemTb, v)
		end
	end
	return itemTb
end

function EmailModel:getRarestItem(mailId)
	local itemList = self:getEmailItemTb(mailId)
	local ret = nil
	for k,v in pairs(itemList) do
		if not ret then
			ret = v
		elseif v.type == ret.type and ret.type == CodeType.ITEM then
			local config1 = ItemConfiger.getInfoByCode(v.code, v.type)
			local config2 = ItemConfiger.getInfoByCode(ret.code, ret.type)
			if config1 and config2 and config2.color < config1.color then
				ret = v
			end
		elseif v.type == ret.type and ret.type == CodeType.HERO then  --两个都是英雄，显示星级高的
			local config1 = DynamicConfigData.t_hero[v.code]
			local config2 = DynamicConfigData.t_hero[ret.code]
			if config1 and config2 and config2.heroStar < config1.heroStar then
				ret = v
			end
		elseif ret.type == CodeType.ITEM and v.type == CodeType.HERO then --如果有英雄，显示英雄
			ret = v
		end
	end

	return ret
end

--清除邮件
function EmailModel:clearEmailData(mailId)
	if mailId then -- 清理单个
		self.__emailDataDict[mailId] = nil
		local removeIndex = nil
		for i, v in ipairs(self.__emailIdTb) do
			if v == mailId then
				removeIndex = i
				break
			end
		end
		if removeIndex then
			table.remove(self.__emailIdTb, removeIndex)
		end
	else
		self.__emailDataDict = {}
		self.__emailIdTb = {}
		self:clearScheDuleId()
	end
end

--清空最后一页的邮件
function EmailModel:resetLastPageData(  )
	if #self.__emailIdTb<=0 then
		return
	end
	self.maxPage = math.ceil( #self.__emailIdTb/MailPerPage)
	local startIndex = (self.maxPage - 1) * MailPerPage + 1
	for i=#self.__emailIdTb,startIndex,-1 do
		--map数据保留吧 保留一手数据更稳妥
		-- if self.__emailDataDict[self.__emailIdTb[i].mailId] then
		-- 	self.__emailDataDict[self.__emailIdTb[i].mailId] = nil
		-- end
		table.remove(self.__emailIdTb, i)
	end
	print(1,"清除最后一页数据后 ",self.maxPage)
end

--更新邮件的状态
function EmailModel:setOneEmailStatus(data)
	local emailData = self.__emailDataDict[data.mailId]
	if emailData then
		if data.hasRead ~= nil or data.success ~= nil then
			emailData.hasRead = data.hasRead or data.success --or true
		end
		if data.hasItem ~= nil then
			emailData.hasItem = data.hasItem --or data.hasItem or true
		end
		if data.hasGet ~= nil or data.success ~= nil then
			-- 如果背包已满，领取失败 更新参数为false 则会变成默认值true 导致显示错误
			emailData.hasGet = data.hasGet or data.success --or true
		end
	end
	-- printTable(1,emailData)
end

function EmailModel:setEmailsStatus(data)
	for i, v in ipairs(data) do
		self:setOneEmailStatus(v)
	end
end

-- 邮件是否有附件
function EmailModel:isEmailHasItem(mailId)
	if self.__emailDataDict[mailId] then
		return self.__emailDataDict[mailId].hasItem
	end
	return false
end

-- 邮件是否已读
function EmailModel:isEmailHasRead(mailId)
	if self.__emailDataDict[mailId] then
		return self.__emailDataDict[mailId].hasRead
	end
	return false
end

-- 邮件是否已领取
function EmailModel:isEmailHasGet(mailId)
	if self.__emailDataDict[mailId] then
		return self.__emailDataDict[mailId].hasGet
	end
	return false
end

-- 设置还有邮件未读状态
function EmailModel:setHaveEmailNotRead(notRead)
	self.__haveEmailNotRead = notRead or false
end

-- 是否有邮件未读
function EmailModel:isHaveEmailNotRead()
	return self.__haveEmailNotRead
end


function EmailModel:setHaveNewEmail(isHave)
	self.__haveNewEmail = isHave or false
end

--是否有新邮件
function EmailModel:isHaveNewEmail()
	return self.__haveNewEmail
end



--玩家请求邮件
function EmailModel:reqMailGetMail(  )
	if self.scheduleId then
		Scheduler.unschedule(self.scheduleId)
		self.scheduleId = false
	end
	-- if self.cannotRequestFlag and not self:isHaveNewEmail() then --已经初始化过 并且没有新邮件 return
	-- 	Dispatcher.dispatchEvent("update_EmailList")
    --    return
	-- end
	print(1,"reqMailGetMail 从该页开始请求",self.maxPage)
	local params = {}
	params.page = self.maxPage
	params.onSuccess = function (res )
	    printTable(1,"邮件数据",#res.mailList)
		self:setEmailData(self.maxPage,res.mailList)
		if #res.mailList>=50  then
			self.maxPage = self.maxPage + 1
			Dispatcher.dispatchEvent("update_EmailList")
			if self.maxPage > 4 then
				-- self.cannotRequestFlag = true
				return
			end
			print(1,"服务器数据回来了")
			if self.scheduleId then
				Scheduler.unschedule(self.scheduleId)
				self.scheduleId = false
			end
			self.scheduleId = Scheduler.scheduleOnce(0.5, function( ... )
				self:reqMailGetMail()
			end)
			
		else
			self.maxPage = 1
			if self.scheduleId then
				Scheduler.unschedule(self.scheduleId)
				self.scheduleId = false
			end
			Dispatcher.dispatchEvent("update_EmailList")
			-- printTable(1,"整体数据",self.__emailIdTb)
		end
		
	end
	RPCReq.Mail_GetMail(params, params.onSuccess)
end


--玩家请求清理邮件
function EmailModel:reqMailClearMail(  )
	--不需要循环服务器的处理实际会自动删除分50条为一次数据下发
	-- for i=1,self.maxPage do
		local params = {}
		params.page = 1
		params.onSuccess = function (res )
			printTable(1,res)
			local delMailList = res.mailList
			local delCount = res.deleteCount
			if delCount and delCount==0 then
				RollTips.show(Desc.Email_no_email)
			else
				self.maxPage = 1
				self:clearEmailData()
				self:reqMailGetMail()
				--重整数据
				-- if #delMailList then
				-- 	-- self:setEmailData(1,delMailList)
				-- else
				-- 	self:clearEmailData()
				-- end
				-- Dispatcher.dispatchEvent("update_EmailList")
			end
		end
	RPCReq.Mail_CleanMail(params, params.onSuccess)
	-- end
end

function EmailModel:getPageIndexByMailId( mailId )
	local index = 0
	for i=1,#self.__emailIdTb do
		if self.__emailIdTb[i] ==mailId then
			index = i
			break
		end
	end
	return  math.ceil(index/MailPerPage)
end

--请求删除邮件
function EmailModel:reqMailDeleteMail( mailId )
	local params = {}
	local page = self:getPageIndexByMailId(mailId)
	params.page = page or 1
	params.mailId = mailId
	params.onSuccess = function (res )
	    print(1,"Mail_DeleteMail",res)
	    local mailId = res.mailId
		self:clearEmailData(mailId)
		--根据数据 重新计算最大页  __emailIdTb
		self.maxPage = math.ceil( #self.__emailIdTb/MailPerPage)
		Dispatcher.dispatchEvent("update_EmailList")
		if ViewManager.isShow("EmailContentView") then
			ViewManager.close("EmailContentView")
		end
	end
	RPCReq.Mail_DeleteMail(params, params.onSuccess)
end

function EmailModel:updateNewMailRed()
	for i, v in ipairs(self.__emailIdTb) do
		local mail = self:getEmailDataByMailId(v)
		if not mail.hasRead then
			RedManager.updateValue("V_MAIL_ITEM"..i, true);
		elseif #mail.gameRes > 0 and not mail.hasGet then
			RedManager.updateValue("V_MAIL_ITEM"..i, true);
		else
			RedManager.updateValue("V_MAIL_ITEM"..i, false);
		end
	end
	-- print(1, "邮件页签更新",ModelManager.EmailModel:hasNewEmail());
	RedManager.updateValue("V_MAIL_NEW", ModelManager.EmailModel:hasNewEmail())
end


--玩家请求领取邮件
function EmailModel:reqMailGetItem( mailId)
	local params = {}
	params.mailId = mailId
	params.onSuccess = function (res )
	    local data = {}
	    data.success = res.success
	    data.mailId = res.mailId
		data.hasItem = res.hasItem
        self:setOneEmailStatus(data)
		ModelManager.EmailModel:updateNewMailRed()
		Dispatcher.dispatchEvent("update_EmailList")
		if ViewManager.isShow("EmailContentView") then
			ViewManager.call("EmailContentView","updateView")
		end
	end
	RPCReq.Mail_GetItem(params, params.onSuccess)
end

--请求一键提取邮件
function EmailModel:reqMailOneKeyExtract( ... )
	for i=1,self.maxPage do
		local params = {}
		params.page = i
		params.onSuccess = function (res)
			ModelManager.EmailModel:updateNewMailRed()
			Dispatcher.dispatchEvent("update_EmailList")
		end
		RPCReq.Mail_OneKeyExtract(params, params.onSuccess)
	end
end

--请求设置邮件已读
function EmailModel:reqMailSetMailHasRead( mailId )
	print(1,"reqMailSetMailHasRead")
	local params = {}
	params.mailId = mailId
	params.onSuccess = function (res )
	    local  data = {}
	    data.hasRead = res.hasRead
	    data.mailId = res.mailId
	    data.hasItem = res.hasItem
	    --printTable(1,data)
	    self:setOneEmailStatus(data)
	    Dispatcher.dispatchEvent("update_EmailList2")
        ViewManager.open("EmailContentView",{mailId = mailId})
	end
	RPCReq.Mail_SetMailHasRead(params, params.onSuccess)
end

return EmailModel