--Name : ServiceCommitView.lua
--Author : generated by FairyGUI
--Date : 2020-6-12
--Desc :

local ServiceCommitView, Super = class("ServiceCommitView", Window)
local CustomPhotoConfiger = require "Game.Modules.ServiceCommit.CustomPhotoConfiger"
local photoFullPath = CustomPhotoConfiger:getTempPhotoPath()
function ServiceCommitView:ctor()
    --LuaLog("ServiceCommitView ctor")
    self._packName = "ServiceCommit"
    self._compName = "ServiceCommitView"
    self._rootDepth = LayerDepth.PopWindow
    self._fileName = {}
    self._chooseList = false
end

function ServiceCommitView:_initEvent()
end

function ServiceCommitView:_initVM()
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:ServiceCommit.ServiceCommitView
    vmRoot.btn_Commit = viewNode:getChildAutoType("$btn_Commit")
    --Button
    vmRoot.btn_jietu = viewNode:getChildAutoType("$btn_jietu")
    --Button
    vmRoot.btn_jindu = viewNode:getChildAutoType("$btn_jindu")
    --Button
    vmRoot.txt_content = viewNode:getChildAutoType("$txt_content")
    --text
    vmRoot.txt_myqq = viewNode:getChildAutoType("$txt_myqq")
    --text
    vmRoot.btn_famkui = viewNode:getChildAutoType("$btn_famkui")
    --Button
    vmRoot.txt_myphone = viewNode:getChildAutoType("$txt_myphone")
    --text
    vmRoot.list_sendPic = viewNode:getChildAutoType("$list_sendPic")
    --list
    vmRoot.txt_titile = viewNode:getChildAutoType("$txt_titile")
    --text
    vmRoot.list_info = viewNode:getChildAutoType("$list_info")
    --list
    --{vmFieldsEnd}:ServiceCommit.ServiceCommitView
    --Do not modify above code-------------
end

function ServiceCommitView:_initUI()
    self:_initVM()
    ServiceCommitModel:feedBackMy(1)
    self:showfanKuiView()
end

function ServiceCommitView:_initEvent(...)
    self.btn_famkui:addClickListener(
        function(...)
            self:showfanKuiView()
        end
    )

    self.btn_jindu:addClickListener(
        function(...)
            self:showJinduView()
            self._fileName = {}
            local count, temp = self:getImgCount()
            printTable(16, "ewqereqw", count, temp)
            self.list_sendPic:setItemRenderer(
                function(index, obj)
                    local imgUrl = temp[index + 1]
                    local img_sendPic = obj:getChildAutoType("$img_sendPic")
                    img_sendPic:setURL(imgUrl)
                end
            )
            self.list_sendPic:setNumItems(count)
        end
    )

    self.btn_Commit:addClickListener(
        function(...)
            self:sendProblem()
        end
    )

    self.btn_jietu:addClickListener(
        --打开相册
        function(...)
            local count, temp = self:getImgCount()
            printTable(16, "adsfadfadsf", count, temp)
            if count < 1 then
                self:openAlbum()
            else
                RollTips.show(DescAuto[268]) -- [268]="最多上传1张截图"
            end
        end
    )
end

function ServiceCommitView:setCommitImage(e, fileName)
    if fileName == "" then
        return
    end
    for key, value in pairs(self._fileName) do
        cc.TextureCache:getInstance():removeTextureForKey(value)
    end
    self._fileName[fileName] = fileName
    local count, temp = self:getImgCount()
    printTable(16, "ewqereqw", count, temp)
    self.list_sendPic:setItemRenderer(
        function(index, obj)
            local imgUrl = temp[index + 1]
            local img_sendPic = obj:getChildAutoType("$img_sendPic")
            img_sendPic:setURL(imgUrl)
        end
    )
    self.list_sendPic:setNumItems(count)
end

function ServiceCommitView:getImgCount()
    local idex = 0
    local temp = {}
    if next(self._fileName) ~= nil then
        for key, value in pairs(self._fileName) do
            idex = idex + 1
            temp[#temp + 1] = value
        end
    end
    return idex, temp
end
---打开相册
function ServiceCommitView:readyToUploadPhoto(dict)
    local realPath = false
    if dict then
        if dict.capOK and dict.fullpath then
            realPath = dict.fullpath
        else
            return
        end
    else
        realPath = photoFullPath
    end
    -- cc.TextureCache:getInstance():removeTextureForKey(realPath)
    local function replaceRes()
        self:setCommitImage(false, realPath)
    end
    replaceRes()
end

function ServiceCommitView:openAlbum()
    local function readyToUp(dict)
        self:readyToUploadPhoto(dict)
    end
    if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) then
        local cameraManager = gy.GYCameraManager:getInstance()
        cameraManager:registerCapturedHandler(readyToUp)
        cameraManager:openAlbum(photoFullPath, 600, 500, 0)
    else
        RollTips.show(photoFullPath)
        self:readyToUploadPhoto()
    end
end

function ServiceCommitView:showfanKuiView()
    self.txt_titile:setText("")
    self.txt_content:setText("")
    self.txt_myqq:setText("")
    --LocalData.getData(LocalData.UIData, LocalData.P_QQ, "", false);
    self.txt_myphone:setText("") --LocalData.getData(LocalData.UIData, LocalData.P_PHONE, "", false);
    -- if (LoginData.customerInfo && LoginData.customerInfo.qq) {
    -- 	view.txt_qq.text = LoginData.customerInfo.qq + ''
    -- } else {
    -- 	view.txt_qq.text = '';
    -- }
    --view.txt_versions.text = AppConfig.SERVER_VER ? AppConfig.SERVER_VER : "1"; //app版本
end

function ServiceCommitView:sendProblem()
    local titile = self.txt_titile:getText()
    local content = self.txt_content:getText()
    local myqq = self.txt_myqq:getText()
    local myphone = self.txt_myphone:getText()
    printTable(15, "打印的参数", titile, content, myqq, myphone)
    local isQQ = false
    if GMethodUtil:checkQQ(myqq) or GMethodUtil:checkEmail(myqq) then
        isQQ = true
    end
    local isPhone = GMethodUtil:checkPhone(myphone)
    --StringUtil.isPhone(myphone);
    if (isQQ) then
    --LocalData.setData(LocalData.UIData, LocalData.P_QQ, myqq, true, false);
    end
    if (isPhone) then
    --LocalData.setData(LocalData.UIData, LocalData.P_PHONE, myphone, true, false);
    end
    local  titile1= StringUtil.trim(content)
    local titile2 = StringUtil.trim(titile)
    printTable(155, ">>>>>???>?", titile1)
    if (titile1 ~= "" and titile2 ~= "") then
        if (isPhone and isQQ) then
            local picStr = ""
            for key, value in pairs(self._fileName) do
                picStr = picStr .. value
            end
            ServiceCommitModel:feedBack(myqq, myphone, titile, content, picStr)
            ServiceCommitModel:feedBackMy(1)
            self._fileName = {}
        else
            if (isQQ and not isPhone) then
                RollTips.show(DescAuto[269]) -- [269]="请输入正确的电话号码"
            elseif (isPhone and not isQQ) then
                RollTips.show(DescAuto[270]) -- [270]="请输入正确的QQ号码或邮箱"
            else
                RollTips.show(DescAuto[271]) -- [271]="QQ与电话号码不可为空"
            end
        end
    else
        RollTips.show(DescAuto[272]) -- [272]="标题与内容不可为空"
    end
end

function ServiceCommitView:showJinduView()
    printTable(15, "我我我我我我")
    local list = ServiceCommitModel:getFeedInfo()
    -- if #list==0 then

    -- else

    -- end
    if not self._chooseList then
        self._chooseList = BindManager.bindGroupList(self.list_info)
    end
    self._chooseList:setState(0)
    self._chooseList:setRenderItem(self.groupListRenderItem)
    self._chooseList:setItemClick(self.onGroupItemClick)
    self._chooseList:resetList()
    -- self._chooseList:setFirstSelect(1, 1);
    self._chooseList:listData(list)
end

--渲染虚拟列表
function ServiceCommitView:groupListRenderItem(groupIndex, index, obj, data)
    -- printTable(15,"打印的objItem信息",groupIndex, index, obj, data)
    local img_red = obj:getChildAutoType("img_red")
    local txt_title = obj:getChildAutoType("txt_title")
    local txt_title1 = obj:getChildAutoType("txt_title1")
    local txt_title2 = obj:getChildAutoType("txt_title2")
    local txt_title3 = obj:getChildAutoType("txt_title3")
    local txt_runeSeleName = obj:getChildAutoType("txt_runeSeleName")
    img_red:setVisible(false)
    if index == -1 then
        txt_title:setText(data.sortId)
        local title1Len = StringUtil.getLength(data.title)
        if (title1Len > 8) then
            -- local textSub = StringUtil.utf8sub(data.title, 1, 8) -- string.sub(data.title,1,8)
            local textSub = StringUtil.getSubStringCN(data.title, 1, 8) 
            txt_title1:setText(textSub .. "...")
        else
            txt_title1:setText(data.title)
        end
        local splitMsg = string.split(data.create_time, " ")
        if splitMsg then
            local str = string.gsub(splitMsg[1], "-", ".")
            txt_title2:setText(str)
        end
        if (data.flag == 0) then
            txt_title3:setText(ColorUtil.formatColorString1(DescAuto[273], "#FF6464")) -- [273]="待处理"
        elseif (data.flag == 1) then
            txt_title3:setText(ColorUtil.formatColorString1(DescAuto[274], "#6aff60")) -- [274]="已处理"
        end
        img_red:setVisible(ServiceCommitModel:getserviceredPoint(data.name))

        txt_runeSeleName:setText("")
    else
        local txt_runeName = obj:getChildAutoType("txt_runeName")
        txt_runeName:setText(data.content)
        if (data.rep_flag == 0) then
            txt_runeSeleName:setText(DescAuto[275]) -- [275]="问题已收录，客服正在努力跟进中"
        elseif (data.rep_flag == 1 and data.rep_content == "") then
            txt_runeSeleName:setText(DescAuto[276]) -- [276]="客服已帮您解决该问题啦"
        elseif (data.rep_flag == 1 and data.rep_content ~= "") then
            local content = string.unicode2utf8(data.rep_content)
            local strs = json.decode(content)
            local str = TableUtil.join(strs, "\n")
            txt_runeSeleName:setText(str)
        end
        img_red:setVisible(false)
    end
    -- obj:setHeight(obj:getHeight()-1)
   -- obj.height = 250;
end

function ServiceCommitView:onGroupItemClick(groupIndex, index, data)
    printTable(15, "当前点击的", groupIndex, index, data)
    ServiceCommitModel:feedBackUpdate(data.id)
end

function ServiceCommitView:updataRed()
    self._chooseList:refeashRed()
end

function ServiceCommitView:openService()
    local length = 0
    local arr = ServiceCommitModel:getFeedInfo()
    for i = 1, #arr, 1 do
        local list_info = arr[i]
        if list_info and list_info.flag == 0 then
            length = length + 1
        end
    end
    if (length >= 20) then
        RollTips.show(DescAuto[277]) -- [277]="请等待问题处理后在提交问题"
    end
end

function ServiceCommitView:serviceMyFeedInfo_updata(_, data)
    self:showJinduView()
end

function ServiceCommitView:serviceMyFeedRed_updata(_, data)
    self:updataRed()
end

return ServiceCommitView
