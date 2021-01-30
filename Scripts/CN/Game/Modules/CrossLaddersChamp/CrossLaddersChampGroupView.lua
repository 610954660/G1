--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 晋级赛界面

local CrossLaddersChampGroupView,Super = class("CrossLaddersChampGroupView", Window)

local __stageShowFlag = {} 	-- 根据阶段去取每个阶段要显示多少个位置的信息
for stage=tonumber(GameDef.SkyLadChampionStage.Start),tonumber(GameDef.SkyLadChampionStage.End) do
	local val -- 取小于等于该位置的数据
	if stage < tonumber(GameDef.SkyLadChampionStage.Top64) then
		val = 0
	elseif (stage ==  tonumber(GameDef.SkyLadChampionStage.Top64))  or (stage ==  tonumber(GameDef.SkyLadChampionStage.Top8))then
		val = 8
	elseif (stage ==  tonumber(GameDef.SkyLadChampionStage.Top32)) or (stage ==  tonumber(GameDef.SkyLadChampionStage.Top4)) then
		val = 12
	elseif (stage ==  tonumber(GameDef.SkyLadChampionStage.Top16)) or (stage ==  tonumber(GameDef.SkyLadChampionStage.Top2)) then
		val = 14
	elseif stage ==  tonumber(GameDef.SkyLadChampionStage.End) then
		val = 15
	end
	__stageShowFlag[stage] = val
end


local __showStage = {{},{}} -- 每个位置要显示的文字 例如64强 32强
for page=1,2 do
	for pos = 1,15 do
		local val
		if page == 1 then
			if pos <= 8 then val = 64 end
			if pos > 8 and pos <= 12 then val = 32 end
			if pos > 12 and pos <= 14 then val = 16 end
			if pos > 14 then val = 8 end
		else
			if pos <= 8 then val = 8 end
			if pos > 8 and pos <= 12 then val = 4 end
			if pos > 12 and pos <= 14 then val = 2 end
			if pos > 14 then val = 1 end
		end
		__showStage[page][pos]=val
	end
end


local __matchRound = { 	-- 对应标题图片
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 1, 	-- 64强
	[9] = 2, 	-- 32强
	[10] = 3, 	-- 16强
	[11] = 4, 	-- 8强
	[12] = 5, 	-- 4强
	[13] = 6, 	-- 2强
	[14] = 7, 	-- 活动结束
}

local _stageToLine = { 	-- 每个阶段对应的线
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 1, 	-- 64强 	-- 第一条线
	[9] = 5, 	-- 32强 	-- 第五条线
	[10] = 7, 	-- 16强 	-- 第七条线
	[11] = 1, 	-- 8强
	[12] = 5, 	-- 4强
	[13] = 7, 	-- 2强
	[14] = 7, 	-- 活动结束
}


local __lineToPos = { 	-- 每条线对应要取的位置
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 8,
	[6] = 0,
	[7] = 12,
}

local __checkWinGroup = { 	-- 每个位置的对应关系
    {1,2,9}, 	-- 第1,2个位置打完对应位置9
    {3,4,10},
    {5,6,11},
    {7,8,12},
    {9,10,13},
    {11,12,14},
    {13,14,15},
}

local __posToStage = {{},{}}	-- 每个位置转化成对应的阶段
for page=1,2 do 	-- i 晋级赛和冠军赛
	for pos=1,14 do -- j 表示坑位
		local val 	-- 对应的阶段
		if page == 1 then
			val = pos<=9 and GameDef.SkyLadChampionStage.Top16 or GameDef.SkyLadChampionStage.Top8
		else
			val = pos<=9 and GameDef.SkyLadChampionStage.Top2 or GameDef.SkyLadChampionStage.End
		end
		__posToStage[page][pos] = tonumber(val)
	end
end

function CrossLaddersChampGroupView:ctor()
	--LuaLog("CrossLaddersChampGroupView ctor")
	self._packName = "CrossLaddersChamp"
	self._compName = "CrossLaddersChampGroupView"
	--self._rootDepth = LayerDepth.Window
	self.statusInfo = {}
	self.spineMap = {}
	self.curGroup = 1;
	self.groupIndexMap = false;
	self.showGroup = 1;
	self.allGroupInfo = {} 	-- 所有分组的信息 包括分组id  和节点id
	self.curGroupInfo = {} 	-- 当前分组的信息
	self.nodeInfo 	= {} 	-- 每个节点信息
	self.timer 	= false
	self.pageIndex = 2
end


function CrossLaddersChampGroupView:_initEvent( )
	
end

function CrossLaddersChampGroupView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLaddersChamp.CrossLaddersChampGroupView
	self.btn_choose1 = viewNode:getChildAutoType('$btn_choose1')--Button14
	self.btn_choose2 = viewNode:getChildAutoType('$btn_choose2')--Button14
	self.btn_choose3 = viewNode:getChildAutoType('$btn_choose3')--Button14
	self.btn_left = viewNode:getChildAutoType('$btn_left')--btn_arrow
	self.btn_right = viewNode:getChildAutoType('$btn_right')--btn_arrow
	self.btn_guess = viewNode:getChildAutoType('btn_guess')--btn_data
		self.btn_guess.img_red = viewNode:getChildAutoType('btn_guess/img_red')--GImage
	self.btn_halloffame = viewNode:getChildAutoType('btn_halloffame')--GButton
	self.btn_match1 = viewNode:getChildAutoType('btn_match1')--btn_matchType
	self.btn_match2 = viewNode:getChildAutoType('btn_match2')--btn_matchType
	self.btn_mymatch = viewNode:getChildAutoType('btn_mymatch')--Button8
		self.btn_mymatch.img_red = viewNode:getChildAutoType('btn_mymatch/img_red')--GImage
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.group_1 = viewNode:getChildAutoType('group_1')--com_guildGroup
		self.group_1.btn_video = viewNode:getChildAutoType('group_1/btn_video')--btn_data
			self.group_1.btn_video.img_red = viewNode:getChildAutoType('group_1/btn_video/img_red')--GImage
		self.group_1.heroCell = viewNode:getChildAutoType('group_1/heroCell')--GButton
		self.group_1.txt_name = viewNode:getChildAutoType('group_1/txt_name')--GTextField
		self.group_1.txt_stage = viewNode:getChildAutoType('group_1/txt_stage')--GTextField
	self.group_10 = viewNode:getChildAutoType('group_10')--com_guildGroup
		self.group_10.btn_video = viewNode:getChildAutoType('group_10/btn_video')--btn_data
			self.group_10.btn_video.img_red = viewNode:getChildAutoType('group_10/btn_video/img_red')--GImage
		self.group_10.heroCell = viewNode:getChildAutoType('group_10/heroCell')--GButton
		self.group_10.txt_name = viewNode:getChildAutoType('group_10/txt_name')--GTextField
		self.group_10.txt_stage = viewNode:getChildAutoType('group_10/txt_stage')--GTextField
	self.group_11 = viewNode:getChildAutoType('group_11')--com_guildGroup
		self.group_11.btn_video = viewNode:getChildAutoType('group_11/btn_video')--btn_data
			self.group_11.btn_video.img_red = viewNode:getChildAutoType('group_11/btn_video/img_red')--GImage
		self.group_11.heroCell = viewNode:getChildAutoType('group_11/heroCell')--GButton
		self.group_11.txt_name = viewNode:getChildAutoType('group_11/txt_name')--GTextField
		self.group_11.txt_stage = viewNode:getChildAutoType('group_11/txt_stage')--GTextField
	self.group_12 = viewNode:getChildAutoType('group_12')--com_guildGroup
		self.group_12.btn_video = viewNode:getChildAutoType('group_12/btn_video')--btn_data
			self.group_12.btn_video.img_red = viewNode:getChildAutoType('group_12/btn_video/img_red')--GImage
		self.group_12.heroCell = viewNode:getChildAutoType('group_12/heroCell')--GButton
		self.group_12.txt_name = viewNode:getChildAutoType('group_12/txt_name')--GTextField
		self.group_12.txt_stage = viewNode:getChildAutoType('group_12/txt_stage')--GTextField
	self.group_13 = viewNode:getChildAutoType('group_13')--com_guildGroup
		self.group_13.btn_video = viewNode:getChildAutoType('group_13/btn_video')--btn_data
			self.group_13.btn_video.img_red = viewNode:getChildAutoType('group_13/btn_video/img_red')--GImage
		self.group_13.heroCell = viewNode:getChildAutoType('group_13/heroCell')--GButton
		self.group_13.txt_name = viewNode:getChildAutoType('group_13/txt_name')--GTextField
		self.group_13.txt_stage = viewNode:getChildAutoType('group_13/txt_stage')--GTextField
	self.group_14 = viewNode:getChildAutoType('group_14')--com_guildGroup
		self.group_14.btn_video = viewNode:getChildAutoType('group_14/btn_video')--btn_data
			self.group_14.btn_video.img_red = viewNode:getChildAutoType('group_14/btn_video/img_red')--GImage
		self.group_14.heroCell = viewNode:getChildAutoType('group_14/heroCell')--GButton
		self.group_14.txt_name = viewNode:getChildAutoType('group_14/txt_name')--GTextField
		self.group_14.txt_stage = viewNode:getChildAutoType('group_14/txt_stage')--GTextField
	self.group_15 = viewNode:getChildAutoType('group_15')--com_guildGroup
		self.group_15.btn_video = viewNode:getChildAutoType('group_15/btn_video')--btn_data
			self.group_15.btn_video.img_red = viewNode:getChildAutoType('group_15/btn_video/img_red')--GImage
		self.group_15.heroCell = viewNode:getChildAutoType('group_15/heroCell')--GButton
		self.group_15.txt_name = viewNode:getChildAutoType('group_15/txt_name')--GTextField
		self.group_15.txt_stage = viewNode:getChildAutoType('group_15/txt_stage')--GTextField
	self.group_2 = viewNode:getChildAutoType('group_2')--com_guildGroup
		self.group_2.btn_video = viewNode:getChildAutoType('group_2/btn_video')--btn_data
			self.group_2.btn_video.img_red = viewNode:getChildAutoType('group_2/btn_video/img_red')--GImage
		self.group_2.heroCell = viewNode:getChildAutoType('group_2/heroCell')--GButton
		self.group_2.txt_name = viewNode:getChildAutoType('group_2/txt_name')--GTextField
		self.group_2.txt_stage = viewNode:getChildAutoType('group_2/txt_stage')--GTextField
	self.group_3 = viewNode:getChildAutoType('group_3')--com_guildGroup
		self.group_3.btn_video = viewNode:getChildAutoType('group_3/btn_video')--btn_data
			self.group_3.btn_video.img_red = viewNode:getChildAutoType('group_3/btn_video/img_red')--GImage
		self.group_3.heroCell = viewNode:getChildAutoType('group_3/heroCell')--GButton
		self.group_3.txt_name = viewNode:getChildAutoType('group_3/txt_name')--GTextField
		self.group_3.txt_stage = viewNode:getChildAutoType('group_3/txt_stage')--GTextField
	self.group_4 = viewNode:getChildAutoType('group_4')--com_guildGroup
		self.group_4.btn_video = viewNode:getChildAutoType('group_4/btn_video')--btn_data
			self.group_4.btn_video.img_red = viewNode:getChildAutoType('group_4/btn_video/img_red')--GImage
		self.group_4.heroCell = viewNode:getChildAutoType('group_4/heroCell')--GButton
		self.group_4.txt_name = viewNode:getChildAutoType('group_4/txt_name')--GTextField
		self.group_4.txt_stage = viewNode:getChildAutoType('group_4/txt_stage')--GTextField
	self.group_5 = viewNode:getChildAutoType('group_5')--com_guildGroup
		self.group_5.btn_video = viewNode:getChildAutoType('group_5/btn_video')--btn_data
			self.group_5.btn_video.img_red = viewNode:getChildAutoType('group_5/btn_video/img_red')--GImage
		self.group_5.heroCell = viewNode:getChildAutoType('group_5/heroCell')--GButton
		self.group_5.txt_name = viewNode:getChildAutoType('group_5/txt_name')--GTextField
		self.group_5.txt_stage = viewNode:getChildAutoType('group_5/txt_stage')--GTextField
	self.group_6 = viewNode:getChildAutoType('group_6')--com_guildGroup
		self.group_6.btn_video = viewNode:getChildAutoType('group_6/btn_video')--btn_data
			self.group_6.btn_video.img_red = viewNode:getChildAutoType('group_6/btn_video/img_red')--GImage
		self.group_6.heroCell = viewNode:getChildAutoType('group_6/heroCell')--GButton
		self.group_6.txt_name = viewNode:getChildAutoType('group_6/txt_name')--GTextField
		self.group_6.txt_stage = viewNode:getChildAutoType('group_6/txt_stage')--GTextField
	self.group_7 = viewNode:getChildAutoType('group_7')--com_guildGroup
		self.group_7.btn_video = viewNode:getChildAutoType('group_7/btn_video')--btn_data
			self.group_7.btn_video.img_red = viewNode:getChildAutoType('group_7/btn_video/img_red')--GImage
		self.group_7.heroCell = viewNode:getChildAutoType('group_7/heroCell')--GButton
		self.group_7.txt_name = viewNode:getChildAutoType('group_7/txt_name')--GTextField
		self.group_7.txt_stage = viewNode:getChildAutoType('group_7/txt_stage')--GTextField
	self.group_8 = viewNode:getChildAutoType('group_8')--com_guildGroup
		self.group_8.btn_video = viewNode:getChildAutoType('group_8/btn_video')--btn_data
			self.group_8.btn_video.img_red = viewNode:getChildAutoType('group_8/btn_video/img_red')--GImage
		self.group_8.heroCell = viewNode:getChildAutoType('group_8/heroCell')--GButton
		self.group_8.txt_name = viewNode:getChildAutoType('group_8/txt_name')--GTextField
		self.group_8.txt_stage = viewNode:getChildAutoType('group_8/txt_stage')--GTextField
	self.group_9 = viewNode:getChildAutoType('group_9')--com_guildGroup
		self.group_9.btn_video = viewNode:getChildAutoType('group_9/btn_video')--btn_data
			self.group_9.btn_video.img_red = viewNode:getChildAutoType('group_9/btn_video/img_red')--GImage
		self.group_9.heroCell = viewNode:getChildAutoType('group_9/heroCell')--GButton
		self.group_9.txt_name = viewNode:getChildAutoType('group_9/txt_name')--GTextField
		self.group_9.txt_stage = viewNode:getChildAutoType('group_9/txt_stage')--GTextField
	self.line_1 = viewNode:getChildAutoType('line_1')--com_line1
		self.line_1.spine = viewNode:getChildAutoType('line_1/spine')--GLoader
	self.line_2 = viewNode:getChildAutoType('line_2')--com_line1
		self.line_2.spine = viewNode:getChildAutoType('line_2/spine')--GLoader
	self.line_3 = viewNode:getChildAutoType('line_3')--com_line1
		self.line_3.spine = viewNode:getChildAutoType('line_3/spine')--GLoader
	self.line_4 = viewNode:getChildAutoType('line_4')--com_line1
		self.line_4.spine = viewNode:getChildAutoType('line_4/spine')--GLoader
	self.line_5 = viewNode:getChildAutoType('line_5')--com_line3
		self.line_5.spine1 = viewNode:getChildAutoType('line_5/spine1')--GLoader
		self.line_5.spine2 = viewNode:getChildAutoType('line_5/spine2')--GLoader
	self.line_6 = viewNode:getChildAutoType('line_6')--com_line3
		self.line_6.spine1 = viewNode:getChildAutoType('line_6/spine1')--GLoader
		self.line_6.spine2 = viewNode:getChildAutoType('line_6/spine2')--GLoader
	self.line_7 = viewNode:getChildAutoType('line_7')--com_line2
		self.line_7.spine1 = viewNode:getChildAutoType('line_7/spine1')--GLoader
		self.line_7.spine2 = viewNode:getChildAutoType('line_7/spine2')--GLoader
	self.matchType = viewNode:getController('matchType')--Controller
	self.stage = viewNode:getChildAutoType('stage')--GLoader
	self.txt_timer = viewNode:getChildAutoType('txt_timer')--GTextField
	self.txt_timerTitle = viewNode:getChildAutoType('txt_timerTitle')--GTextField
	self.wing = viewNode:getChildAutoType('wing')--GLoader
	--{autoFieldsEnd}:CrossLaddersChamp.CrossLaddersChampGroupView
	--Do not modify above code-------------
end

function CrossLaddersChampGroupView:_initListener( )
	-- 左切
	self.btn_left:addClickListener(function()
		self:changeBtnChose(0);
	end)
	-- 右切
	self.btn_right:addClickListener(function()
		self:changeBtnChose(1);
	end)
	-- 晋级赛
	self.btn_match1:addClickListener(function()
		if self.pageIndex == 0 then
			return
		end
		self.pageIndex = 0
		self.showGroup = self.curGroup;
		self:upPosInfo();
		self:CrossLaddersChampGroupView_refreshPanel()
	end)
	-- 冠军赛
	self.btn_match2:addClickListener(function()
		if not CrossLaddersChampModel:isChampion() and (not CrossLaddersChampModel:isEnd()) then
			RollTips.show(Desc.GLOL_str11);
			self.btn_match1:setSelected(true);
			return;
		end
		if self.pageIndex == 1 then
			return
		end

		self.pageIndex = 1
		self.showGroup = 1;
		self:upPosInfo();
		self:CrossLaddersChampGroupView_refreshPanel()
	end)


	self.btn_halloffame:addClickListener(function()
		ModuleUtil.openModule(ModuleId.Chat.id , true)
	end)


end

function CrossLaddersChampGroupView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:setBg("worldchallengeMian1.png")
	self:initSpine()
	-- self:GLOL_MatchInfoUpdate();
	self:showBtnChose()
	if CrossLaddersChampModel:isChampion() or CrossLaddersChampModel:isEnd() then
		self.matchType:setSelectedIndex(1)
	end
	self:CrossLaddersChampGroupView_refreshPanel()
end

function CrossLaddersChampGroupView:CrossLaddersChampGroupView_refreshPanel()
	-- self.matchType:setSelectedIndex(CrossLaddersChampModel:isChampion() and 1 or 0)
	local stage = (self.matchType:getSelectedIndex() == 0) and GameDef.SkyLadChampionStage.Top64 or GameDef.SkyLadChampionStage.Top8
	self:updateCountDown()
	-- if (self.matchType:getSelectedIndex() + 1 == 1) and CrossLaddersChampModel:isChampion() then
	-- 	return
	-- end
	self:upMatchInfo()
	self:upLineInfo();
	CrossLaddersChampModel:reqSkyLadChampion_GetGroupInfo(stage,function() 
		self.allGroupInfo 	= CrossLaddersChampModel.allGroupInfo 	-- 所有分组的信息
		print(8849,">>>>>>>>>self.showGroup>>>" .. self.showGroup)
		self.curGroupInfo 	= self.allGroupInfo[self.showGroup] or {}
		if self.curGroupInfo and self.curGroupInfo.nodeId then
			CrossLaddersChampModel:reqSkyLadChampion_GetNodeInfo(self.curGroupInfo.nodeId,function()
				self:setGroupInfo()
			end,false,(self.matchType:getSelectedIndex()+1))
		else
			self:setGroupInfo()
		end
	end,(self.matchType:getSelectedIndex()+1))
end



function CrossLaddersChampGroupView:initSpine()
	for key=1,7 do
		local line = self["line_"..key];
		self.spineMap[key] = {}
		if (key == 7) then
			for i = 1, 2 do
				local spine = line["spine"..i];
				local animation = SpineUtil.createSpineObj(spine,{x = 0, y = 0},"ui_lianxian2_1_loop","Effect/UI","efx_sijieleitaisai","efx_sijieleitaisai",true)
				table.insert(self.spineMap[key], animation);
			end
		elseif key == 5 or key == 6 then
			for i = 1, 2 do
				local spine = line["spine"..i];
				local animation = SpineUtil.createSpineObj(spine,{x = 0, y = 0},"ui_lianxian4_1_loop","Spine/ui/GuildLeague","efx_sijieleitaisai","efx_sijieleitaisai",true)
				table.insert(self.spineMap[key], animation);
			end
		else
			local spine = line.spine;
			local animation = SpineUtil.createSpineObj(spine,{x = 0, y = 0},"ui_lianxian8_1_loop","Effect/UI","efx_sijieleitaisai","efx_sijieleitaisai",true)
			table.insert(self.spineMap[key], animation);
		end
		if (self.spineMap[key]) then
			for _, anim in ipairs(self.spineMap[key]) do
				anim:setVisible(false);
			end
		end
	end
end

function CrossLaddersChampGroupView:showLineSpine()
	local pageIndex = self.matchType:getSelectedIndex()+1
	for key,spine in pairs(self.spineMap) do
		local state =  CrossLaddersChampModel.lineEffectState[pageIndex][key]
		if (self.spineMap[key]) then
			for _, anim in ipairs(self.spineMap[key]) do
				anim:setVisible(state);
			end
		end
	end
end

-- 竞猜部分按钮
function CrossLaddersChampGroupView:changeBtnStatus()
	local myGroupInfo 	= CrossLaddersChampModel.myGroupInfo

	printTable(8850,">>>self.curGroupInfo.nodeId>>",myGroupInfo)
	if CrossLaddersChampModel:isSecond2() then
		if myGroupInfo[1] and myGroupInfo[1].nodeId then
			CrossLaddersChampModel:reqSkyLadChampion_GetNodeInfo(myGroupInfo[1].nodeId,function()
				
				self.btn_mymatch:setVisible( myGroupInfo[1].groupId and CrossLaddersChampModel:checkShowMyMatch((self.matchType:getSelectedIndex()+1)))
			end,true,(self.matchType:getSelectedIndex()+1))
		else
			self.btn_mymatch:setVisible(false)
		end
	elseif CrossLaddersChampModel:isChampion() then
		if myGroupInfo[1] and myGroupInfo[1].nodeId and myGroupInfo[2] and myGroupInfo[2].nodeId then
			CrossLaddersChampModel:reqSkyLadChampion_GetNodeInfo(myGroupInfo[2].nodeId,function()
				self.btn_mymatch:setVisible( myGroupInfo[2].groupId and CrossLaddersChampModel:checkShowMyMatch((self.matchType:getSelectedIndex()+1)))
			end,true,(self.matchType:getSelectedIndex()+1))
		else
			self.btn_mymatch:setVisible(false)
		end
	else
		self.btn_mymatch:setVisible(false)
	end

	-- local guessShow = true
	self.btn_guess:setVisible(CrossLaddersChampModel:isSecond())
end


-- 更新位置信息
function CrossLaddersChampGroupView:upPosInfo()
	
	self:upMatchInfo();
end

-- 
function CrossLaddersChampGroupView:setBtn()
	-- 打开竞猜界面
	self.btn_guess:getChildAutoType("img_red"):setVisible(CrossLaddersChampModel:checkCanQuiz())
	self.btn_guess:removeClickListener(11)
	self.btn_guess:addClickListener(function()
		if CrossLaddersChampModel:isEnd() then
			RollTips.show(Desc.CrossLaddersChamp_str31)
			return
		end
		ViewManager.open("CrossLaddersChampQuizView")
	end,11)

	-- 打开我的调整阵容界面
	self.btn_mymatch:getChildAutoType("img_red"):setVisible(CrossLaddersChampModel:checkCanArray(2))
	self.btn_mymatch:removeClickListener(11)
	self.btn_mymatch:addClickListener(function()
		ViewManager.open("CrossLaddersChampQuizView",{enterType = 2,pageIndex = (self.matchType:getSelectedIndex()+1)})
	end,11)
end


-- 设置每个位置的信息
function CrossLaddersChampGroupView:setGroupInfo()
	self:showLineSpine()
	self:changeBtnStatus()
	self:setBtn()
	local curGroupInfo 	= {} 	-- 当前阶段的分组信息
	self.nodeInfo = {}
	self.nodeInfo 	= CrossLaddersChampModel.nodeInfo
	local winPlayerId =  false 
	if self.nodeInfo[15] and self.nodeInfo[15].playerId then
		winPlayerId = self.nodeInfo[15].playerId
	end
	local pageIndex = self.matchType:getSelectedIndex() +1
	for i = 1,15 do
		local data	= self.nodeInfo[i]
		local obj 	= self["group_"..i]
		local isHaveCtrl 	= obj:getController("isHaveCtrl") 	-- 0没人 1有人
		local isOutCtrl 	= obj:getController("isOutCtrl") 	-- 0赢了 1输了
		local isVideoCtrl 	= obj:getController("isVideoCtrl") 	-- 0没录像 1有录像
		local heroCell 	= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local txt_name 	= obj:getChildAutoType("txt_name")
		local btn_video 	= obj:getChildAutoType("btn_video")
		local txt_stage 	= obj:getChildAutoType("txt_stage")
		
		if __showStage[pageIndex][i] ~= 1 then
			txt_stage:setText(string.format(Desc.CrossLaddersChamp_str37,__showStage[pageIndex][i]))
		else
			txt_stage:setText(Desc.CrossLaddersChamp_str38)
		end
		local stage 	= CrossLaddersChampModel.stage
		isOutCtrl:setSelectedIndex(0)
		local limitPos = __stageShowFlag[stage]
		local currentLineIndex = _stageToLine[stage]
		if pageIndex == 1 and CrossLaddersChampModel:isChampion() then
			limitPos = 15
		end
		if pageIndex == 2 and CrossLaddersChampModel:isEnd() then
			limitPos = 15
		end
		local oldStage =  __posToStage[pageIndex][i]
		if (data and data.playerId) and (limitPos and i <= limitPos) then
			local lineStatus = CrossLaddersChampModel.lineEffectState[pageIndex][currentLineIndex]
			local showPos 	= __lineToPos[currentLineIndex]

			self:getLineObj(data.pos,data)
			isVideoCtrl:setSelectedIndex(data.recordId and 1 or 0)
			isHaveCtrl:setSelectedIndex(1)
			heroCell:setHead(data.head, data.level, data.playerId,nil,data.headBorder)
			if data.have then
				if lineStatus then
					if i <= showPos then
						isOutCtrl:setSelectedIndex((data.winState) and 0 or 1)
						if data.isGray then
							if stage >= oldStage then
								isOutCtrl:setSelectedIndex(1)
							end
						end
					else
						isOutCtrl:setSelectedIndex(0)
					end
				end
				if CrossLaddersChampModel.stage >= GameDef.SkyLadChampionStage.Top8 and (pageIndex == 1) then
					isOutCtrl:setSelectedIndex((data.winState) and 0 or 1)
					if data.isGray then
						isOutCtrl:setSelectedIndex(1)
					end
					if data.playerId ~= winPlayerId then
						isOutCtrl:setSelectedIndex(1)
					end
				end

				if CrossLaddersChampModel:isEnd() then
					isOutCtrl:setSelectedIndex((data.winState) and 0 or 1)
					if data.isGray then
						isOutCtrl:setSelectedIndex(1)
					end
					if data.playerId ~= winPlayerId then
						isOutCtrl:setSelectedIndex(1)
					end
				end
			else
				isOutCtrl:setSelectedIndex(0)
			end
			txt_name:setText(data.name)
			btn_video:removeClickListener(11)
			btn_video:addClickListener(function()
				ModelManager.BattleModel:requestBattleRecord(data.recordId)
			end,11)
		else
			isOutCtrl:setSelectedIndex(1)
			isHaveCtrl:setSelectedIndex(0)
		end
	end

end


function CrossLaddersChampGroupView:upLineInfo()
	for i=1, 7  do
		local line = self["line_"..i];
		line:setMax(100);
		local img = line:getChildAutoType("bar")
		line:setValue(0)
	end
end

function CrossLaddersChampGroupView:getLineObj(pos,data)
	local keyMap = {
		[1] = 54, 	-- 1 2 9
		[2] = 54, 	-- 3 4 10
		[3] = 54, 	-- 5 6 11
		[4] = 54, 	-- 7 8 12
		[5] = 51, 	-- 9 10 13
		[6] = 51, 	-- 11 12 14
		[7] = 51 	-- 13 14 15
	}
	for k,v in pairs (__checkWinGroup) do
		local nodeData  = CrossLaddersChampModel.nodeInfo
		local leftPlayer    = nodeData[v[1]]
		local rightPlayer   = nodeData[v[2]]
		local winPlayer     = nodeData[v[3]]
		if (v[1] == pos) or (v[2] == pos) then
			local line = self["line_"..k];
			local img_bar = line:getChildAutoType("bar")
			-- img_bar:setFillOrigin(1)
			if winPlayer and winPlayer.playerId then
				if (line:getScaleY() == -1) then
					if data.winState then
						if  (data.playerId == leftPlayer.playerId) then -- 上面赢了
							img_bar:setFillOrigin(1)
							if k == 4 or k==2 then
								keyMap[k] = 50
							end
						else
							img_bar:setFillOrigin(0)
						end
					end
				else
					if data.winState then 
						if  (data.playerId == leftPlayer.playerId) then -- 上面赢了
							img_bar:setFillOrigin(0)
						else
							img_bar:setFillOrigin(1)
							if k == 1 or k ==3 then
								keyMap[k] = 50
							end
						end
					end
				end
				if data.winState then
					local lineShow,isEnd = CrossLaddersChampModel:getLineIndex(self.matchType:getSelectedIndex()+1)
					printTable(8850,">>>>lineShow>>>" .. lineShow)
					if isEnd then
						if k <= lineShow and lineShow ~= 1 then
							line:setValue(keyMap[k])
						end
					else
						if k < lineShow and lineShow ~= 1 then
							line:setValue(keyMap[k])
						end
					end

				end
			else
				line:setValue(0);
			end
		end
	end
end

-- 更新阶段信息
function CrossLaddersChampGroupView:upMatchInfo()
	local statusInfo	= CrossLaddersChampModel.statusInfo
	local stage 	= statusInfo.stage or GameDef.SkyLadChampionStage.End
	local status 	= statusInfo.status or GameDef.SkyLadChampionStatus.Pre
	local matchRound = __matchRound[stage]; -- 1、64强  2、32强  3、16强  4、8强 5、4强 6、2强、7、活动结束
	local roundState = status ; -- 1、准备阶段  2、战斗阶段  3、结算阶段
	-- self.txt_stage:setText("testLog:"..(Desc["GLOL_round"..matchRound] or ""))
	if (matchRound) then
		local map = {32, 16, 8, 4, 2, 1, 1}
		self.stage:setIcon(string.format("UI/WorldChallenge/worldchallengeyisuzi%s.png", map[matchRound]))
	else
		self.stage:setIcon("")
	end
end

-- 底部分组
function CrossLaddersChampGroupView:changeBtnChose(type)
	local flag = type == 0 and -1 or 1
	local curSelected = self:limitBtnNum(self.curGroup + flag)
	self.curGroup = curSelected
	if (not TableUtil.Exist(self.groupIndexMap, curSelected)) then
		local next1 = self:limitBtnNum(curSelected - flag)
		local next2 = self:limitBtnNum(curSelected - 2 * flag)
		if (type == 0) then
			self.groupIndexMap = {curSelected, next1, next2}
		else
			self.groupIndexMap = {next2, next1, curSelected}
		end
	end
	self.showGroup = self.curGroup;
	self:showBtnChose();
end

-- 分组数字限制
function CrossLaddersChampGroupView:limitBtnNum(num)
    local result = (num + 8) % 8
    return result == 0 and 8 or result
end

-- 底部分组按钮
function CrossLaddersChampGroupView:showBtnChose()
	if (not self.groupIndexMap) then
		local next1 = self:limitBtnNum(self.curGroup - 1)
        local next2 = self:limitBtnNum(self.curGroup + 1)
        self.groupIndexMap = {next1, self.curGroup, next2}
	end
	for i = 1, 3 do
		local btn = self["btn_choose"..i];
		local index = self.groupIndexMap[i]
		btn:setTitle(string.format(Desc.WorldChallenge_str8, index));
		-- local showGroup = self.showGroup == 0 and self.curGroup or self.showGroup;
		btn:setSelected(index == self.curGroup)
		local c1 = btn:getController("c1");
		if (index == GuildLeagueOfLegendsModel.guessGroup) then  -- GuildLeagueOfLegendsModel.guessGroup 竞猜的组
			c1:setSelectedIndex(1);
		else
			c1:setSelectedIndex(0);
		end
		btn:removeClickListener();
		btn:addClickListener(function()
			self.showGroup = index;
			self.curGroup = index;
			self:showBtnChose();
		end)
	end
	self:CrossLaddersChampGroupView_refreshPanel()
end

function CrossLaddersChampGroupView:updateCountDown()
	local stopTimes = math.floor(CrossLaddersChampModel.curEndTimeMs/1000)
	local serverTime 	= ServerTimeModel:getServerTime()
	stopTimes = stopTimes - serverTime
	if stopTimes > 0 then
		stopTimes = stopTimes +1
		local titleStr = ""
		if not tolua.isnull(self.txt_timerTitle) then
			titleStr = Desc["CrossLaddersChamp_status"..CrossLaddersChampModel.status]
			self.txt_timerTitle:setText(titleStr)
		end
		if not tolua.isnull(self.txt_timer) then
			self.txt_timer:setText(TimeLib.GetTimeFormatDay(stopTimes,2))
		end
		local function onCountDown(dt)
			stopTimes = stopTimes - dt
			if stopTimes <= 0 then
				stopTimes = 0
			end
			if not tolua.isnull(self.txt_timerTitle) then
				titleStr = Desc["CrossLaddersChamp_status"..CrossLaddersChampModel.status]
				self.txt_timerTitle:setText(titleStr)
			end
			if not tolua.isnull(self.txt_timer) then
				self.txt_timer:setText(TimeLib.GetTimeFormatDay(math.floor(stopTimes,2)))
			end
		end
		if self.timer then
			Scheduler.unschedule(self.timer)
			self.timer = false
		end
		self.timer = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.01)
	else
		if self.timer then
			Scheduler.unschedule(self.timer)
			self.timer = false
		end
		self.txt_timer:setText("")
		self.txt_timerTitle:setText(Desc.CrossLaddersChamp_statusEnd)
	end
end


function CrossLaddersChampGroupView:_exit()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
	CrossLaddersChampModel.nodeInfo = {}
	if self._args.entranType then
		ModuleUtil.openModule(ModuleId.CrossLaddersChamp.id, true,{pageIndex = 2})
	end
end



return CrossLaddersChampGroupView