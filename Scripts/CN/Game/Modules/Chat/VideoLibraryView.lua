

local VideoLibraryView,Super = class("VideoLibraryView", MutiWindow)

function VideoLibraryView:ctor()
	--LuaLog("TwistRuneTaskView ctor")
	self._packName = "Chat"
	self._compName = "VideoLibraryView"
	--self._rootDepth = LayerDepth.Window
	self.showDataFunc=false
	self._tabBarName = "list_recordType"
end


function VideoLibraryView:_initUI( )
	
	local help= self.view:getChildAutoType("btn_help");
	help:removeClickListener()
	help:addClickListener(
		function(...)
			local info={}
			info['title']=Desc.help_StrTitle205
			info['desc']=Desc.help_StrDesc205
			ViewManager.open("GetPublicHelpView",info)
		end
	)
	
	self:moveTitleToTop()
	self:initTabConfig()
end


function VideoLibraryView:initTabConfig( )
	
	-- 设置左侧小页签（二级页签）
	
	local titles={
           [1]=DescAuto[4], -- [4]="竞技场"
		   [2]=DescAuto[27]		 -- [27]="天境赛"
	}
	local childs = self._tabBar:getChildren()
	for i = 1, #childs-1 do 
		local tabObj = childs[i]
		tabObj:getChildAutoType("arrow1"):setVisible(false)
		tabObj:getChildAutoType("arrow"):setVisible(false)
	end
	
	
	local obj 			= childs[3]
	local list_midTag 	= obj:getChildAutoType("list_midTag")
	local clickArea 	= obj:getChildAutoType("clickArea")

	local objTitle 		= obj:getChildAutoType("title")
	local arrowCtrl = obj:getController("arrowCtrl")
	arrowCtrl:setSelectedIndex(0)
	list_midTag:setItemRenderer(function(idx2,obj2)
			local title 	= obj2:getChildAutoType("title")
			title:setText(titles[idx2+1])
			obj2:addClickListener(function()
					Dispatcher.dispatchEvent(EventType.update_VideoTotalRecord,{secondPage=idx2+1});
			end,222)
	end)
	list_midTag:setNumItems(2)
	list_midTag:resizeToFit(2)
	obj:setSize(list_midTag:getWidth(), list_midTag:getHeight()+70)
	list_midTag:setVisible(true)
	list_midTag:setSelectedIndex(0)
end



return VideoLibraryView
