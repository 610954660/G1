--道具tips
--added by wyang
local ItemTipsItemFrom = class("ItemTipsItemFrom",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsItemFrom:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsItemFrom"
   self._isFullScreen = false

	self.sourceData = args.data
end

function ItemTipsItemFrom:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsItemFrom:_initUI( ... )
	local list_attr = self.view:getChildAutoType("list_attr")
	
	list_attr:setItemRenderer(function(index,obj)
			local moduleIcon = obj:getChildAutoType("moduleIcon")
			local txt_source = obj:getChildAutoType("txt_source")
			local txt_open = obj:getChildAutoType("txt_open")
			local btn_open = obj:getChildAutoType("btn_open")
			local c1 = obj:getController("c1")
			
			local sourceId = self.sourceData[index + 1]
			local sourceInfo = DynamicConfigData.t_itemSource[tonumber(sourceId)]
			
			local openTips = ModuleUtil.getModuleOpenTips(sourceId)
			if not openTips then
				c1:setSelectedIndex(1)
			else
				c1:setSelectedIndex(0)
				txt_open:setText(openTips)
			end
			
			moduleIcon:setURL(PathConfiger.getItemIcon(sourceInfo.icon))
			txt_source:setText(sourceInfo.decription)
			btn_open:removeClickListener()
			btn_open:addClickListener(function ( ... )
				ModelManager.EquipTargetModel.jump = true
				ModuleUtil.openModule(sourceInfo.module,true)
				--[[if (self.args and self.args.callFunc) then
					Scheduler.scheduleNextFrame(function ()
						self.args.callFunc();
					end)
				end--]]
				--self:closeView()
				ViewManager.close("AwardShowView")
				ViewManager.close("ItemTips")
			end)
			
		end)
	list_attr:setNumItems(#self.sourceData)
end

-- [子类重写] 准备事件
function ItemTipsItemFrom:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsItemFrom:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsItemFrom:_exit()
end


return ItemTipsItemFrom