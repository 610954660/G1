--Date :2020-12-27
--Author : added by xhd
--Desc : 晋级赛选拔

local StrideRankJJGameView,Super = class("StrideRankJJGameView", Window)

function StrideRankJJGameView:ctor()
	--LuaLog("StrideRankJJGameView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideRankJJGameView"
	--self._rootDepth = LayerDepth.Window
	self.addTag = 1
	self.curGroupId = 1
	self.calltimer = false
	self.addMap = {}
	self.touchBtn = false
	self.xiantiaoAnima = {}
end

function StrideRankJJGameView:_initEvent( )
	
end

function StrideRankJJGameView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideRankJJGameView
	self.bar1_1 = viewNode:getChildAutoType('$bar1_1')--GProgressBar
	self.bar1_2 = viewNode:getChildAutoType('$bar1_2')--GProgressBar
	self.bar1_3 = viewNode:getChildAutoType('$bar1_3')--GProgressBar
	self.bar1_4 = viewNode:getChildAutoType('$bar1_4')--GProgressBar
	self.bar2_1 = viewNode:getChildAutoType('$bar2_1')--ProgressBar1
		self.bar2_1.img_ani = viewNode:getChildAutoType('$bar2_1/img_ani')--GLoader
	self.bar2_2 = viewNode:getChildAutoType('$bar2_2')--ProgressBar1
		self.bar2_2.img_ani = viewNode:getChildAutoType('$bar2_2/img_ani')--GLoader
	self.bar2_3 = viewNode:getChildAutoType('$bar2_3')--ProgressBar1
		self.bar2_3.img_ani = viewNode:getChildAutoType('$bar2_3/img_ani')--GLoader
	self.bar2_4 = viewNode:getChildAutoType('$bar2_4')--ProgressBar1
		self.bar2_4.img_ani = viewNode:getChildAutoType('$bar2_4/img_ani')--GLoader
	self.btn_choose1 = viewNode:getChildAutoType('$btn_choose1')--Button14
	self.btn_choose2 = viewNode:getChildAutoType('$btn_choose2')--Button14
	self.btn_choose3 = viewNode:getChildAutoType('$btn_choose3')--Button14
	self.btn_choose4 = viewNode:getChildAutoType('$btn_choose4')--Button14
	self.btn_choose5 = viewNode:getChildAutoType('$btn_choose5')--Button14
	self.btn_left = viewNode:getChildAutoType('$btn_left')--btn_arrow
	self.btn_right = viewNode:getChildAutoType('$btn_right')--btn_arrow
	self.heroCell1_1 = viewNode:getChildAutoType('$heroCell1_1')--Component8
		self.heroCell1_1.btn_video = viewNode:getChildAutoType('$heroCell1_1/$btn_video')--GButton
		self.heroCell1_1.heroCell = viewNode:getChildAutoType('$heroCell1_1/heroCell')--GButton
		self.heroCell1_1.img_shouzhi = viewNode:getChildAutoType('$heroCell1_1/img_shouzhi')--GImage
		self.heroCell1_1.img_shouzhiani = viewNode:getChildAutoType('$heroCell1_1/img_shouzhiani')--GLoader
		self.heroCell1_1.txt_num = viewNode:getChildAutoType('$heroCell1_1/txt_num')--GRichTextField
		self.heroCell1_1.txt_playername = viewNode:getChildAutoType('$heroCell1_1/txt_playername')--GTextField
	self.heroCell1_2 = viewNode:getChildAutoType('$heroCell1_2')--Component8
		self.heroCell1_2.btn_video = viewNode:getChildAutoType('$heroCell1_2/$btn_video')--GButton
		self.heroCell1_2.heroCell = viewNode:getChildAutoType('$heroCell1_2/heroCell')--GButton
		self.heroCell1_2.img_shouzhi = viewNode:getChildAutoType('$heroCell1_2/img_shouzhi')--GImage
		self.heroCell1_2.img_shouzhiani = viewNode:getChildAutoType('$heroCell1_2/img_shouzhiani')--GLoader
		self.heroCell1_2.txt_num = viewNode:getChildAutoType('$heroCell1_2/txt_num')--GRichTextField
		self.heroCell1_2.txt_playername = viewNode:getChildAutoType('$heroCell1_2/txt_playername')--GTextField
	self.heroCell2_1 = viewNode:getChildAutoType('$heroCell2_1')--Component8
		self.heroCell2_1.btn_video = viewNode:getChildAutoType('$heroCell2_1/$btn_video')--GButton
		self.heroCell2_1.heroCell = viewNode:getChildAutoType('$heroCell2_1/heroCell')--GButton
		self.heroCell2_1.img_shouzhi = viewNode:getChildAutoType('$heroCell2_1/img_shouzhi')--GImage
		self.heroCell2_1.img_shouzhiani = viewNode:getChildAutoType('$heroCell2_1/img_shouzhiani')--GLoader
		self.heroCell2_1.txt_num = viewNode:getChildAutoType('$heroCell2_1/txt_num')--GRichTextField
		self.heroCell2_1.txt_playername = viewNode:getChildAutoType('$heroCell2_1/txt_playername')--GTextField
	self.heroCell2_2 = viewNode:getChildAutoType('$heroCell2_2')--Component8
		self.heroCell2_2.btn_video = viewNode:getChildAutoType('$heroCell2_2/$btn_video')--GButton
		self.heroCell2_2.heroCell = viewNode:getChildAutoType('$heroCell2_2/heroCell')--GButton
		self.heroCell2_2.img_shouzhi = viewNode:getChildAutoType('$heroCell2_2/img_shouzhi')--GImage
		self.heroCell2_2.img_shouzhiani = viewNode:getChildAutoType('$heroCell2_2/img_shouzhiani')--GLoader
		self.heroCell2_2.txt_num = viewNode:getChildAutoType('$heroCell2_2/txt_num')--GRichTextField
		self.heroCell2_2.txt_playername = viewNode:getChildAutoType('$heroCell2_2/txt_playername')--GTextField
	self.heroCell2_3 = viewNode:getChildAutoType('$heroCell2_3')--Component8
		self.heroCell2_3.btn_video = viewNode:getChildAutoType('$heroCell2_3/$btn_video')--GButton
		self.heroCell2_3.heroCell = viewNode:getChildAutoType('$heroCell2_3/heroCell')--GButton
		self.heroCell2_3.img_shouzhi = viewNode:getChildAutoType('$heroCell2_3/img_shouzhi')--GImage
		self.heroCell2_3.img_shouzhiani = viewNode:getChildAutoType('$heroCell2_3/img_shouzhiani')--GLoader
		self.heroCell2_3.txt_num = viewNode:getChildAutoType('$heroCell2_3/txt_num')--GRichTextField
		self.heroCell2_3.txt_playername = viewNode:getChildAutoType('$heroCell2_3/txt_playername')--GTextField
	self.heroCell2_4 = viewNode:getChildAutoType('$heroCell2_4')--Component8
		self.heroCell2_4.btn_video = viewNode:getChildAutoType('$heroCell2_4/$btn_video')--GButton
		self.heroCell2_4.heroCell = viewNode:getChildAutoType('$heroCell2_4/heroCell')--GButton
		self.heroCell2_4.img_shouzhi = viewNode:getChildAutoType('$heroCell2_4/img_shouzhi')--GImage
		self.heroCell2_4.img_shouzhiani = viewNode:getChildAutoType('$heroCell2_4/img_shouzhiani')--GLoader
		self.heroCell2_4.txt_num = viewNode:getChildAutoType('$heroCell2_4/txt_num')--GRichTextField
		self.heroCell2_4.txt_playername = viewNode:getChildAutoType('$heroCell2_4/txt_playername')--GTextField
	self.heroCell3_1 = viewNode:getChildAutoType('$heroCell3_1')--Component8
		self.heroCell3_1.btn_video = viewNode:getChildAutoType('$heroCell3_1/$btn_video')--GButton
		self.heroCell3_1.heroCell = viewNode:getChildAutoType('$heroCell3_1/heroCell')--GButton
		self.heroCell3_1.img_shouzhi = viewNode:getChildAutoType('$heroCell3_1/img_shouzhi')--GImage
		self.heroCell3_1.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_1/img_shouzhiani')--GLoader
		self.heroCell3_1.txt_num = viewNode:getChildAutoType('$heroCell3_1/txt_num')--GRichTextField
		self.heroCell3_1.txt_playername = viewNode:getChildAutoType('$heroCell3_1/txt_playername')--GTextField
	self.heroCell3_2 = viewNode:getChildAutoType('$heroCell3_2')--Component8
		self.heroCell3_2.btn_video = viewNode:getChildAutoType('$heroCell3_2/$btn_video')--GButton
		self.heroCell3_2.heroCell = viewNode:getChildAutoType('$heroCell3_2/heroCell')--GButton
		self.heroCell3_2.img_shouzhi = viewNode:getChildAutoType('$heroCell3_2/img_shouzhi')--GImage
		self.heroCell3_2.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_2/img_shouzhiani')--GLoader
		self.heroCell3_2.txt_num = viewNode:getChildAutoType('$heroCell3_2/txt_num')--GRichTextField
		self.heroCell3_2.txt_playername = viewNode:getChildAutoType('$heroCell3_2/txt_playername')--GTextField
	self.heroCell3_3 = viewNode:getChildAutoType('$heroCell3_3')--Component8
		self.heroCell3_3.btn_video = viewNode:getChildAutoType('$heroCell3_3/$btn_video')--GButton
		self.heroCell3_3.heroCell = viewNode:getChildAutoType('$heroCell3_3/heroCell')--GButton
		self.heroCell3_3.img_shouzhi = viewNode:getChildAutoType('$heroCell3_3/img_shouzhi')--GImage
		self.heroCell3_3.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_3/img_shouzhiani')--GLoader
		self.heroCell3_3.txt_num = viewNode:getChildAutoType('$heroCell3_3/txt_num')--GRichTextField
		self.heroCell3_3.txt_playername = viewNode:getChildAutoType('$heroCell3_3/txt_playername')--GTextField
	self.heroCell3_4 = viewNode:getChildAutoType('$heroCell3_4')--Component8
		self.heroCell3_4.btn_video = viewNode:getChildAutoType('$heroCell3_4/$btn_video')--GButton
		self.heroCell3_4.heroCell = viewNode:getChildAutoType('$heroCell3_4/heroCell')--GButton
		self.heroCell3_4.img_shouzhi = viewNode:getChildAutoType('$heroCell3_4/img_shouzhi')--GImage
		self.heroCell3_4.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_4/img_shouzhiani')--GLoader
		self.heroCell3_4.txt_num = viewNode:getChildAutoType('$heroCell3_4/txt_num')--GRichTextField
		self.heroCell3_4.txt_playername = viewNode:getChildAutoType('$heroCell3_4/txt_playername')--GTextField
	self.heroCell3_5 = viewNode:getChildAutoType('$heroCell3_5')--Component8
		self.heroCell3_5.btn_video = viewNode:getChildAutoType('$heroCell3_5/$btn_video')--GButton
		self.heroCell3_5.heroCell = viewNode:getChildAutoType('$heroCell3_5/heroCell')--GButton
		self.heroCell3_5.img_shouzhi = viewNode:getChildAutoType('$heroCell3_5/img_shouzhi')--GImage
		self.heroCell3_5.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_5/img_shouzhiani')--GLoader
		self.heroCell3_5.txt_num = viewNode:getChildAutoType('$heroCell3_5/txt_num')--GRichTextField
		self.heroCell3_5.txt_playername = viewNode:getChildAutoType('$heroCell3_5/txt_playername')--GTextField
	self.heroCell3_6 = viewNode:getChildAutoType('$heroCell3_6')--Component8
		self.heroCell3_6.btn_video = viewNode:getChildAutoType('$heroCell3_6/$btn_video')--GButton
		self.heroCell3_6.heroCell = viewNode:getChildAutoType('$heroCell3_6/heroCell')--GButton
		self.heroCell3_6.img_shouzhi = viewNode:getChildAutoType('$heroCell3_6/img_shouzhi')--GImage
		self.heroCell3_6.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_6/img_shouzhiani')--GLoader
		self.heroCell3_6.txt_num = viewNode:getChildAutoType('$heroCell3_6/txt_num')--GRichTextField
		self.heroCell3_6.txt_playername = viewNode:getChildAutoType('$heroCell3_6/txt_playername')--GTextField
	self.heroCell3_7 = viewNode:getChildAutoType('$heroCell3_7')--Component8
		self.heroCell3_7.btn_video = viewNode:getChildAutoType('$heroCell3_7/$btn_video')--GButton
		self.heroCell3_7.heroCell = viewNode:getChildAutoType('$heroCell3_7/heroCell')--GButton
		self.heroCell3_7.img_shouzhi = viewNode:getChildAutoType('$heroCell3_7/img_shouzhi')--GImage
		self.heroCell3_7.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_7/img_shouzhiani')--GLoader
		self.heroCell3_7.txt_num = viewNode:getChildAutoType('$heroCell3_7/txt_num')--GRichTextField
		self.heroCell3_7.txt_playername = viewNode:getChildAutoType('$heroCell3_7/txt_playername')--GTextField
	self.heroCell3_8 = viewNode:getChildAutoType('$heroCell3_8')--Component8
		self.heroCell3_8.btn_video = viewNode:getChildAutoType('$heroCell3_8/$btn_video')--GButton
		self.heroCell3_8.heroCell = viewNode:getChildAutoType('$heroCell3_8/heroCell')--GButton
		self.heroCell3_8.img_shouzhi = viewNode:getChildAutoType('$heroCell3_8/img_shouzhi')--GImage
		self.heroCell3_8.img_shouzhiani = viewNode:getChildAutoType('$heroCell3_8/img_shouzhiani')--GLoader
		self.heroCell3_8.txt_num = viewNode:getChildAutoType('$heroCell3_8/txt_num')--GRichTextField
		self.heroCell3_8.txt_playername = viewNode:getChildAutoType('$heroCell3_8/txt_playername')--GTextField
	self.comboBox = viewNode:getChildAutoType('comboBox')--GComboBox
	self.gameType2 = viewNode:getChildAutoType('gameType2')--GTextField
	self.img_ani1_1 = viewNode:getChildAutoType('img_ani1_1')--GLoader
	self.img_ani1_2 = viewNode:getChildAutoType('img_ani1_2')--GLoader
	self.img_ani1_3 = viewNode:getChildAutoType('img_ani1_3')--GLoader
	self.img_ani1_4 = viewNode:getChildAutoType('img_ani1_4')--GLoader
	self.img_ani2_1 = viewNode:getChildAutoType('img_ani2_1')--GLoader
	self.img_ani2_2 = viewNode:getChildAutoType('img_ani2_2')--GLoader
	self.img_ani2_3 = viewNode:getChildAutoType('img_ani2_3')--GLoader
	self.img_ani2_4 = viewNode:getChildAutoType('img_ani2_4')--GLoader
	self.statusTitle = viewNode:getChildAutoType('statusTitle')--GTextField
	self.txt_countdown = viewNode:getChildAutoType('txt_countdown')--GTextField
	--{autoFieldsEnd}:StrideServer.StrideRankJJGameView
	--Do not modify above code-------------
end

function StrideRankJJGameView:_initListener( )
	self.btn_left:addClickListener(
		function(context) --减
			self:getBtnNum(0)
			--0减1加
		end
	)

	self.btn_right:addClickListener(
		function(context) --加
			self:getBtnNum(1)
			--0减1加
		end
	)
	
	--下拉框
	self.comboBox:addEventListener(FUIEventType.Changed,function(data)
		local value = self.comboBox:getValue()
		StrideServerModel:reqGetGrearUpgradeInfo(value,1) -- 请求当前赛区的第一组数据
		self.curGroupId = 1
   end)

   self.comboBox:addEventListener(FUIEventType.Changed,function(data)
	local value = self.comboBox:getValue()
	local championCurArr = StrideServerModel:getGearUpCurArr()
	if championCurArr.zid~=tonumber(value) then
		StrideServerModel:setGearUpCurArrZid(value)
		StrideServerModel:reqGetGrearUpgradeInfo(value,1)
	end
end)


end

function StrideRankJJGameView:_initUI( )
	self:_initVM()
	self:_initListener()
	--初始化请求 --需要默认请求第一赛区 第一组的成员
	local championCurArr = StrideServerModel:getGearUpCurArr()
	if not championCurArr then
		StrideServerModel:reqGetGrearUpgradeInfo(1,1)
	else
		StrideServerModel:reqGetGrearUpgradeInfo(championCurArr.zid,championCurArr.sgid)
	end
end


function StrideRankJJGameView:_refresh( )
	local championCurArr = StrideServerModel:getGearUpCurArr()
	if not championCurArr then
		StrideServerModel:reqGetGrearUpgradeInfo(1,1)
	else
		StrideServerModel:reqGetGrearUpgradeInfo(championCurArr.zid,championCurArr.sgid)
	end
end


--更新整个页面信息
function StrideRankJJGameView:upWorldViewInfo()
	self:showBtn() --拿到组的数据后 做显示
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
		self.calltimer = false
	end
	local bigStage,battleStage = StrideServerModel:getTwoStage()
	if bigStage==1 then
	   self.statusTitle:setVisible(false)
	   self.txt_countdown:setText("未开赛")
	elseif bigStage == 2 then
		self.statusTitle:setVisible(true)
		local str = StrideServerModel:getSmallStateStr()
		self.statusTitle:setText(str) --阶段问题显示

		local status,countdown,smallTime = StrideServerModel:getLastTime(  )
		print(1,"countdown",countdown)
		print(1,"smallTime",smallTime)
		self:showCountDown(smallTime)
	elseif bigStage >= 3 then
		self.statusTitle:setVisible(false)
		self.txt_countdown:setText("已结束")
	end


	--下拉框
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

    self:showView() --显示16位置
end

--请求数据后刷新
function StrideRankJJGameView:update_stride_upGradeJJPvp()
	self:upWorldViewInfo() --刷新UI
end

--小组赛切换按钮
function StrideRankJJGameView:showBtn()
	local gearUpCurArr = StrideServerModel:getCurGrearGroupId()
	if #self.addMap == 0 then
		local index = math.min(28, math.max(1, gearUpCurArr.sgid))
		self.addTag = index
		self.curGroupId = math.min(32, math.max(1, gearUpCurArr.sgid))
		self.addMap = {index, index + 1, index + 2,index + 3,index + 4}
	end
	
	local seleInfo = self.curGroupId
	for i = 1, 5, 1 do
		local num = self.addMap[i]
		local key = "$btn_choose" .. i
		local btnItem = self.view:getChildAutoType(key)
		-- local c1 = btnItem:getController("c1")
		-- if num == gearUpCurArr.sgid then
		-- 	c1:setSelectedIndex(1)
		-- else
		-- 	c1:setSelectedIndex(0)
		-- end
		if num == seleInfo then
			btnItem:setSelected(true)
			self.touchBtn = btnItem
			self:showView() -- 更新具体多少强显示UI
		else
			btnItem:setSelected(false)
		end
		if num == nil then
			num = 1
		end
		btnItem:setTitle(string.format("组%d", num))
		btnItem:removeClickListener(100)
		btnItem:addClickListener(
			function(context)
				if self.touchBtn then
					self.touchBtn:setSelected(false)
				end
				btnItem:setSelected(true)
				self.touchBtn = btnItem
				self.curGroupId = num
				local  zoomID = StrideServerModel:getCurGrearGroupId().zid --赛区ID
				StrideServerModel:reqGetGrearUpgradeInfo(zoomID,num) --请求某一组的数据
			end,
			100
		)
	end
end

--往左 往右按钮事件
function StrideRankJJGameView:getBtnNum(type) --0减1加
	self.addMap = {}
	local flag = type == 0 and -1 or 1
	local tag = self.addTag + 5 * flag
	tag = math.min(28, math.max(1, tag))
	for i = 0, 4 do
		table.insert(self.addMap, tag + i)
	end
	self.addTag = tag;
	self:showBtn()
end

function StrideRankJJGameView:itemCellUpdate(posKey,data,type,firstVal)
	local key = "$heroCell" .. posKey
	local item = self.view:getChildAutoType(key)
	local c1 = item:getController("c1")
	local c2 = item:getController("c2")
	local c3 = item:getController("c3")
	local txt_num = item:getChildAutoType("txt_num")
	local img_shouzhiani = item:getChildAutoType("img_shouzhiani")
	local playerHead = item:getChildAutoType("heroCell")
	local heroItem = BindManager.bindPlayerCell(playerHead)
	local txt_playername = item:getChildAutoType("txt_playername")
	local arrt = string.split(posKey, "_")
	-- 竞猜手指
	c3:setSelectedIndex(0)

	local playerInfo = false
	local recordIdList = false
	local playerIdList = false
	local winPlayerId = false
    local pid =false
	if type ==1 then
		playerInfo = data 
	elseif type ==2 then
		local battleInfo = data
		if battleInfo then
			pid = battleInfo.winPlayerId
			recordIdList = battleInfo.recordIdList
			playerIdList = battleInfo.playerIdList
			winPlayerId = battleInfo.winPlayerId
			playerInfo = StrideServerModel:getGearPlayInfo(pid)
		end
	end

	if (not playerInfo) then --没有参赛人员显示几强
		c1:setSelectedIndex(0)
		c2:setSelectedIndex(0)
		--多少强
		if type == 1 then
			txt_num:setText(firstVal.."强")
		else
			local temp= 1
			if  tonumber(arrt[1]) ==  2 then
                temp = 1
			elseif  tonumber(arrt[1]) == 1 then
				temp = 2
			elseif  tonumber(arrt[1]) == 0 then
                temp = 4
			end
			local num = firstVal/(temp*2)
			if tonumber(arrt[1])==0 and num ==1 then
				txt_num:setText("冠军")
			else
				txt_num:setText(num.."强")
			end
		end
	else
		--玩家状态
		c1:setSelectedIndex(3)
		--玩家名称
		-- local serverName = ""
		-- local serverGroup = LoginModel:getServerGroups()
		-- for _, d in pairs(serverGroup) do
		-- 	for _, info in pairs(d) do
		-- 		if (info.unit_server == playerInfo.serverId) then
		-- 			serverName = info.name;
		-- 		end
		-- 	end
		-- end
        -- print(1,"serverName",serverName)
		txt_playername:setText(string.format("%s\n[S.%s]",playerInfo.name,playerInfo.serverId))
		heroItem:setHead(playerInfo.head, playerInfo.level, nil, nil, playerInfo.headBorder)
		playerHead:removeClickListener(100)
		playerHead:addClickListener(
			function(context)
				-- if (self.mode == 1) then
				-- 	allplayerInfo.fromView = "worldChallenge"
				-- 	ViewManager.open("HigherPvPPlayerInfoView", allplayerInfo)
				-- else
				-- 	ViewManager.open(
				-- 		"FriendCheckView",
				-- 		{playerId = playId, serverId = serverId, arrayType = GameDef.BattleArrayType.DreamPvp}
				-- 	)
				-- end

				local playId = playerInfo.playerId
				local serverId = playerInfo.serverId
				if playId<0 then
					RollTips.show(Desc.Friend_cant_show)
					return
				end
				--这里可能有疑问 是否打开的是这个页面
				ViewManager.open(
					"ViewPlayerView",
					{playerId = playId, serverId = serverId, arrayType = GameDef.BattleArrayType.TopArenaAckOne} --这里的type应该有问题
				)
			end,
		100
		)
		--战斗记录
		if  recordIdList and #recordIdList>0 then
			c2:setSelectedIndex(1)
		else
			c2:setSelectedIndex(0)
		end
		local btn_video = item:getChildAutoType("$btn_video")
		btn_video:removeClickListener(100)
		btn_video:addClickListener(
			function(context)
				ViewManager.open("StrideResultView",{recordIdList = recordIdList})	
				-- if recordIdList then
				-- 	local btypeArr = {GameDef.BattleArrayType.TopArenaAckOne,GameDef.BattleArrayType.TopArenaAckTwo,GameDef.BattleArrayType.TopArenaAckThree}
				-- 	StrideServerModel:battleBegin(recordIdList,btypeArr,GameDef.GamePlayType.TopArena)
				-- end			
			end,
		100)
	end
end

--显示玩家排行  groupId 是哪个分组
function StrideRankJJGameView:showView()
	local data = StrideServerModel:getGearUpgradeData()
	if not data then
       return
	end
	local  bigStage,battleStage = StrideServerModel:getTwoStage()
	local config = false
	if bigStage > 2 then --已经超过了
		self.gameType2:setText("256晋64")
	elseif bigStage <=1 then
		self.gameType2:setText("256晋128")
	else
		local str1 ,str2 = StrideServerModel:getBigStageStr( )
		self.gameType2:setText(str2)
	end
	

	--具体的显示位置
	local ItemPosNum = StrideServerModel.ItemPosJJ
	local bigStage,battleStage =  StrideServerModel:getTwoStage(  )
	local first = 256
	if bigStage >2 then --晋级赛已经过了
		first = 256
	end
	for i = 1, 8, 1 do
		local posKey = ItemPosNum[i] --左右两边8个
		self:itemCellUpdate(posKey,data.playerList[i],1,first)
	end
	
	--其他的补位
	for i = 9,#ItemPosNum,1 do
		local posKey = ItemPosNum[i] --其他的
		local arr = string.split(posKey, "_")
		local pos = tonumber(arr[1]..arr[2])
		if tonumber(arr[1]) == 2 then
			pos = pos - 10
		elseif  tonumber(arr[1])  == 1 then
			pos = pos + 10
		end 
		local battleInfo = false
		for i,v in ipairs(data.battleNodeList) do
			if v.pos == pos then
				battleInfo = v
			end
		end
		self:itemCellUpdate(posKey,battleInfo,2,first)
	end
	self:showLine()
end


--显示线
function StrideRankJJGameView:showLine()
	local lineNum = StrideServerModel.LinePosJJ --晋级的线组
	for lineId = 1, #lineNum, 1 do
		local tiaoKey = lineNum[lineId]
		local lineKey = "$bar" .. tiaoKey
		local barItem = self.view:getChildAutoType(lineKey)
		barItem:setMin(0)
		barItem:setMax(100)
		local img = barItem:getChildAutoType("bar") --高亮的路线

		local isShowAnim = StrideServerModel:getWorldChallengeXiantiao(tiaoKey,1) --获取需要显示特效的线组
		local img_ani = self.view:getChildAutoType("img_ani" .. tiaoKey)
		print(1,"1111111111tiaoKey",tiaoKey,isShowAnim)
		if isShowAnim then
			if not self.xiantiaoAnima[tiaoKey] then
				print(1,"创建")
				self.xiantiaoAnima[tiaoKey] = self:getXiantiaoAnim(tiaoKey, img_ani,1)
			end
		else
			print(1,"不良")
			if self.xiantiaoAnima[tiaoKey] then
				print(1,"销毁")
				SpineUtil.clearEffect(self.xiantiaoAnima[tiaoKey])
				self.xiantiaoAnima[tiaoKey] = false
			end
		end

		local isLine = StrideServerModel:getLineBarState(tiaoKey,1)
		if isLine == 1 then
			img:setFillOrigin(0) -- 图片方向设置为上到下
			barItem:setValue(54)  --设置进度条值填充
		elseif isLine == 2 then
			img:setFillOrigin(1) --图片方向设置为下到到
			barItem:setValue(50)
		elseif isLine == 3 then
			img:setFillOrigin(2)  --左到右
			barItem:setValue(50)
		elseif isLine == 4 then
			img:setFillOrigin(3)  --右到左
			barItem:setValue(51)
		elseif isLine == true then --进度全亮
			barItem:setValue(100)
		elseif isLine == false then  --进度全黑
			barItem:setValue(0)
		end
	end
end

--获取线条
function StrideRankJJGameView:getXiantiaoAnim(lineId, barImg,type)
	local ani = StrideServerModel:getXiantiaobyStageAnim(barImg,type)
	print(1,"lineID",lineId,ani)
	if ani ~= false then
		local arr = string.split(lineId, "_")
		local key = tonumber(arr[1])
		local pos = tonumber(arr[2])
		if key == 2 and (pos == 3 or pos == 4) then
			ani:setScaleX(-1)
		elseif key == 1 and pos == 3 then
			ani:setScaleX(-1)
		elseif key == 1 and pos == 2 then
			ani:setScaleY(-1)
		elseif key == 1 and pos == 4 then
			ani:setScaleX(-1)
			ani:setScaleY(-1)
		end
	end
	return ani
end


--显示倒计时
function StrideRankJJGameView:showCountDown(countdown)
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
		self.calltimer = false
	end
	if countdown > 0 then
		self.txt_countdown:setText(TimeLib.GetTimeFormatDay(countdown, 2))
		local function onCountDown(time)
			self.txt_countdown:setText(TimeLib.formatTime(time, 2))
		end
		local function onEnd(...)
			self.txt_countdown:setText(Desc.DreamMasterPvp_allend)
		end
		if self.calltimer then
			TimeLib.clearCountDown(self.calltimer)
			self.calltimer = false
		end
		self.calltimer = TimeLib.newCountDown(countdown, onCountDown, onEnd, false, false, false)
	else
		self.txt_countdown:setText(Desc.DreamMasterPvp_allend)
	end
end

function StrideRankJJGameView:_exit()
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
		self.calltimer = false
	end
end

return StrideRankJJGameView