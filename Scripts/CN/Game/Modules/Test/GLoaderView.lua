local GLoaderView,Super = class("GLoaderView", View)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
function GLoaderView:ctor()
    self._packName = "Basics"
	self._compName = "Demo_Loader"
end
function GLoaderView:_initUI()
	local viewRoot = self.view
    local GLoader= FGUIUtil.getChild(viewRoot,"n3","GLoader")
end

function GLoaderView:_enter()

end

return GLoaderView