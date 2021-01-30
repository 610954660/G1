--added by xiehande
--邮件系统子页
local NoticeView = class("NoticeView", View)
local TimeLib = require "Game.Utils.TimeLib"
local ItemCell = require "Game.UI.Global.ItemCell"
function NoticeView:ctor()
	self._title = Desc.email_gonggao
	self._packName = "Email"
    self._compName = "NoticeView"
end

--重写方法 初始化UI
function NoticeView:_initUI( ... )

end

--事件初始化
function NoticeView:_initEvent( ... )
end

--initEvent后执行
function NoticeView:_enter( ... )
	print(1,"NoticeView _enter")
end

--页面退出时执行
function NoticeView:_exit( ... )
print(1,"NoticeView _exit")
end


return NoticeView