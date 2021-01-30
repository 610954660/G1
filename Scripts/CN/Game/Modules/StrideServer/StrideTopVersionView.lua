--Date :2020-12-27
--Author : added by xhd
--Desc : 巅峰赛页面

local StrideTopVersionView,Super = class("StrideTopVersionView", Window)

function StrideTopVersionView:ctor()
	--LuaLog("StrideTopVersionView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideTopVersionView"
	--self._rootDepth = LayerDepth.Window
	self.stateInfo = false
	self.topItemArr = {}
	self.panelData = false
	self.comboxFlag = false
end

function StrideTopVersionView:_initEvent( )
end

function StrideTopVersionView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideTopVersionView
	self.btnCtrl = viewNode:getController('btnCtrl')--Controller
	self.btnGroup = viewNode:getChildAutoType('btnGroup')--GGroup
	self.btn_bz = viewNode:getChildAutoType('btn_bz')--GButton
	self.btn_my = viewNode:getChildAutoType('btn_my')--GButton
	self.btn_rank = viewNode:getChildAutoType('btn_rank')--GButton
	self.btn_reward = viewNode:getChildAutoType('btn_reward')--GButton
	self.btn_shop = viewNode:getChildAutoType('btn_shop')--GButton
	self.comboBox = viewNode:getChildAutoType('comboBox')--GComboBox
	self.curTxt = viewNode:getChildAutoType('curTxt')--GTextField
	self.curType = viewNode:getChildAutoType('curType')--GTextField
	self.rankTxt = viewNode:getChildAutoType('rankTxt')--GRichTextField
	self.seasionTxt = viewNode:getChildAutoType('seasionTxt')--GRichTextField
	self.topItem1 = viewNode:getChildAutoType('topItem1')--strideItem
		self.topItem1.playName = viewNode:getChildAutoType('topItem1/playName')--GTextField
		self.topItem1.playerCell = viewNode:getChildAutoType('topItem1/playerCell')--GButton
		self.topItem1.rIndex = viewNode:getChildAutoType('topItem1/rIndex')--GTextField
		self.topItem1.serverName = viewNode:getChildAutoType('topItem1/serverName')--GTextField
	self.topItem2 = viewNode:getChildAutoType('topItem2')--strideItem
		self.topItem2.playName = viewNode:getChildAutoType('topItem2/playName')--GTextField
		self.topItem2.playerCell = viewNode:getChildAutoType('topItem2/playerCell')--GButton
		self.topItem2.rIndex = viewNode:getChildAutoType('topItem2/rIndex')--GTextField
		self.topItem2.serverName = viewNode:getChildAutoType('topItem2/serverName')--GTextField
	self.topItem3 = viewNode:getChildAutoType('topItem3')--strideItem
		self.topItem3.playName = viewNode:getChildAutoType('topItem3/playName')--GTextField
		self.topItem3.playerCell = viewNode:getChildAutoType('topItem3/playerCell')--GButton
		self.topItem3.rIndex = viewNode:getChildAutoType('topItem3/rIndex')--GTextField
		self.topItem3.serverName = viewNode:getChildAutoType('topItem3/serverName')--GTextField
	self.topItem4 = viewNode:getChildAutoType('topItem4')--strideItem
		self.topItem4.playName = viewNode:getChildAutoType('topItem4/playName')--GTextField
		self.topItem4.playerCell = viewNode:getChildAutoType('topItem4/playerCell')--GButton
		self.topItem4.rIndex = viewNode:getChildAutoType('topItem4/rIndex')--GTextField
		self.topItem4.serverName = viewNode:getChildAutoType('topItem4/serverName')--GTextField
	self.topItem5 = viewNode:getChildAutoType('topItem5')--strideItem
		self.topItem5.playName = viewNode:getChildAutoType('topItem5/playName')--GTextField
		self.topItem5.playerCell = viewNode:getChildAutoType('topItem5/playerCell')--GButton
		self.topItem5.rIndex = viewNode:getChildAutoType('topItem5/rIndex')--GTextField
		self.topItem5.serverName = viewNode:getChildAutoType('topItem5/serverName')--GTextField
	self.topItem6 = viewNode:getChildAutoType('topItem6')--strideItem
		self.topItem6.playName = viewNode:getChildAutoType('topItem6/playName')--GTextField
		self.topItem6.playerCell = viewNode:getChildAutoType('topItem6/playerCell')--GButton
		self.topItem6.rIndex = viewNode:getChildAutoType('topItem6/rIndex')--GTextField
		self.topItem6.serverName = viewNode:getChildAutoType('topItem6/serverName')--GTextField
	self.topItem7 = viewNode:getChildAutoType('topItem7')--strideItem
		self.topItem7.playName = viewNode:getChildAutoType('topItem7/playName')--GTextField
		self.topItem7.playerCell = viewNode:getChildAutoType('topItem7/playerCell')--GButton
		self.topItem7.rIndex = viewNode:getChildAutoType('topItem7/rIndex')--GTextField
		self.topItem7.serverName = viewNode:getChildAutoType('topItem7/serverName')--GTextField
	self.topItem8 = viewNode:getChildAutoType('topItem8')--strideItem
		self.topItem8.playName = viewNode:getChildAutoType('topItem8/playName')--GTextField
		self.topItem8.playerCell = viewNode:getChildAutoType('topItem8/playerCell')--GButton
		self.topItem8.rIndex = viewNode:getChildAutoType('topItem8/rIndex')--GTextField
		self.topItem8.serverName = viewNode:getChildAutoType('topItem8/serverName')--GTextField
	--{autoFieldsEnd}:StrideServer.StrideTopVersionView
	--Do not modify above code-------------

end

function StrideTopVersionView:update_event_combox(_,context)
	if self.comboxFlag then
		self.comboxFlag = not self.comboxFlag
		if self.comboxFlag then
			self.btnCtrl:setSelectedIndex(1)
		else
			self.btnCtrl:setSelectedIndex(0)
		end
	end
end


function StrideTopVersionView:_initListener( )
	
	--打开布阵
	self.btn_bz:addClickListener(function()
		local const = DynamicConfigData.t_TopArenaConfig[1]
		local function battleHandler(eventName)
			if eventName == "begin" then
				RollTips.show(Desc.HigherPvP_saveDefSuc)
                ViewManager.close("BattlePrepareView")
			end
		end
		local args = {
			fightID= const.fightId,
			configType = GameDef.BattleArrayType.TopArenaAckOne,
		}
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,args)
	end)

	

	self.btn_my:addClickListener(function()
		print(1,"我的赛程被点击")
        ViewManager.open("StrideMyCourseView")
	end)

	self.btn_rank:addClickListener(function()
		print(1,"排行被点击")
        ViewManager.open("StridePVPRankView")
	end)

	self.btn_reward:addClickListener(function()
		ViewManager.open("StrideRewardView")
	end)

	self.btn_shop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.Shop_strideShop.id,true)
	end)
	
	
	self.comboBox:addEventListener(FUIEventType.Click,function(context)
		self.comboxFlag = not self.comboxFlag
		if self.comboxFlag then
			self.btnCtrl:setSelectedIndex(1)
		else
			self.btnCtrl:setSelectedIndex(0)
		end
		context:stopPropagation()

	end)
	
	self.comboBox:addEventListener(FUIEventType.Changed,function(data)
		self.comboxFlag = not self.comboxFlag
		if self.comboxFlag then
			self.btnCtrl:setSelectedIndex(1)
		else
			self.btnCtrl:setSelectedIndex(0)
		end
		 local value = self.comboBox:getValue()
		 local curZoneId = StrideServerModel:getCurSelectZone()
		 if curZoneId~=tonumber(value) then
			StrideServerModel:setCurSelectZone(value)
			StrideServerModel:reqTopPanelInfo(value)
		 end
	end)

end

function StrideTopVersionView:_initUI( )
	self:_initVM()
	self:_initListener()
	StrideServerModel:reqTopPanelInfo(1)
end

function StrideTopVersionView:_refresh()
	self:update_stride_dianfenPanel()
end

--请求数据返回
function StrideTopVersionView:update_stride_dianfenPanel( )
	self.stateInfo = StrideServerModel:getStateInfo(  )
	self.panelData = StrideServerModel:getTopPanelInfo(  )
	if (not self.stateInfo) or (not self.panelData) then
		return
	end
	self:updatePanel()
end

function StrideTopVersionView:update_stride_histroyRank( _,params )
    if tolua.isnull(self.view) then return end
	if params>0 then			
		self.rankTxt:setVar("num",tostring(params))
		self.rankTxt:flushVars()
	else
		self.rankTxt:setText(DescAuto[311]) -- [311]='未上榜'
	end
end

--更新页面
function StrideTopVersionView:updatePanel(  )
	if tolua.isnull(self.view) then return end
	local seanum = StrideServerModel:getSeasonId() or 0
	self.seasionTxt:setVar("num",tostring(seanum))
	self.seasionTxt:flushVars()

	self.comboBox:setTitle(DescAuto[308]) -- [308]="第一赛区"
	local strArr = {}
	local valArr = {}
	local allZoneNum = StrideServerModel:getAllzoneNum()
	if allZoneNum>0 then
		for i = 1, allZoneNum do
			local str = DescAuto[241]..StringUtil.transNumToChnNum(i)..DescAuto[287] -- [241]="第" -- [287]="赛区"
			table.insert( strArr,str )
			table.insert( valArr,i )
		end
	end
	self.comboBox:setItems(strArr)
	self.comboBox:setValues(valArr)
	self.comboBox:refresh()
	local curSelectZone = StrideServerModel:getCurSelectZone()
	if not curSelectZone then
		StrideServerModel:setCurSelectZone(1)
		self.comboBox:setSelectedIndex(1)
	else
		local temp = self.comboBox:getValue()
		StrideServerModel:setCurSelectZone(tonumber(temp) or 1)
	end
	
	

	-- body
    local id =StrideServerModel:getSeasonId()
	local str1,str2 = StrideServerModel:getBigStageStr(  )
	local smallStr = StrideServerModel:getSmallStateStr()
	self.curTxt:setText(string.format( "%s%s",str1,str2))
	self.curType:setText("("..smallStr..")")
	if self.panelData.myRank>0 then			
		self.rankTxt:setVar("num",tostring(self.panelData.myRank))
		self.rankTxt:flushVars()
	else
		self.rankTxt:setText(DescAuto[311]) -- [311]='未上榜'
	end
	for i = 1, 8 do
	   self.topItemArr[i] = BindManager.bindStrideCell(self["topItem"..i])
	   if self.panelData and self.panelData.rankList then
		  self.topItemArr[i]:setData(self.panelData.rankList[i])
	   else
		  self.topItemArr[i]:setData(nil)
	   end
	  
	end
	
end

return StrideTopVersionView
