--获取途径
--added by xhd
local GetCardsHelpView,Super = class("GetCardsHelpView",Window)
function GetCardsHelpView:ctor( arg )
    self._packName = "GetCards"
	self._compName = "GetCardsHelpView"
	self._rootDepth = LayerDepth.PopWindow
	self.moduleId = self._args.moduleId

end

function GetCardsHelpView:_initUI( ... )
   self.pageList = self.view:getChildAutoType("pageList")
   local config = DynamicConfigData.t_SummonChance[self.moduleId]
   self.pageList:setItemRenderer(function(index,obj)
	   local title = obj:getChildAutoType("title"):getChildAutoType("title")
	   title:setText(config[index+1][1].title)
	   local cellList = obj:getChildAutoType("cellList")
	   printTable(1,config[index+1])
	   cellList:setItemRenderer(function(index2,obj2)
		  local config2 = config[index+1][index2+1]
		  local txt = obj2:getChildAutoType("txt")
		  local rate = obj2:getChildAutoType("rate")
		  txt:setText(config2.desc)
		  rate:setText(config2.chance)
	   end)
	   cellList:setData(config[index+1])
	   
   end)
   self.pageList:setData(config)
end

function GetCardsHelpView:_initEvent( ... )
   
end

--initUI执行之前
function GetCardsHelpView:_enter( ... )

end

--页面退出时执行
function GetCardsHelpView:_exit( ... )
	print(1,"GetCardsHelpView _exit")
end

return GetCardsHelpView