--added by xiehande
--邮件大窗体
local WindowTabBar1 = require "Game.FMVC.Core.WindowTabBar1"
local EmailWindow,Super = class("EmailWindow",WindowTabBar1)

function EmailWindow:ctor( ... )
	self.ptitleImg = "ui://WindowTabBar2/bag_title" --大页标签
	self._updateTitle = false
end

-------------------常用------------------------
--继承tabBar类必须配置子页方法
function EmailWindow:initTabConfig( ... )
	return {
       {key="EmailView",title=Desc.email_title,ctitleImg="ui://Email/email_title",path="Game.Modules.Email.EmailView"},
       -- {key="NoticeView",title=Desc.email_gonggao,ctitleImg="ui://dtrawinojr2m35",path="Game.Modules.Email.NoticeView"},
    }
end

--UI初始化
function EmailWindow:_initUI( ... )
  print(1,"EmailWindow _initUI 初始化UI")
end

--事件初始化
function EmailWindow:_initEvent( ... )
	-- body
end

--initEvent后执行
function EmailWindow:_enter( ... )
	print(1,"EmailWindow _enter")
	-- body
end

--页面退出时执行
function EmailWindow:_exit( ... )
	print(1,"EmailWindow _exit")
end
-------------------常用------------------------

return EmailWindow