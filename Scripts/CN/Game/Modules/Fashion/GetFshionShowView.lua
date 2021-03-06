--Date :2021-01-10
--Author : generated by FairyGUI
--Desc : 

local GetFshionShowView,Super = class("GetFshionShowView", Window)

function GetFshionShowView:ctor()
	--LuaLog("GetFshionShowView ctor")
	self._packName = "Fashion"
	self._compName = "GetFshionShowView"
	self._rootDepth = LayerDepth.PopWindow
	self.soundId = 0
	--self._rootDepth = LayerDepth.Window
end

function GetFshionShowView:_initEvent( )
	
end

function GetFshionShowView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:Fashion.GetFshionShowView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.fashionDesc = viewNode:getChildAutoType('fashionDesc')--GTextField
	self.fashionName = viewNode:getChildAutoType('fashionName')--GTextField
	self.lihuiDisplay = viewNode:getChildAutoType('lihuiDisplay')--GButton
	--{autoFieldsEnd}:Fashion.GetFshionShowView
	--Do not modify above code-------------
end

function GetFshionShowView:_initUI( )
	self:_initVM()
	self.lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
	self.lihuiDisplay:setScale(0.45,0.45)
	self.heroCode = self._args.code
	self.fashionId = self._args.fashionCode
	self.closeCallback = self._args.closeCallback
	self.lihuiDisplay:setData(self.heroCode,nil,nil,self.fashionId)
	local fashionInfo = DynamicConfigData.t_Fashion[self.heroCode][self.fashionId]
	local heroInfo = DynamicConfigData.t_hero[self.heroCode]
	self.fashionName:setText(string.format("%s·%s",heroInfo.heroName,fashionInfo.name))
	self.fashionDesc:setText(heroInfo.tip3)
	--播放立绘的音效
	if heroInfo.sound and #heroInfo.sound>0 then
		if heroInfo.sound[3] then
			self.soundId = SoundManager.playSound(heroInfo.sound[3],false)
		end
	end
end

function GetFshionShowView:_exit()
	SoundManager.stopSound(self.soundId)
	if self.closeCallback  then
		Scheduler.scheduleNextFrame(function ( ... )
			self.closeCallback()
		end)
	end
end

return GetFshionShowView