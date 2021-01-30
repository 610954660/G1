--Name : VipUpLevelView.lua
--Author : zn

local VipUpLevelView,Super = class("VipUpLevelView", View)

function VipUpLevelView:ctor()
	--LuaLog("VipUpLevelView ctor")
	self._packName = "Vip"
	self._compName = "VipUpLevelView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	
	
	self.curData = false
	self.nextData = false
end

function VipUpLevelView:_initEvent( )
	
end

function VipUpLevelView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:UpgradeLevel.VipUpLevelView
		vmRoot.mask = viewNode:getChildAutoType("blackbg")--graph
		vmRoot.before = viewNode:getChildAutoType("$before")--text
		vmRoot.cur = viewNode:getChildAutoType("$cur")--text
        vmRoot.mditem = viewNode:getChildAutoType("$mditem")--
        vmRoot.list_desc = viewNode:getChildAutoType("list_desc");
        vmRoot.list_award = viewNode:getChildAutoType("list_award");
	--{vmFieldsEnd}:UpgradeLevel.VipUpLevelView
	--Do not modify above code-------------
end

function VipUpLevelView:_initUI( )
	self:_initVM()
	
	self.mask:addClickListener(function()
        self.view:getTransition("out"):play(function()
            Dispatcher.dispatchEvent("Vip_UpLevel");
            self:closeViewNextFrame()
        end);
	end)
	
	self.cur:setText(self._args.newLv)
	self.before:setText(self._args.oldLv)
    
    if (type(self._args.newLv) == 'number') then
        local conf = DynamicConfigData.t_Vip[self._args.newLv];
        local priArr = conf.vipType;
        self.list_desc:setVirtual();
        self.list_desc:setItemRenderer(function (idx, obj)
            local conf = VipModel:getPriviligeType(priArr[idx + 1], self._args.newLv);
            obj:setTitle(conf.tips)
            obj:getController("isNew"):setSelectedIndex(conf.newShow or 0);
            -- obj:setText(VipModel:getPriviligeType(priArr[idx + 1], self._args.newLv));
        end)
        self.list_desc:setNumItems(#priArr);

        self.list_award:setVirtual();
        self.list_award:setItemRenderer(function (idx, obj)
            local d = conf.dayGift[idx + 1];
            local item = BindManager.bindItemCell(obj);
            item:setData(d.code, d.amount, d.type);
        end)
        self.list_award:setNumItems(#conf.dayGift)
    end
	
	self.view:getTransition("enter"):play(function ()
        
    end);
end


function VipUpLevelView:_exit()
	Scheduler.scheduleNextFrame(function()
		Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)
end

return VipUpLevelView