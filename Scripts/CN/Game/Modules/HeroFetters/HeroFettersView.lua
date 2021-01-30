local HeroFettersView,Super = class("HeroFettersView", Window)

function HeroFettersView:ctor()
	self._packName = "HeroFetters"
	self._compName = "HeroFettersView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true

	package.loaded["Game.Modules.HeroFetters.ItemHandle"] = nil
end

function HeroFettersView:_initEvent()
	
end

function HeroFettersView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:HeroFetters.HeroFettersView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.btn_help1 = viewNode:getChildAutoType('btn_help1')--GButton
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.list = viewNode:getChildAutoType('list')--GList
	self.nextReward = viewNode:getController('nextReward')--Controller
	--{autoFieldsEnd}:HeroFetters.HeroFettersView
	--Do not modify above code-------------
end

function HeroFettersView:_initUI()
	self:_initVM()
	RedManager.updateValue("V_HeroFettersFirst",false)
	local data = DynamicConfigData.t_HeroFetter
	self.list:setItemRenderer(function(index,obj)
		data[index + 1].maxNum = table.nums(data)
		data[index + 1].curIndex = index + 1
		local item = require"Game.Modules.HeroFetters.ItemHandle".new(obj)
		item:setData(data[index + 1])
		obj:addClickListener(function()
			ViewManager.open("HeroFettersShowInfoView",data[index + 1])
		end)
		RedManager.register("V_HeroFettersReward"..index + 1, obj:getChildAutoType("img_red"))
	end)
	self.btn_help1:addClickListener(function()
		local info = {}
	    info['title'] = Desc.HeroFettersTitle
	    info['desc'] = Desc.HeroFettersContent
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	self.list:setData(data)
	local width = 420 * table.nums(data) > 1250 and 1250 or 420 * table.nums(data)
	self.list:setSize(width,self.list:getSize().height)

	self:_refreshView()
end


function HeroFettersView:_refreshView()

end

function HeroFettersView:onExit_()

end

return HeroFettersView