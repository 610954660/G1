---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ChatPlayTipsView, Super = class("ChatPlayTipsView", Window)

function ChatPlayTipsView:ctor()
    self._packName = "Chat"
    self._compName = "ChatPlayTipsView"
    self._rootDepth = LayerDepth.FaceWindow
    self.faceList = false
end

function ChatPlayTipsView:_initUI()
    local viewRoot = self.view
    -- local playInfo = ModelManager.ChatModel.fromPlayTipsInfo
    -- local playItem = viewRoot:getChild("com_PlayerInfo")
    -- local txtName = playItem:getChildAutoType("txt_name")
    -- txtName:setText(playInfo.name)
    -- local txtLine = playItem:getChildAutoType("txt_line")
    -- local isLine = "离线"
    -- if playInfo.online == true then
    --     isLine = "在线"
    -- end
    -- txtLine:setText(isLine)
    -- local playerHead = playItem:getChildAutoType("playerHead")
    -- playerHead:setIcon(PlayerModel:getUserHeadURL(playInfo.head))
    -- local headLevel = playerHead:getChildAutoType("txt_level")
    -- headLevel:setText(playInfo.level)
    self:bindEvent()
end

function ChatPlayTipsView:bindEvent()
    local playInfo = ModelManager.ChatModel.fromPlayTipsInfo
    local viewRoot = self.view
    local btnLook = viewRoot:getChild("btn_look")
    btnLook:addClickListener(
        function()
        end
    )
    local btnAttention = viewRoot:getChild("btn_attention")
    btnAttention:addClickListener(
        function()
        end
    )
    local btnPrivate = viewRoot:getChild("btn_private")
    btnPrivate:addClickListener(
        function()
            if playInfo.online == false then
                RollTips.show(DescAuto[63]) -- [63]='对方已下线'
            else
                Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, playInfo)
            end
            ViewManager.close("ChatPlayTipsView")
        end
    )
    local btnShield = viewRoot:getChild("btn_shield")
    btnShield:addClickListener(
        function()
        end
    )
end

function ChatPlayTipsView:_enter()
end

return ChatPlayTipsView
