--Name : ActivityFrame3View.lua
--Author : generated by FairyGUI
--Date : 2020-5-9
--Desc : added by xhd UI框架模态3

local ActivityFrameViewBase = require "Game.Modules.ActivityFrame.ActivityFrameViewBase"
local ActivityFrame3View,Super = class("ActivityFrame3View", ActivityFrameViewBase)
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
function ActivityFrame3View:ctor()
	self._packName = "ActivityFrame"
	self._compName = "ActivityFrame3View"
end

function ActivityFrame3View:_initEvent( )
end

return ActivityFrame3View