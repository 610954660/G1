--added by xiehande
--功能 异界招募探员选定
local GCHeroSelectView,Super = class("GCHeroSelectView", Window)
function GCHeroSelectView:ctor(args)
	LuaLogE("GCHeroSelectView ctor")
	self._packName = "GetCardsYjActivity"
	self._compName = "GCHeroSelectView"
	self._isFullScreen = true
	self._rootDepth = LayerDepth.AlertWindow
	self.timer = false
	self.spineParent = false
end

function GCHeroSelectView:showEffect( ... )
	if tolua.isnull(self.view) then return end
	self.view:getTransition("t0"):play(function( ... )
						  end);
	self.showCtrl:setSelectedIndex(1)
	self:updatePanel()
    local spine1 =  SpineUtil.createSpineObj(self.spineParent, vertex2(self.spineParent:getWidth()/2,self.spineParent:getHeight()/2), "fx_gongxihuode", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan",false)
    spine1:setCompleteListener(function( name )
		spine1:setAnimation(0,"fx_gongxihuode_loop",true)
	end)
	
end

--更新页面
function GCHeroSelectView:updatePanel()
	self.typeCtrl:setSelectedIndex(self._args.type-1)
	if self._args.type == 1 then
		if (not self.playerCell.lua_sript) then
			self.playerCell.lua_sript = BindManager.bindCardCell(self.playerCell);
		end
		self.playerCell.lua_sript:setData(self._args.heroCode, true);
		self.view:getChildAutoType("n72"):setVar("name",DynamicConfigData.t_hero[self._args.heroCode].heroName)
		self.view:getChildAutoType("n72"):flushVars()
	elseif self._args.type == 2 then
		local lastHeroCode = GetCardsYjActivityModel:getLastHeroCode()
		if (not self.playerCell_left.lua_sript) then
			self.playerCell_left.lua_sript = BindManager.bindCardCell(self.playerCell_left);
		end
		self.playerCell_left.lua_sript:setData(lastHeroCode, true);

		if (not self.playerCell_right.lua_sript) then
			self.playerCell_right.lua_sript = BindManager.bindCardCell(self.playerCell_right);
		end
		self.playerCell_right.lua_sript:setData(self._args.heroCode, true);
		self.name_left:setText(DynamicConfigData.t_hero[lastHeroCode].heroName)
		self.name_right:setText(DynamicConfigData.t_hero[self._args.heroCode].heroName)
	end
	GetCardsYjActivityModel:setLastHeroCode( self._args.heroCode )
	Dispatcher.dispatchEvent("update_yj_heroPage")
end

function GCHeroSelectView:showSpine(  )
    if self.timer then
    	Scheduler.unschedule(self.timer)
    end
    local countTime  = 0 
	self.timer=Scheduler.schedule(function(time)
		countTime=countTime + time
		if countTime>=0.1 then
           self:showEffect()
            if self.timer then
		    	Scheduler.unschedule(self.timer)
		    	self.timer = nil
		    end
		end
    end,0)
end

function GCHeroSelectView:_initUI()
	self.spineParent = self.view:getChildAutoType("spineParent")
	self.showCtrl = self.view:getController("showCtrl")  
	self.showCtrl:setSelectedIndex(0)
	self.typeCtrl = self.view:getController("typeCtrl")
    self.playerCell = self.view:getChildAutoType("playerCell")
    self.playerCell_left = self.view:getChildAutoType("playerCell_left")
    self.playerCell_right = self.view:getChildAutoType("playerCell_right")
    self.name_left = self.view:getChildAutoType("name_left")
	self.name_right = self.view:getChildAutoType("name_right")
	self:showSpine()
end

function GCHeroSelectView:_initEvent( ... )
end

function GCHeroSelectView:_exit( ... )

	--如果有关闭回调的，调用回调
	if self._args.closeCallBack then
		self._args.closeCallBack(self._args.closeCaller)
	end

	if self.timer then
    	Scheduler.unschedule(self.timer)
    	self.timer = nil
	end
	
end

return GCHeroSelectView