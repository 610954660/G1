---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ChatFaceView, Super = class("ChatFaceView", Window)

function ChatFaceView:ctor()
    self._packName = "Chat"
    self._compName = "ChatFaceView"
    self._rootDepth = LayerDepth.FaceWindow
    self.faceList = false
    self.facetype = false
    self.faceList1 = false
end

function ChatFaceView:_initUI()
    local viewRoot = self.view
    self.c1 = viewRoot:getController("c1")
    self.faceList = viewRoot:getChild("list_face")
    self.faceList1 = viewRoot:getChild("list_face1")
    self.facetype = viewRoot:getChild("list_type")
    local config = DynamicConfigData.t_Emoji
    self.facetype:setItemRenderer(
        function(index, obj)
            obj:setIcon(string.format("UI/Chat/chatFaceBtn_%s.png", index))
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local faceType = (index + 1)
                    if faceType == 1 then
                        self.c1:setSelectedIndex(0)
                        self:showFaceList(faceType, self.faceList)
                    else
                        self.c1:setSelectedIndex(1)
                        self:showFaceList(faceType, self.faceList1)
                    end
                end,
                100
            )
            if index == 0 then
                obj:setSelected(true)
                self:showFaceList(index + 1,self.faceList)
                self.c1:setSelectedIndex(index)
            else
                obj:setSelected(false)
            end
        end
    )
    self.facetype:setNumItems(#config)
end

function ChatFaceView:showFaceList(type, listObj)
    local configFace = DynamicConfigData.t_Emoji[type]
    listObj:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local dispatchInfo = configFace[(index + 1)]
                    local faceId = dispatchInfo.emojiRes
                    Dispatcher.dispatchEvent(EventType.update_chatFace, faceId)
                    ViewManager.close("ChatFaceView")
                end,
                100
            )
            local dispatchInfo = configFace[(index + 1)]
            local faceId = dispatchInfo.emojiRes
            local imgUrl = "ui://Chat/" .. faceId
            local imgItem = obj:getChild("icon")
            imgItem:setURL(imgUrl)
        end
    )
    listObj:setNumItems(#configFace)
end

function ChatFaceView:_enter()
end

return ChatFaceView
