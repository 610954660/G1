--Name : RuneHeroChooseView.lua
--Author : generated by FairyGUI
--Date : 2020-7-27
--Desc : 
--added by xhd 符文卡牌选择页面
local RuneHeroChooseView,Super = class("RuneHeroChooseView", Window)

function RuneHeroChooseView:ctor()
	--LuaLog("RuneHeroChooseView ctor")
	self._packName = "RuneSystem"
	self._compName = "RuneHeroChooseView"
	self._rootDepth = LayerDepth.PopWindow
	self.btn_category = {}
	self.heroData = false
	self.curClickData = false
	-- self.listCellArr = {}
	self.chooseHero = {} --
	self.hadEquipNum = 0 --已装备的个数 
	self.cdingNum = 0 --在cd的格子数
	self.chooseNum = 0 --已选择的个数 
	self.emptyNum = 0 --空的格子数（不包含cd的）
	self.curPageData = false --当前页已有的英雄
	self.equipPos = {} --已装备的位置
	self.chooseHeroIds = {} --不能上相同的英雄，用个map来装一下已经选的英雄id
end

function RuneHeroChooseView:_initEvent( )
	self.list:setVirtual();
    self.list:setItemRenderer(function(idx, obj)
    	-- self.listCellArr[idx+1] = obj
        self:upHeroListItem(idx, obj);
    end)
	

    self.goBtn:addClickListener(function( ... )
    	if self.chooseNum  <= 0 then
    		RollTips.show(Desc.Rune_txt28)
    		return
    	end
		local emptyPos = {self._args.pos}
		for pos = 1,8 do
			if not self.equipPos[pos] and pos ~= self._args.pos then
				table.insert(emptyPos, pos)
			end
		end
		
		local onAddSuccess = function(res)
			
		end
		local successUuids = {}
		local posIndex = 1
		local successNum = 0
		for uuid,info in pairs(self.chooseHero) do
			local params = {}
			params.id = RuneSystemModel:getCurBjRuneID(  )
			params.pos = emptyPos[posIndex]
			posIndex = posIndex + 1
			params.heroUuid = uuid
			printTable(1,"前端 上阵",params)
			params.onSuccess = function (res )
				printTable(1,"服务器上阵成功",res)
				local data = {}
				data.cd = 0
				data.pos = res.pos
				data.uuid = res.heroUuid
				table.insert(successUuids, res.heroUuid)
				RuneSystemModel:setCurRuneEquipHero( data )
				if #successUuids >= self.chooseNum then
					ViewManager.open("RuneHeroShowView",{heroUuid = res.heroUuid})
					Dispatcher.dispatchEvent("update_rune_heroList")
					ViewManager.close("RuneHeroChooseView")
				end
				
				--ViewManager.close("RuneHeroChooseView")
				--ViewManager.open("RuneHeroShowView",{heroUuid = res.heroUuid})
				--Dispatcher.dispatchEvent("update_rune_heroList")
			end
			RPCReq.Rune_EquipmentHero(params, params.onSuccess)
		end
		Dispatcher.dispatchEvent("update_rune_heroList")
    end)

    -- 种族切页
    for idx = 0, 5 do
        self.btn_category[idx]:addClickListener(function()
            self:changeCategory(idx);
        end)
    end


    self:changeCategory(0);
end


function RuneHeroChooseView:updateNum()
	self.txt_num:setText(string.format("%s/%s", self.chooseNum, self.emptyNum))
end

-- 改变种族 -0 全 1 仙 魔 兽 人 械
function RuneHeroChooseView:changeCategory(idx)
	local data = RuneSystemModel:getCurRuneEquipHero()
	if not data then print(1,DescAuto[236])  return end -- [236]="没有数据?"
	local uuidArr = {}
	-- for k,v in pairs(data) do
	-- 	table.insert(uuidArr,v.uuid)
	-- end
    self.heroData = CardLibModel:getCardByCategory(idx, uuidArr, nil, 100)
    self.list:setData(self.heroData)
    if #self.heroData <=0 then
    	self.goBtn:setTouchable(false)
    	self.goBtn:setGrayed(true)
    else
    	self.goBtn:setTouchable(true)
    	self.goBtn:setGrayed(false)
    end
end

function RuneHeroChooseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:RuneSystem.RuneHeroChooseView
		vmRoot.categoryChoose = viewNode:getChildAutoType("$categoryChoose")--
		vmRoot.title = viewNode:getChildAutoType("$title")--text
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.goBtn = viewNode:getChildAutoType("$goBtn")--Button
		vmRoot.txt_num = viewNode:getChildAutoType("$txt_num")--Button
	--{vmFieldsEnd}:RuneSystem.RuneHeroChooseView
	--Do not modify above code-------------
end

function RuneHeroChooseView:_initUI( )
	self:_initVM()
        -- 种族选择
    for idx = 0, 5 do
        self.btn_category[idx] = self.categoryChoose:getChildAutoType("category"..idx);
        if (idx == 0) then
            self.btn_category[idx]:setSelected(true);
        end
    end
	self.curPageData = RuneSystemModel:getCurRuneEquipHero()
	for _,v in pairs(self.curPageData) do
		if v.uuid and v.uuid ~= "" then
			self.hadEquipNum = self.hadEquipNum + 1
			--self.chooseNum = self.chooseNum + 1
			self.equipPos[v.pos] = 1
			local heroInfo = CardLibModel:getHeroByUid(v.uuid)
			self.chooseHeroIds[heroInfo.heroId] = 1
		elseif v.cd ~= 0 and (v.cd - ServerTimeModel:getServerTimeMS()) > 0 then
			self.cdingNum = self.cdingNum + 1
		end
	end

	self.emptyNum =  8 - self.hadEquipNum - self.cdingNum
	self:updateNum()
end


function RuneHeroChooseView:upHeroListItem(idx, obj)
    local data = self.heroData[idx + 1];
    -- printTable(1,data)
	local ctrl = obj:getController("c1");
	
    local cardCell = BindManager.bindCardCell(obj);
    cardCell:setData(data, true);
	cardCell:setRuneName(nil)
    local name = RuneSystemModel:checkHeroHadEquip(data.uuid)
    if name then
    	cardCell:setGrayed(true)
		cardCell:setRuneName(name or "")
    end

	if self.chooseHero[data.uuid] then
		ctrl:setSelectedIndex(2);
	else
		ctrl:setSelectedIndex(1);
	end
	if not name then
		obj:removeClickListener(22);
		obj:addClickListener(function()
			
			if self.chooseHero[data.uuid] then
				local heroInfo = CardLibModel:getHeroByUid(data.uuid)
				self.chooseHeroIds[heroInfo.heroId] = nil
				self.chooseHero[data.uuid] = nil
				self.chooseNum = self.chooseNum  -1
				ctrl:setSelectedIndex(0);
			else
				if self.chooseNum >= self.emptyNum then
					RollTips.show(Desc.Rune_maxNum)
					ctrl:setSelectedIndex(0);
					return
				end
				local heroInfo = CardLibModel:getHeroByUid(data.uuid)
				if self.chooseHeroIds[heroInfo.heroId] then
					RollTips.show(Desc.Rune_canNotSame)
					return
				end
				self.chooseHeroIds[heroInfo.heroId] = 1
				self.chooseNum = self.chooseNum + 1
				ctrl:setSelectedIndex(2);
				self.chooseHero[data.uuid] = data
			end
			self:updateNum()
		end,22)
	end
end

function RuneHeroChooseView:updateListCell( ... )
	local itemNum = self.list:numChildren()
	for i=1,itemNum do
		local node = self.list:getChildAt(i-1)
		if node then
			local ctrl = node:getController("c1");
			ctrl:setSelectedIndex(0);
		end
	end
end


return RuneHeroChooseView