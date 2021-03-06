--Name : GCHeroChooseView.lua
--Author : generated by FairyGUI
--Date : 2020-7-27
--Desc : 
--added by xhd 异界招募卡牌选择页面
local GCHeroChooseView,Super = class("GCHeroChooseView", Window)

function GCHeroChooseView:ctor()
	--LuaLog("GCHeroChooseView ctor")
	self._packName = "GetCardsYjActivity"
	self._compName = "GCHeroChooseView"
	self._rootDepth = LayerDepth.PopWindow
	self.btn_category = {}
	self.heroData = false
	self.curClickData = false
	self.viewData = self._args.viewData
end

function GCHeroChooseView:_initEvent( )
	self.list:setVirtual();
    self.list:setItemRenderer(function(idx, obj)
        self:upHeroListItem(idx, obj);
    end)

    self.goBtn:addClickListener(function( ... )
    	if not self.curClickData then
    		RollTips.show(Desc.getCard_1)
    		return
		end
		--如果选择相同 跳过
		local lastHeroCode = GetCardsYjActivityModel:getLastHeroCode( ... )
		if lastHeroCode and lastHeroCode>0 and lastHeroCode == self.curClickData.HeroId then
			RollTips.show(Desc.GetCard_Text18)
			return 
		end
    	local params = {}
		params.activityId = self.viewData.id
		params.heroCode = self.curClickData.HeroId
		printTable(1,"前端 设置心愿英雄",params)
		params.onSuccess = function (res )
			printTable(1,res)
			if res.heroCode then
				local type = 1
				local lastHeroCode = GetCardsYjActivityModel:getLastHeroCode()
				if lastHeroCode and lastHeroCode>0 then
					type = 2
				end
				ViewManager.close("GCHeroChooseView")
				ViewManager.open("GCHeroSelectView",{type=type,heroCode= res.heroCode})
			else
				print(1,"服务器出错,没有数据.heroCode=",res.heroCode)
			end
		end
		RPCReq.Activity_Farplane_Set(params, params.onSuccess)
    end)

    -- 种族切页
    for idx = 0, 5 do
        self.btn_category[idx]:addClickListener(function()
            self:changeCategory(idx);
        end)
    end


    self:changeCategory(0);
end

-- 改变种族 -0 全 1 仙 魔 兽 人 械
function GCHeroChooseView:changeCategory(idx)
	self.heroData = {}
	local dataConfig = GetCardsYjActivityModel:getYJHeroConfig(self.viewData.showContent.moduleId)
	if idx==0 then
		for k,v in ipairs(dataConfig) do
				table.insert(self.heroData,v)
		end
	else
		for k,v in ipairs(dataConfig) do
			if  v.category == idx then
				table.insert(self.heroData,v)
			end
		end
	end
	self.list:setData(self.heroData)
    if #self.heroData <=0 then
    	self.goBtn:setTouchable(false)
    	self.goBtn:setGrayed(true)
    else
    	self.goBtn:setTouchable(true)
    	self.goBtn:setGrayed(false)
    end
end

function GCHeroChooseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:RuneSystem.GCHeroChooseView
		vmRoot.categoryChoose = viewNode:getChildAutoType("$categoryChoose")--
		vmRoot.title = viewNode:getChildAutoType("$title")--text
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.goBtn = viewNode:getChildAutoType("$goBtn")--Button
	--{vmFieldsEnd}:RuneSystem.GCHeroChooseView
	--Do not modify above code-------------
end

function GCHeroChooseView:_initUI( )
	self:_initVM()
        -- 种族选择
    for idx = 0, 5 do
        self.btn_category[idx] = self.categoryChoose:getChildAutoType("category"..idx);
        if (idx == 0) then
            self.btn_category[idx]:setSelected(true);
        end
    end
end

function GCHeroChooseView:upHeroListItem(idx, obj)
    local data = self.heroData[idx + 1];
	local ctrl = obj:getController("c1");
	ctrl:setSelectedIndex(0);
    if (not obj.lua_sript) then
        obj.lua_sript = BindManager.bindCardCell(obj);
    end
	obj.lua_sript:setCardNameVis(true);
	obj.lua_sript:setData(data.HeroId, true);
    if not self.curClickData then
		local lastHeroCode = GetCardsYjActivityModel:getLastHeroCode(  )
		if lastHeroCode<=0 then
			self.curClickData =  data
		else
			if lastHeroCode == data.HeroId then
				self.curClickData =  data
			end
		end
		self:updateListCell()
		ctrl:setSelectedIndex(2);
	else
		if data.HeroId == self.curClickData.HeroId then
			ctrl:setSelectedIndex(2);
		end
	end
    obj:removeClickListener(22);
    obj:addClickListener(function()
		self.curClickData = data
        self:updateListCell()
        ctrl:setSelectedIndex(2);
    end,22)
end

function GCHeroChooseView:updateListCell( ... )
	local itemNum = self.list:numChildren()
	for i=1,itemNum do
		local node = self.list:getChildAt(i-1)
		if node then
			local ctrl = node:getController("c1");
			ctrl:setSelectedIndex(0);
		end
	end
end

return GCHeroChooseView