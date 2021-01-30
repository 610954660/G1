local VirtualView,Super = class("VirtualView", View)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
function VirtualView:ctor()
    self._packName = "VirtualList"
	self._compName = "Main"
end

function VirtualView:_initUI()
	local viewRoot = self.view
    local gList= FGUIUtil.getChild(viewRoot,"mailList","GList")
    local arraydata={"test1111",DescAuto[315],"test","test11111111111","test222","test99999",DescAuto[316]} -- [315]="测试" -- [316]="最后一组数据"
    local x = {dataList=arraydata, list=gList}
	local gListComponent=infiniteList.new(x)
	-- gListComponent.init({"dataList":dataList,"list":gList})
end


function VirtualView:_enter()

end

return VirtualView
