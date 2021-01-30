--Date :2020-12-27
--Author : added by xhd
--Desc : 巅峰赛我的赛程

local StrideMyCourseView,Super = class("StrideMyCourseView", Window)

function StrideMyCourseView:ctor()
	--LuaLog("StrideMyCourseView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideMyCourseView"
	self._rootDepth = LayerDepth.PopWindow
end

function StrideMyCourseView:_initEvent( )
	
end

function StrideMyCourseView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideMyCourseView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.dataCtrl = viewNode:getController('dataCtrl')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	self.typeTxt = viewNode:getChildAutoType('typeTxt')--GRichTextField
	--{autoFieldsEnd}:StrideServer.StrideMyCourseView
	--Do not modify above code-------------
end

function StrideMyCourseView:_initListener( )
	
	-- self.blackBg:addClickListener(function()

	-- end)

	self.list:setItemRenderer(function(idx, obj)
		local index = idx + 1
        local data = self.list._dataTemplate[index]
		local gametxt1 = obj:getChildAutoType("gametxt1")
		local ganetxt2 = obj:getChildAutoType("ganetxt2")
		local daytime = obj:getChildAutoType("daytime")
		local resultCtrl = obj:getController("resultCtrl")

        local leftCell = obj:getChildAutoType("leftCell")
        local txt_name1 = obj:getChildAutoType("txt_name1")
		local txt_power1 = obj:getChildAutoType("txt_power1")

		local rightCell = obj:getChildAutoType("rightCell")
        local txt_name2 = obj:getChildAutoType("txt_name2")
		local txt_power2 = obj:getChildAutoType("txt_power2")
		
		daytime:setText(TimeLib.msToString( data.time, "%Y-%m-%d" ))

		resultCtrl:setSelectedIndex(data.result)
		local str1,str2 = StrideServerModel:getBigStageStr(data.bigStage,data.battleStage)
		print(1,"data.result",data.bigStage,data.battleStage,data.result,str1,str2)
		gametxt1:setText(str1)
		ganetxt2:setText(str2)
		-- if str2=="" then
		-- 	gametxt1:setPosition(325,97)
		-- else
		-- 	gametxt1:setPosition(306,97)
		-- end
		local leftCellScript = BindManager.bindPlayerCell(leftCell)
		local leftPlayData = data.playerInfo[1]
		txt_name1:setText(leftPlayData.name)
		leftCellScript:setHead(leftPlayData.head, leftPlayData.level, leftPlayData.playerId, leftPlayData.name, leftPlayData.headBorder)
		local rightCellScript = BindManager.bindPlayerCell(rightCell)
		local rightPlayData = data.playerInfo[2]
		txt_name2:setText(rightPlayData.name)
		rightCellScript:setHead(rightPlayData.head, rightPlayData.level, rightPlayData.playerId, rightPlayData.name, rightPlayData.headBorder)
		txt_power1:setText(leftPlayData.combat)
		txt_power2:setText(rightPlayData.combat)
	end)

end

function StrideMyCourseView:_initUI( )
	self:_initVM()
	self:_initListener()
	StrideServerModel:reqGetMyBattleInfo()
end

function  StrideMyCourseView:update_stride_myCourse( _,params )
	self:updatePanel(params.data)
end

function StrideMyCourseView:updatePanel( data )
	self.typeTxt:setText(DescAuto[241]..data.zoneId..DescAuto[287]) 
	local listData = data.infoList
	table.sort(listData,function(a,b) 
		return a.time>b.time
	end)
	self.list:setData(listData)
	if #data.infoList>0 then
		self.dataCtrl:setSelectedIndex(0)
	else
		self.dataCtrl:setSelectedIndex(1)
	end
end

function StrideMyCourseView:_exit( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
		self.__timerId = false
	end
end



return StrideMyCourseView
