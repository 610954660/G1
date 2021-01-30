---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by gqy.
--- DateTime: 2020/8/19 17:21
---

local EmailContentView = class("EmailContentView",Window)
local TimeLib = require "Game.Utils.TimeLib"

function EmailContentView:ctor()
    self._packName = "Email"
    self._compName = "EmailContentView"
    self._rootDepth = LayerDepth.PopWindow
    self.datas = false
end

function EmailContentView:_initUI()
    self.txtSource = self.view:getChildAutoType("txtSource")
    self.txtTime = self.view:getChildAutoType("txtTime")
    self.txtLimit = self.view:getChildAutoType("txtLimit")
    self.txtContent = self.view:getChildAutoType("txtContent/txtContent")
    self.itemList = self.view:getChildAutoType("itemList")
    self.btnGet = self.view:getChildAutoType("btnGet")
    self.btnDelete = self.view:getChildAutoType("btnDelete")
    self.hasGetCtrl = self.view:getController("hasGet")

    self.itemList:setItemRenderer(function(index,obj)
        self:itemListRenderer(index,obj)
    end)

    self.btnGet:addClickListener(function()
        self:onBtnGetClick()
    end,1)

    self.btnDelete:addClickListener(function()
        self:onBtnDelete()
    end,1)

    self:updateItemList()
    self:updateView()
end

function EmailContentView:_exit()
    self.datas = false
end

function EmailContentView:updateView()
    -- print(1,"self._args.mailId",self._args.mailId)
    local hasRead = EmailModel:isEmailHasRead(self._args.mailId)
    local hasItem = EmailModel:isEmailHasItem(self._args.mailId)
    local hasGet = EmailModel:isEmailHasGet(self._args.mailId)
    local mailType = EmailModel:getEmailType(self._args.mailId)
    local createTime = EmailModel:getEmailCreateTime(self._args.mailId)
    local contentText = EmailModel:getEmailContent(self._args.mailId)
    local title = EmailModel:getEmailTitle(self._args.mailId)
    local remainDay = EmailModel:getEmailReaminDay(self._args.mailId)

    self.txtTime:setText(TimeLib.msToString(createTime,"%Y.%m.%d"))
    self.txtSource:setText(mailType == 0 and Desc.Email_Text1 or Desc.Email_Text1)
    self.txtContent:setText(contentText)
    self.txtLimit:setText(remainDay)
    self:setTitle(Desc.Email_Text2)--title)

    if hasItem then
        self.view:getController("readStatus"):setSelectedIndex(hasGet and 1 or 0)
    else
        self.view:getController("readStatus"):setSelectedIndex(hasRead and 1 or 0)
    end

    self.view:getController("type"):setSelectedIndex(hasItem and 1 or 0)
end

function EmailContentView:updateItemList()
    local hasItem = EmailModel:isEmailHasItem(self._args.mailId)

    if hasItem then
        self.datas = ModelManager.EmailModel:getEmailItemTb(self._args.mailId)
        self.itemList:setNumItems(#self.datas)
    end
end

function EmailContentView:itemListRenderer(index,obj)
    local itemCell = BindManager.bindItemCell(obj)
    local itemData = self.datas[index + 1]
    itemCell:setData(itemData.code,itemData.amount,itemData.type)
end

function EmailContentView:onBtnGetClick()
    EmailModel:reqMailGetItem(self._args.mailId)
end

function EmailContentView:onBtnDelete()
    EmailModel:reqMailDeleteMail(self._args.mailId)
end


return EmailContentView