--Name : RuneSystemView.lua
--Author : generated by FairyGUI
--Date : 2020-5-21
--Desc : 

local RuneSystemView,Super = class("RuneSystemView", MutiWindow)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ItemCell = require "Game.UI.Global.ItemCell"
local  RuneConfiger = require "Game.Modules.RuneSystem.RuneConfiger"
function RuneSystemView:ctor()
	--LuaLog("RuneSystemView ctor")
	self._packName = "RuneSystem"
	self._compName = "RuneSystemView"
	self.runeBagData = {}
	self.smallPageIndex = 0 --显示的是哪个小窗口Id
	self.curRuneBagIndex = 0
	self.curRuneData = false --当前格子数据
	self._tabBarName = "_tabBar"
	self.redArr ={"V_PACKAGE","","","V_RUNERESET"}
	
	self.showMoneyResetType = {
		{type = DynamicConfigData.t_LockConsume[1].cost[1].type, code = DynamicConfigData.t_LockConsume[1].cost[1].code, iconType = GameDef.ItemType.Normal},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}
	
	self.showMoneyPackageType = {
		{type = DynamicConfigData.t_RunePage[4][1].cost[1].type, code = DynamicConfigData.t_RunePage[4][1].cost[1].code, iconType = GameDef.ItemType.Normal},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyDefaultType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
		}
end

function RuneSystemView:_initEvent( )
	self.btn_gl:addClickListener(function()
		local info={}
		info['title']=Desc["strategy_StrTitle1"]
		info['desc']=Desc["strategy_StrDesc1"]
		ViewManager.open("GetPublicHelpView",info) 
	end)
end

function RuneSystemView:_viewChangeCallBack( index )
	-- self._frame:getChildAutoType("fullScreen"):getChildAutoType("icon"):setURL(ImgURL[index+1])
end

function RuneSystemView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:RuneSystem.RuneSystemView
		vmRoot.btn_gl = viewNode:getChildAutoType("$btn_gl")--Button
		local RuneBagView = viewNode:getChildAutoType("$RuneBagView")--
		vmRoot.RuneBagView = RuneBagView
			RuneBagView.list = viewNode:getChildAutoType("$RuneBagView/$list")--list
		local RunPackageView = viewNode:getChildAutoType("$RunPackageView")--
		vmRoot.RunPackageView = RunPackageView
			RunPackageView.heroList = viewNode:getChildAutoType("$RunPackageView/$heroList")--list
			RunPackageView.rune10 = viewNode:getChildAutoType("$RunPackageView/$rune10")--Button
			RunPackageView.rune29 = viewNode:getChildAutoType("$RunPackageView/$rune29")--Button
			RunPackageView.rune15 = viewNode:getChildAutoType("$RunPackageView/$rune15")--Button
			RunPackageView.rune36 = viewNode:getChildAutoType("$RunPackageView/$rune36")--Button
			RunPackageView.rune11 = viewNode:getChildAutoType("$RunPackageView/$rune11")--Button
			RunPackageView.rune17 = viewNode:getChildAutoType("$RunPackageView/$rune17")--Button
			RunPackageView.btn_page = viewNode:getChildAutoType("$RunPackageView/$btn_page")--Button
			RunPackageView.rune18 = viewNode:getChildAutoType("$RunPackageView/$rune18")--Button
			RunPackageView.rune33 = viewNode:getChildAutoType("$RunPackageView/$rune33")--Button
			RunPackageView.rune24 = viewNode:getChildAutoType("$RunPackageView/$rune24")--Button
			RunPackageView.changeNameBtn = viewNode:getChildAutoType("$RunPackageView/$changeNameBtn")--Button
			RunPackageView.rune21 = viewNode:getChildAutoType("$RunPackageView/$rune21")--Button
			RunPackageView.rune14 = viewNode:getChildAutoType("$RunPackageView/$rune14")--Button
			RunPackageView.rune19 = viewNode:getChildAutoType("$RunPackageView/$rune19")--Button
			RunPackageView.rune30 = viewNode:getChildAutoType("$RunPackageView/$rune30")--Button
			RunPackageView.btn_allpanel = viewNode:getChildAutoType("$RunPackageView/$btn_allpanel")--Button
			RunPackageView.rune22 = viewNode:getChildAutoType("$RunPackageView/$rune22")--Button
			RunPackageView.rune27 = viewNode:getChildAutoType("$RunPackageView/$rune27")--Button
			RunPackageView.rune16 = viewNode:getChildAutoType("$RunPackageView/$rune16")--Button
			RunPackageView.rune31 = viewNode:getChildAutoType("$RunPackageView/$rune31")--Button
			RunPackageView.rune26 = viewNode:getChildAutoType("$RunPackageView/$rune26")--Button
			RunPackageView.rune12 = viewNode:getChildAutoType("$RunPackageView/$rune12")--Button
			RunPackageView.rune28 = viewNode:getChildAutoType("$RunPackageView/$rune28")--Button
			RunPackageView.rune38 = viewNode:getChildAutoType("$RunPackageView/$rune38")--Button
			RunPackageView.rune25 = viewNode:getChildAutoType("$RunPackageView/$rune25")--Button
			RunPackageView.rune37 = viewNode:getChildAutoType("$RunPackageView/$rune37")--Button
			RunPackageView.rune35 = viewNode:getChildAutoType("$RunPackageView/$rune35")--Button
			RunPackageView.rune13 = viewNode:getChildAutoType("$RunPackageView/$rune13")--Button
			RunPackageView.rune20 = viewNode:getChildAutoType("$RunPackageView/$rune20")--Button
			RunPackageView.rune34 = viewNode:getChildAutoType("$RunPackageView/$rune34")--Button
			RunPackageView.rune39 = viewNode:getChildAutoType("$RunPackageView/$rune39")--Button
			RunPackageView.rune23 = viewNode:getChildAutoType("$RunPackageView/$rune23")--Button
			RunPackageView.rune32 = viewNode:getChildAutoType("$RunPackageView/$rune32")--Button
		local RuneCompoundView = viewNode:getChildAutoType("$RuneCompoundView")--
		vmRoot.RuneCompoundView = RuneCompoundView
			RuneCompoundView.runeComp1 = viewNode:getChildAutoType("$RuneCompoundView/$runeComp1")--Button
			RuneCompoundView.costBar = viewNode:getChildAutoType("$RuneCompoundView/$costBar")--
			RuneCompoundView.runeComp3 = viewNode:getChildAutoType("$RuneCompoundView/$runeComp3")--Button
			RuneCompoundView.btn_hecheng = viewNode:getChildAutoType("$RuneCompoundView/$btn_hecheng")--Button
			RuneCompoundView.btn_add = viewNode:getChildAutoType("$RuneCompoundView/$btn_add")--Button
			RuneCompoundView.runeComp5 = viewNode:getChildAutoType("$RuneCompoundView/$runeComp5")--Button
			RuneCompoundView.compItem = viewNode:getChildAutoType("$RuneCompoundView/$compItem")--Button
			RuneCompoundView.runeComp4 = viewNode:getChildAutoType("$RuneCompoundView/$runeComp4")--Button
			RuneCompoundView.runeComp2 = viewNode:getChildAutoType("$RuneCompoundView/$runeComp2")--Button
		local smallPage3 = viewNode:getChildAutoType("$smallPage3")--
		vmRoot.smallPage3 = smallPage3
			smallPage3.proList = viewNode:getChildAutoType("$smallPage3/$proList")--list
			smallPage3.runeName = viewNode:getChildAutoType("$smallPage3/$runeName")--text
			smallPage3.runeComp = viewNode:getChildAutoType("$smallPage3/$runeComp")--Button
			smallPage3.btn_gh = viewNode:getChildAutoType("$smallPage3/$btn_gh")--Button
			smallPage3.btn_hc = viewNode:getChildAutoType("$smallPage3/$btn_hc")--Button
			smallPage3.close_change = viewNode:getChildAutoType("$smallPage3/$close_change")--Button
		local smallPage2 = viewNode:getChildAutoType("$smallPage2")--
		vmRoot.smallPage2 = smallPage2
			smallPage2.skillTxt = viewNode:getChildAutoType("$smallPage2/$skillTxt")--richtext
			smallPage2.btn_change = viewNode:getChildAutoType("$smallPage2/$btn_change")--Button
			smallPage2.btn_clear = viewNode:getChildAutoType("$smallPage2/$btn_clear")--Button
			smallPage2.skillList = viewNode:getChildAutoType("$smallPage2/$skillList")--list
			smallPage2.skillName = viewNode:getChildAutoType("$smallPage2/$skillName")--richtext
			smallPage2.allLevel = viewNode:getChildAutoType("$smallPage2/$allLevel")--text
			smallPage2.prosList = viewNode:getChildAutoType("$smallPage2/$prosList")--list
		vmRoot._tabBar = viewNode:getChildAutoType("$_tabBar")--list
		local smallPage1 = viewNode:getChildAutoType("$smallPage1")--
		vmRoot.smallPage1 = smallPage1
			smallPage1.btnList = viewNode:getChildAutoType("$smallPage1/$btnList")--list
			smallPage1.list = viewNode:getChildAutoType("$smallPage1/$list")--list
			smallPage1.closeButton = viewNode:getChildAutoType("$smallPage1/$closeButton")--list
		local RuneResetView = viewNode:getChildAutoType("$RuneResetView")--
		vmRoot.RuneResetView = RuneResetView
			RuneResetView.proList = viewNode:getChildAutoType("$RuneResetView/$proList")--list
			RuneResetView.runeCell = viewNode:getChildAutoType("$RuneResetView/$runeCell")--Button
			RuneResetView.costItem = viewNode:getChildAutoType("$RuneResetView/$costItem")--
			RuneResetView.btn_cz = viewNode:getChildAutoType("$RuneResetView/$btn_cz")--Button
	--{vmFieldsEnd}:RuneSystem.RuneSystemView
	--Do not modify above code-------------
end

function RuneSystemView:_initUI( )
	self:_initVM()
	self:setBg("bg_rune.jpg")
	self:requestRunePageData()
	self:initSmallPanel1()
	self:initSmallPanel2()
	self:initSmallPanel3()
	self._tabBar:addEventListener(FUIEventType.ClickItem,function()
		local index = self._tabBar:getSelectedIndex() + 1
		if index ~=2 then
			ViewManager.close("ItemTipsBagView")
		end
	end)
end


function RuneSystemView:requestRunePageData( ... )
	--请求符文页数据
	local params = {}
	params.onSuccess = function (res )
	    
	end
	RPCReq.Rune_GetRunePage(params, params.onSuccess)
end

function RuneSystemView:rune_changeSmallPage( _,params )
	printTable(1,"RuneSystemView rune_changeSmallPage",params)
	-- do return end
	self.view:getController("smallView"):setSelectedIndex(params.status)
	self.smallPageIndex = params.status
	if params.page then
		self.curRuneBagIndex = params.page
		if params.show then
			self.smallPage1:getController("pageCtrl"):setSelectedIndex(1)
			if params.pageIndex and params.pageIndex ==3 then
				self.smallPage1.btnList:setNumItems(4)
			else
				self.smallPage1.btnList:setNumItems(5)
			end
		else
			if params.isChange then
				self.smallPage1:getController("pageCtrl"):setSelectedIndex(2)
			else
				self.smallPage1:getController("pageCtrl"):setSelectedIndex(0)
			end
		end
		self:updateSmallPage1(params.page)
		self.smallPage1.btnList:setSelectedIndex(params.page)
	end
	
end

--针对符文重置 只刷新选中的属性显示
function RuneSystemView:update_resetPage_OneListCell( ... )
	Scheduler.scheduleNextFrame(function()
		local preitemData = RuneSystemModel:getCurRuneResetData( )
	    for i=1,#self.runeBagData do
			if preitemData and self.runeBagData[i]:getUuid() == preitemData:getUuid() then
				self.smallPage1.list:scrollToView(i-1,true,false)
				break
			end
		end
		
	end)
end

function RuneSystemView:initSmallPanel1( ... )
	self.smallPage1.btnList:setItemRenderer(function (index,obj)
		obj:removeClickListener(100)
		obj:addClickListener(function( ... )
			self.curRuneBagIndex = index
			self:updateSmallPage1(index)
		end,100)
	end)
	self.smallPage1.btnList:setNumItems(5)
	self.smallPage1.closeButton:removeClickListener(100)
	self.smallPage1.closeButton:addClickListener(function()
		print(1,"按钮被点击")
		Dispatcher.dispatchEvent(EventType.init_smallPageShow)
		Dispatcher.dispatchEvent("rune_quit_change")
	end,100)

	self.smallPage1.list:setItemRenderer(function (index,obj)
		local itemData = self.runeBagData[index+1]
		local runeAttrs = itemData:getItemSPecialData().rune.attrs
		local itemCellObj =obj:getChildAutoType("itemCell")
		local txt_desc =obj:getChildAutoType("txt_desc")
		local typeCtrl =obj:getController("typeCtrl")
		local itemcell = BindManager.bindItemCell(itemCellObj)
		itemcell:setAmountVisible(false)
		itemcell:setItemData(itemData) 
		
		local itemCode = itemData:getItemCode()
		if DynamicConfigData.t_MultipleAttr[itemCode] then
			typeCtrl:setSelectedIndex(1)
			txt_desc:setText(DynamicConfigData.t_MultipleAttr[itemCode].description1)
		else
			typeCtrl:setSelectedIndex(0)
		end

		obj:getChildAutoType("name"):setText(itemData:getName())
		obj:getChildAutoType("name"):setColor(itemData:getColor())

		local hadChooseCtrl = obj:getController("hadChooseCtrl")
		local proList = obj:getChildAutoType("proList")
		proList:setItemRenderer(function ( index2,obj2 )
			obj2:getChildAutoType("title"):setText(Desc["common_fightAttr"..runeAttrs[index2+1].id])
			obj2:getChildAutoType("titleVal"):setText("+"..GMethodUtil:getFightAttrName(runeAttrs[index2+1].id,runeAttrs[index2+1].value))
			if runeAttrs[index2+1].id < 100 or RuneConfiger.isHightAttr(runeAttrs[index2+1].id) then
				obj2:getChildAutoType("title"):setColor(ColorUtil.textColor.yellow)
				obj2:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.yellow)
			else
				obj2:getChildAutoType("title"):setColor(ColorUtil.textColor.black)
				obj2:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.black)
			end
		end)
		proList:setData(runeAttrs)
		
		hadChooseCtrl:setSelectedIndex(0)
		if self._preIndex == 2 then --在系统合成页面
			local runeCompDataArr = RuneSystemModel:getRuneCompDataArr()
			if runeCompDataArr then
				for k,v in pairs(runeCompDataArr) do
					if itemData:getUuid() == v:getUuid() then
						hadChooseCtrl:setSelectedIndex(1)
						break
					end
				end
			end
		end

		if self._preIndex == 3 then --在符文重置页面
            local preitemData = RuneSystemModel:getCurRuneResetData( )
            if preitemData and itemData:getUuid() == preitemData:getUuid() then
			   hadChooseCtrl:setSelectedIndex(1)
            else
            	hadChooseCtrl:setSelectedIndex(0)
            end
		end

		obj:removeClickListener(100)
		obj:addClickListener(function ( ... )
			
			
			if self._preIndex == 2 then --在系统合成页面
			   if hadChooseCtrl:getSelectedIndex() == 0 then
			   	  local count = RuneSystemModel:getRuneCompCount()
                  if count >=5 then
                  	RollTips.show(Desc.Rune_txt22)
                  	return
                  end
			   	  local flag,level = RuneSystemModel:checkRuneCompCurLevel( itemData:getItemCode() )
			   	  if not flag then
			   	  	RollTips.show(Desc.Rune_txt23)
			   	  	return
				  end
				  local flag = RuneSystemModel:checkRuneSpeColor( itemData:getItemCode() )
				  if not flag then
					RollTips.show(Desc.Rune_txt50)
					return
			      end
			   	  if flag and level and level>=3 then
			   	  	RollTips.show(Desc.Rune_txt24)
			   	  	return
			   	  end

			   	  local flag2 = RuneSystemModel:checkRuneCompCurColor( itemData:getItemCode() )
			   	  if not flag2 then
			   	  	RollTips.show(Desc.Rune_txt25)
			   	  	return
			   	  end
			   	  hadChooseCtrl:setSelectedIndex(1)
			   	  Dispatcher.dispatchEvent(EventType.set_runeHechengEvent,{itemData= itemData,type=1})
			   else
					hadChooseCtrl:setSelectedIndex(0)
					Dispatcher.dispatchEvent(EventType.set_runeHechengEvent,{itemData= itemData,type=0})
			   end
			elseif self._preIndex ==3 then --在符文重置页面
				local preitemData = RuneSystemModel:getCurRuneResetData( )
                if preitemData and itemData:getUuid() == preitemData:getUuid() then
                	return
                end
				hadChooseCtrl:setSelectedIndex(1)
				Dispatcher.dispatchEvent(EventType.set_runeResetEvent,{itemData= itemData})
				Dispatcher.dispatchEvent("update_smallPage")
			else --符文装备页面
                --请求穿上
                -- do return end
                self.curRuneData = RuneSystemModel:getCurSelectRuneData(  )
				if self.curRuneData and self.curRuneData.runeColor and self.curRuneData.runeColor.itemCode ~= 0 then   --如果不是空的，说明是替换的
					local runeData = {}
					runeData.runeColor = {}
					runeData.uuid = itemData:getUuid()
					runeData.runeColor.attr = itemData:getItemSPecialData().rune.attrs
					runeData.runeColor.itemCode = itemData:getItemCode()
					Dispatcher.dispatchEvent(EventType.set_runeChangeItem,{runeData= runeData})
					return 
				end
			
                if self.curRuneData and self.curRuneData.runeColor and self.curRuneData.runeColor.itemCode==0 then
                	local params = {}
					params.id = self.curRuneData.id
					params.type = self.curRuneData.type
					params.index = self.curRuneData.index
					params.itemUuid = itemData:getUuid()
					printTable(1,params)
					params.onSuccess = function (res )
					    printTable(1,"请求装上",res)
						if res.addToPageRune then
							local data = {}
							data.id = res.addToPageRune.id 
							data.runeColor = res.addToPageRune.runeColor
							data.type = res.addToPageRune.type
							data.index = res.addToPageRune.index
							self.curRuneData = data
							RuneSystemModel:setCurSelectRuneData( data )
							RuneSystemModel:updateRunePageRuneColor( res.addToPageRune.id,res.addToPageRune.type,res.addToPageRune.index,res.addToPageRune.runeColor)
						end
					end
					RPCReq.Rune_AddPageRunePos(params, params.onSuccess)
					do return end
                elseif self.curRuneData and self.curRuneData.runeColor and self.curRuneData.runeColor.itemCode~=0 then
                	--已经存在 自动寻找下一个能装备的格子
                    local color,index = RuneSystemModel:checkNextCanEquip()
                    if color and index then
                    	local params = {}
						params.id = RuneSystemModel:getCurBjRuneID(  )
						params.type = color
						params.index = index
						params.itemUuid = itemData:getUuid()
						params.onSuccess = function (res )
						    --printTable(1,res)
						    local data = {}
						    data.id = res.addToPageRune.id 
						    data.runeColor = res.addToPageRune.runeColor
						    data.type = res.addToPageRune.type
						    data.index = res.addToPageRune.index
							self.curRuneData = data
						    RuneSystemModel:setCurSelectRuneData( data )
						    RuneSystemModel:updateRunePageRuneColor( res.addToPageRune.id,res.addToPageRune.type,res.addToPageRune.index,res.addToPageRune.runeColor)
						end
						RPCReq.Rune_AddPageRunePos(params, params.onSuccess)
                    end
                end
				
			end
						
		end,100)
	end)
    self.smallPage1.list:setVirtual()
end

function RuneSystemView:updateSmallPage1( index)
	print(1,"RuneSystemView updateSmallPage1 ",index)
	if not index then
		index = self.curRuneBagIndex --没有更换颜色的请求下，刷新包含当前的颜色的背包数据
	end
	self.runeBagData = RuneSystemModel:getRunePackByType( index,self._preIndex)
	self.smallPage1.list:setData(self.runeBagData)
	self:update_resetPage_OneListCell()
	RuneSystemModel:checkCompoundData()
end


--更新背包显示
function RuneSystemView:pack_rune_change( ... )
	print(1,"RuneSystemView:pack_rune_change")
	
	self:update_RuneServerData()
end

function RuneSystemView:rune_changePage(_,pageName )
	print(1,"rune_changePage")
	if not pageName then
		self:_setPage(0)
		return
	end
	self:_setPage(pageName)
	
end

function RuneSystemView:onShowPage(page)
	if page == "RuneResetView" then 
		self:setMoneyType(self.showMoneyResetType);
	elseif page == "RunPackageView" then 
		self:setMoneyType(self.showMoneyPackageType);
	else
		Dispatcher.dispatchEvent(EventType.set_runeResetEvent,{})
		RuneSystemModel:setCurRuneResetData(false )	
		self:setMoneyType(self.showMoneyDefaultType);
	end
	
	if page ~= "RunPackageView" then
		Dispatcher.dispatchEvent(EventType.rune_quit_change)
	end
end

function RuneSystemView:initSmallPanel2( ... )
	self.smallPage2.btn_clear:addClickListener(function ( ... )

		local info = {}
		info.text = Desc.Rune_txt26
		info.yesText = Desc.common_sure
		info.noText =  Desc.common_cancel
		info.type = "yes_no"
		info.onYes = function()
           --请求全部脱下
			local params = {}
			params.id = RuneSystemModel:getCurBjRuneID()
			params.onSuccess = function (res )
			    print(1,"请求脱下成功")
			    --printTable(1,res)
			    RuneSystemModel:updateDataToRunePages(res.retData)
			end
			RPCReq.Rune_TakeOffPageAllRune(params, params.onSuccess)
		end				
		Alert.show(info)
	end)
	--所有符文属性叠加
	self.smallPage2.prosList:setItemRenderer(function (index,obj)
		    local data = self.smallPage2.prosList._dataTemplate[index+1]
            obj:getChildAutoType("title"):setText(Desc["common_fightAttr"..data.id])
			obj:getChildAutoType("titleVal"):setText("+"..GMethodUtil:getFightAttrName(data.id,data.value))
			if data.id < 100 or RuneConfiger.isHightAttr(data.id) then
				obj:getChildAutoType("title"):setColor(cc.c3b(0xff, 0xA4, 0x43))
				obj:getChildAutoType("titleVal"):setColor(cc.c3b(0xff, 0xA4, 0x43))
			else
				obj:getChildAutoType("title"):setColor(ColorUtil.textColor.white)
				obj:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.white)
			end
    end)
    --符文技能list
    self.smallPage2.skillList:setItemRenderer(function (index,obj)
    	 obj:removeClickListener(100)
    	 local itemSkillObj = obj:getChildAutoType("itemSkillCell")
    	 local skillId = self.smallPage2.skillList._dataTemplate[index+1]
         local statusCtrl = obj:getController("statusCtrl")
         if skillId == 0 then
         	statusCtrl:setSelectedIndex(0)
         	obj:addClickListener(function( ... )
                ViewManager.open("RuneSkillView")
            end,100)
         else
         	statusCtrl:setSelectedIndex(1)
            local iconLoader = itemSkillObj:getChildAutoType("iconLoader")
            local selectFrameImg = itemSkillObj:getChildAutoType("selectFrameImg")
            local __levelLabel = itemSkillObj:getChildAutoType("lv")
            local lockCtrl = itemSkillObj:getController("lockCtrl")
            selectFrameImg:setVisible(false)
            __levelLabel:setVisible(false)
            --暂时使用被动技能
            -- local skillInfo = DynamicConfigData.t_skill[skillId]
            local skillInfo = DynamicConfigData.t_passiveSkill[skillId]
            if skillInfo then
                local skillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
                iconLoader:setURL(skillurl)
            end
            obj:addClickListener(function( ... )
				ViewManager.open("RuneSkillView")
                --ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId,data = skillInfo,btnShow = true})
            end,100)

         end
	end)
	RedManager.register("V_PACKAGE_SKILL", self.smallPage2:getChildAutoType("img_red"))
end

function RuneSystemView:updateSmallPage2( ... )
	self.smallPage2.allLevel:setText(RuneSystemModel:getRuleAllLevel( RuneSystemModel:getCurBjRuneID() ))
	local allPros = RuneSystemModel:getRuleAllPros(RuneSystemModel:getCurBjRuneID())
	for _,v in ipairs(allPros) do
		v.isHigh = (v.id < 100 or RuneConfiger.isHightAttr(v.id)) and 1 or 0
	end
	TableUtil.sortByMap(allPros, {{key = "isHigh",asc = true}, {key = "id",asc = false}})
	self.smallPage2.prosList:setData(allPros)
	
	local pageData = RuneSystemModel:getRunePagesById( RuneSystemModel:getCurBjRuneID() )
	local skillData = {}
	if pageData then
        skillData = pageData.skills
	end
	
	if not  (#skillData>0) then
		table.insert(skillData,0)
	end
	self.smallPage2.skillList:setData(skillData)
	self.smallPage2.btn_change:setVisible(#skillData > 0 and skillData[1] ~= 0)
    if skillData[1]~=0 then
    	self.smallPage2:getController("statusCtrl"):setSelectedIndex(1)
    	local skillInfo = DynamicConfigData.t_passiveSkill[skillData[1]]
    	self.smallPage2.skillName:setText(skillInfo.name)
    	self.smallPage2.skillTxt:setText(skillInfo.desc)
    else
    	self.smallPage2:getController("statusCtrl"):setSelectedIndex(0)
    end
	if RuneSystemModel:checkHadRunes( RuneSystemModel:getCurBjRuneID() ) then
		self.smallPage2.btn_clear:setTouchable(true)
		self.smallPage2.btn_clear:setGrayed(false)
	else
		self.smallPage2.btn_clear:setTouchable(false)
		self.smallPage2.btn_clear:setGrayed(true)
	end
end

function RuneSystemView:update_RuneServerData( ... )
	print(1,"RuneSystemView:update_RuneServerData  ",self.smallPageIndex)
	if self.smallPageIndex == 1 then
		self:updateSmallPage1()
	elseif self.smallPageIndex == 2 then
		self:updateSmallPage2()
	elseif self.smallPageIndex == 3 then
		self:updateSmallPage3()
    end
end

function RuneSystemView:update_smallPage( _,params )
	self:update_RuneServerData()
end

function RuneSystemView:initSmallPanel3( ... )

	self.smallPage3.close_change:removeClickListener(100)
	self.smallPage3.close_change:addClickListener(function()
		Dispatcher.dispatchEvent(EventType.init_smallPageShow)
	end,100)

	local proList = self.smallPage3.proList
	proList:setItemRenderer(function ( index2,obj2 )
		local data = proList._dataTemplate
		obj2:getChildAutoType("title"):setText(Desc["common_fightAttr"..data[index2+1].id])
		obj2:getChildAutoType("titleVal"):setText("+"..GMethodUtil:getFightAttrName(data[index2+1].id,data[index2+1].value))
		if data[index2+1].id < 100 or RuneConfiger.isHightAttr(data[index2+1].id) then
			obj2:getChildAutoType("title"):setColor(ColorUtil.textColor.yellow)
			obj2:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.yellow)
		else
			obj2:getChildAutoType("title"):setColor(ColorUtil.textColor.black)
			obj2:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.black)
		end
	end)

	--卸载
	self.smallPage3.btn_gh:addClickListener(function( ... )
		if self.curRuneData and self.curRuneData.runeColor then
			--请求服务器脱下
			local params = {}
			params.id = self.curRuneData.id
			params.type = self.curRuneData.type
			params.index = self.curRuneData.index
			params.onSuccess = function (res )
			    printTable(1,"请求更换成功服务器数据=",res)
		    	if self.curRuneData and self.curRuneData.id == res.id then
		    		local data = {}
				    data.id = res.id 
				    data.runeColor = res.runeColor
				    data.type = res.type
				    data.index = res.index
				    RuneSystemModel:setCurSelectRuneData( data )
		    		RuneSystemModel:updateRunePageRuneColor( res.id,res.type,res.index,res.runeColor )
		    	end
			end
			RPCReq.Rune_TakeOffRune(params, params.onSuccess)
		else
			print(1,"出错拉！！！！")
		end
	end)

	--合成
	self.smallPage3.btn_hc:addClickListener(function( ... )
		self:_setPage("RuneCompoundView")
	end)

end

function RuneSystemView:updateSmallPage3( ... )
	print(1,"RuneSystemView updateSmallPage3")
	self.curRuneData = RuneSystemModel:getCurSelectRuneData(  )
	if self.curRuneData and self.curRuneData.runeColor and self.curRuneData.runeColor.itemCode then
		local itemCode = self.curRuneData.runeColor.itemCode 
		local iconURL = ItemConfiger.getItemIconByCode(itemCode)
		self.smallPage3.runeComp:setIcon(iconURL)
		local itemInfo = ItemConfiger.getInfoByCode(itemCode)
		self.smallPage3.runeName:setText(itemInfo.name)
		self.smallPage3.proList:setData(self.curRuneData.runeColor.attr)
		self.smallPage3.runeComp:getController("selectedCtrl"):setSelectedIndex(0)
		self.smallPage3.runeComp:getController("statusCtrl"):setSelectedIndex(1)
	end
end

function RuneSystemView:_exit( ... )
	if ModelManager.RuneSystemModel then ModelManager.RuneSystemModel:setCurSelectRuneData( false ) end
	Scheduler.scheduleNextFrame(function()
		ViewManager.close("ItemTipsBagView")
	end)
end

return RuneSystemView