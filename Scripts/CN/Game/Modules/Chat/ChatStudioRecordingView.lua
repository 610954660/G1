--聊天话筒
---------------------------------------------------------------------
local ChatStudioRecordingView, Super = class("ChatStudioRecordingView", Window)

function ChatStudioRecordingView:ctor()
    self._packName = "Chat"
    self._compName = "ChatStudioRecordingView"
    self._rootDepth = LayerDepth.FaceWindow
end

function ChatStudioRecordingView:_initUI()
    local type= self._args.recordType
   self.view:getController("c1"):setSelectedIndex(type)
   if type==0 then--话筒
    self:showEff("t0")
   end
end

function ChatStudioRecordingView:showEff(str)
    local transition =self.view:getTransition(str);
    transition:stop();
    transition:playReverse();
    transition:play(function ()
		self:showEff(str)
    end)
end

function ChatStudioRecordingView:_enter()
end

return ChatStudioRecordingView
