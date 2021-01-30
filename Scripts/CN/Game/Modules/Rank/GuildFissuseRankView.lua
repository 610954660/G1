--added by wyang 排行榜窗口
local GuildFissuseRankView,Super = class("GuildFissuseRankView",Window)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local wzNumCount = 30
function GuildFissuseRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "GuildFissuseRankView"
	-- self._rootDepth = LayerDepth.PopWindow
	self.rankData = false
	self.wzData =false
	self.rollIndex = 0   -- 列表滚动到指定位置	
end


function GuildFissuseRankView:_initUI( )
   self.closeBtn = self.view:getChildAutoType("closeBtn")
   self.list_rank = self.view:getChildAutoType("list_rank")
   self.dwLoader = self.view:getChildAutoType("dwLoader")
   self.txt_name = self.view:getChildAutoType("txt_name")
   self.txt_attr1 = self.view:getChildAutoType("txt_attr1")
   self.headItem = self.view:getChildAutoType("headItem")
   self.dwtxt = self.view:getChildAutoType("dwtxt")
   self.btn_record = self.view:getChildAutoType("btn_record")
   self.noDataCtrl = self.view:getController("noDataCtrl")
   self.hadRankCtrl = self.view:getController("hadRankCtrl")

end

--事件初始化
function GuildFissuseRankView:_initEvent( ... )
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(function(index,obj)
		local tempIndex = index+ 1
		local typeCtrl = obj:getController("typeCtrl")
		local c1Ctrl = obj:getController("c1")
		local bgCtrl 	= obj:getController("bgCtrl")
		bgCtrl:setSelectedIndex(tempIndex <= 30 and 0 or 1)
		-- c1Ctrl:setSelectedIndex(4)
		local dwLoader =obj:getChildAutoType("dwLoader")
		local txt_rank = obj:getChildAutoType("txt_rank")
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_attr1 = obj:getChildAutoType("txt_attr1")
		local headItem = obj:getChildAutoType("headItem")
		local btn_record = obj:getChildAutoType("btn_record")
		local btn_viewInfo = obj:getChildAutoType("btn_viewInfo")
		local btn_look = obj:getChildAutoType("btn_look")
		local dwtxt = obj:getChildAutoType("dwtxt")
		local dwothertxt = obj:getChildAutoType("dwothertxt")
		local txtPlayerNum = obj:getChildAutoType("txtPlayerNum")
		local txt_hurt	= obj:getChildAutoType("txt_hurt")
		local txt_num	= obj:getChildAutoType("txt_num")
		local playerList = obj:getChildAutoType("playerList")
		txt_rank:setVisible(false)
		if tempIndex <= 3 then
			c1Ctrl:setSelectedIndex(tempIndex)
		elseif tempIndex <= 30 then
			c1Ctrl:setSelectedIndex(4)
			txt_rank:setVisible(true)
			txt_rank:setText(tempIndex)
		else
			c1Ctrl:setSelectedIndex(0)
		end

		if tempIndex <= 30 then
			obj:setSize(1224, 130)
		else
			obj:setSize(1224, 144)
		end
		
		btn_viewInfo:removeClickListener(100)

		if tempIndex<=wzNumCount then --固定显示王者
           if self.wzData[tempIndex] and self.wzData[tempIndex].id then --这个位置有王者
           	   -- printTable(1,self.wzData[tempIndex])
               typeCtrl:setSelectedIndex(0)
               local url = PathConfiger.getBossDw(1)
               dwLoader:setURL(url)
               txt_name:setText(self.wzData[tempIndex].name)
               txt_attr1:setText(self.wzData[tempIndex].value)
               	local hero = BindManager.bindPlayerCell(headItem)
	            hero:setHead(self.wzData[tempIndex].head, self.wzData[tempIndex].level,self.wzData[tempIndex].id,nil,self.wzData[tempIndex].headBorder)
		        btn_record:removeClickListener(100)
				btn_record:addClickListener(
					function(...)
						BattleModel:requestBattleRecord(self.wzData[tempIndex].battleId)
					end,100)
				local rankConfig = GuildModel:getBossRankConfigByIndexs(1,tempIndex )
			    -- dwtxt:setText(rankConfig.rankName)
			    dwtxt:setText(PathConfiger.getDwtxt(tempIndex))
                txtPlayerNum:setText("")
                txt_hurt:setText("")
                txt_num:setText("")
				btn_viewInfo:addClickListener(
				function(...)
					ViewManager.open("ViewPlayerView",{playerId = self.wzData[tempIndex].id,serverId = self.wzData[tempIndex].serverId })
				end,100)
           else
               typeCtrl:setSelectedIndex(1)
           end
		else
			--其他段位
			local rankIndex = tempIndex -  wzNumCount + 1
			local url = PathConfiger.getBossDw(rankIndex)
			dwLoader:setURL(url)
			local rankConfig = GuildModel:getBossRankConfigByIndexs(1,rankIndex )
			-- dwtxt:setText(rankConfig.rankName)
			dwothertxt:setText(PathConfiger.getDwtxt(tempIndex))
		    if self.rankData.rankLevelData[rankIndex] then --段位有人
		    	typeCtrl:setSelectedIndex(2)
		       local data = self.rankData.rankLevelData[rankIndex].rankData
               -- local fightVal = data. --这里输出达到多少呢??
               -- printTable(1,self.rankData.rankLevelData[rankIndex])
               -- txtPlayerNum:setText(string.format("共{count=%d}人,输出达到{fightVal=%d}可晋升",self.rankData.rankLevelData[rankIndex].totalNum,self.rankData.rankLevelData[rankIndex].nextRankDamage))
               txt_num:setText(self.rankData.rankLevelData[rankIndex].totalNum)
               txt_hurt:setText(self.rankData.rankLevelData[rankIndex].nextRankDamage)
			   playerList:setItemRenderer(function( p_index,obj )
					local haveHeroCtrl = obj:getController("haveHeroCtrl")
					if  (p_index+1) <= self.rankData.rankLevelData[rankIndex].totalNum then
						haveHeroCtrl:setSelectedIndex(0)
						local headItem = obj:getChildAutoType("heroCell")
						local hero = BindManager.bindPlayerCell(headItem)
						hero:setHead(data[p_index+1].head,data[p_index+1].level,data[p_index+1].id,nil,data[p_index+1].headBorder)
		            	obj:removeClickListener(100)   --移除通用处理添加的监听 
						headItem:removeClickListener(100)
						headItem:addClickListener(
							 	function(...)

							 		ViewManager.open("ViewPlayerView",{playerId = data[p_index+1].id})
									
							 	end,100
							 )
					else
						haveHeroCtrl:setSelectedIndex(1)
					end
               	end)
				  -- playerList:setData(data)	 --段位没人
				  playerList:setNumItems(5) 	--固定显示五个
		    	-- typeCtrl:setSelectedIndex(self.rankData.rankLevelData[rankIndex].totalNum>0 and 2 or 3)
		    	btn_look:removeClickListener(100)
				btn_look:addClickListener(
				function(...)
					printTable(8848,"数据署",self.rankData.rankLevelData[rankIndex])
					ViewManager.open("GuildFissuseTipRankView",{rankIndex=rankIndex,data =self.rankData.rankLevelData[rankIndex] })
				end,100)
		    end
		end
	end)
	--获取公会跨服BOSS排行榜数据
	local params = {}
    params.onSuccess = function (res )
        -- printTable(1,"服务器返回公会跨服Boss排行榜数据",res)
        GuildModel:setCylfBossRankData( res )
        self:updatePanel()
    end
    RPCReq.Rank_GetGuildWorldBossRankData(params, params.onSuccess)
end

function GuildFissuseRankView:updatePanel(  )
	self.rankData = GuildModel:getCylfBossRankData( )
	self.rollIndex = self:getRankRollIndex()
	local flag = false
	for k,v in pairs(self.rankData.rankLevelData) do
		flag = true
		break
	end

	if not flag then
		self.noDataCtrl:setSelectedIndex(1)
		return
	else
		self.noDataCtrl:setSelectedIndex(0)
		self.wzData = self:makeKingData()
		--printTable(8848,"self.wzData",self.wzData)
		local count = self:getRankDataCount()
		self.list_rank:setNumItems(count) --self.rollIndex-1
		self.list_rank:scrollToView(self.rollIndex-1,true,true)
	
		self:showMyRankView()
	end
end

function GuildFissuseRankView:getRankRollIndex()
	local myRankData = self.rankData.myRankData
	local inRank = false
	local myRankLevel = myRankData.extraData.guildWorldBoss.rankLevel or 0

	-- 判断自己在没在榜上 如果有段位 没在 则插进去
	for k,v in pairs(self.rankData.rankLevelData) do
		if myRankLevel ~= 0 and myRankLevel ~= 1 and myRankLevel == k then
			for o,p in pairs(v.rankData) do
				if p.id == myRankData.id then
					inRank = true
					break
				end
			end
			if not inRank then
				-- v.totalNum = v.totalNum + 1
				for o,p in pairs(v.rankData) do
					if o == 5 then
						table.remove(v.rankData,o)
						break
					end
				end
				table.insert(v.rankData,myRankData)
				break
			end
		end
	end

	-- 获取自己在榜上的位置
	local rankLevelData = self.rankData.rankLevelData
	local isFind = false
	for k,v in pairs(rankLevelData) do
		if v.totalNum>0 then
			for o,p in pairs(v.rankData) do
				if p.id == myRankData.id then
					isFind = true
					if v.rankLevel == 1 then
						return o
					else
						return v.rankLevel + 29
					end
				end
			end
		end
	end
	if not isFind then return 1 end
end


function GuildFissuseRankView:getRankDataCount( ... )
	local count = 0
	for k,v in pairs(DynamicConfigData.t_GuildWorldBossRankConfig[1]) do
	 	count = count + 1
	end 
	return count + wzNumCount - 1
end


function GuildFissuseRankView:makeKingData( )
	local data = {}
	if not self.rankData.rankLevelData[1] then
		--没有王者
		for i=1,wzNumCount do
			table.insert(data,{})
		end
	else
	    --有王者
	    local wzData = self.rankData.rankLevelData[1]
	    if wzData.rankLevel == 1 then
	    	for i,v in ipairs(wzData.rankData) do
	    		table.insert(data,v)
	    	end

	    	local lastCount = wzNumCount - #wzData.rankData
	    	for i=lastCount,wzNumCount do
	    		table.insert(data,{})
	    	end
	    end
	end
	-- printTable(1,"王者的数据",data)
	return data
end

function GuildFissuseRankView:showMyRankView( )
	local myRankData = self.rankData.myRankData
	printTable(8848,"myRankData>>>>>>",myRankData)
	local rankLevel = myRankData.extraData.guildWorldBoss.rankLevel
	local txt_rank 	= self.view:getChildAutoType("txt_rank")
	local rankLvCtrl = self.view:getController("rankLvCtrl")
	if myRankData.value<=0 or rankLevel<=0 then --未上榜
		self.hadRankCtrl:setSelectedIndex(1)
		rankLvCtrl:setSelectedIndex(1)
		txt_rank:setVisible(false)
	else
		-- txt_rank:setText("第"..rankLevel.."名")
		self.hadRankCtrl:setSelectedIndex(0)
		rankLvCtrl:setSelectedIndex(rankLevel >=1 and 0 or 1)
		local url = PathConfiger.getBossDw(rankLevel)
	    self.dwLoader:setURL(url)
	    local rankConfig = GuildModel:getBossRankConfigByIndexs(1,rankLevel )
        self.dwtxt:setText(PathConfiger.getDwtxt(rankLevel+29))
	end
	self.txt_name:setText(myRankData.name)
	self.txt_attr1:setText(myRankData.value)

    self.headItem:setVisible(true)
	local hero = BindManager.bindPlayerCell(self.headItem)
	hero:setHead(myRankData.head, myRankData.level,nil,nil,myRankData.headBorder)

	self.btn_record:removeClickListener(100)
	self.btn_record:addClickListener(
		function(...)
			if myRankData.value<=0 or rankLevel<=0 then --未上榜
				RollTips.show(Desc.Guild_Text14)
				return
			end
			local data = {}
			data.battleId = myRankData.battleId
			data.gamePlayType = GameDef.GamePlayType.GuildWorldBoss
			data.serverId = myRankData.serverId
			BattleModel:requestBattleRecord(data.battleId,nil,data.gamePlayType,data.serverId)
			-- BattleModel:requestBattleRecord(myRankData.battleId)
		end,100)
end

--initEvent后执行
function GuildFissuseRankView:_enter( ... )
	print(1,"GuildFissuseRankView _enter")
end


--页面退出时执行
function GuildFissuseRankView:_exit( ... )

	print(1,"GuildFissuseRankView _exit")
end

-------------------常用------------------------

return GuildFissuseRankView