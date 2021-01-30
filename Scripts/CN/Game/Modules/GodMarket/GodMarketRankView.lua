--Date :2020-12-26
--Author : generated by FairyGUI
--Desc : 

local GodMarketRankView,Super = class("GodMarketRankView", Window)

function GodMarketRankView:ctor()
	--LuaLog("GodMarketRankView ctor")
	self._packName = "GodMarket"
	self._compName = "GodMarketRankView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function GodMarketRankView:_initEvent( )
	
end

function GodMarketRankView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:ExtraordinarylevelPvP.GodMarketRankView
	self.blackBg = viewNode:getChildAutoType('blackBg')--GButton
	self.c1 = viewNode:getController('c1')--Controller
	self.typeCtrl = viewNode:getController('typeCtrl')--Controller
	self.com_myRank = viewNode:getChildAutoType('com_myRank')--Component8
		self.com_myRank.txt_order = viewNode:getChildAutoType('com_myRank/$txt_order')--GRichTextField
		self.com_myRank.duanweidesc = viewNode:getChildAutoType('com_myRank/duanweidesc')--GRichTextField
		self.com_myRank.headItem = viewNode:getChildAutoType('com_myRank/headItem')--GButton
		self.com_myRank.img_duanwei = viewNode:getChildAutoType('com_myRank/img_duanwei')--GLoader
		self.com_myRank.img_myduanwei = viewNode:getChildAutoType('com_myRank/img_myduanwei')--GLoader
		self.com_myRank.myduanweidesc = viewNode:getChildAutoType('com_myRank/myduanweidesc')--GRichTextField
		self.com_myRank.txt_combat = viewNode:getChildAutoType('com_myRank/txt_combat')--GTextField
		self.com_myRank.txt_myRank = viewNode:getChildAutoType('com_myRank/txt_myRank')--GRichTextField
		self.com_myRank.txt_myRankTitle = viewNode:getChildAutoType('com_myRank/txt_myRankTitle')--GTextField
		self.com_myRank.txt_name = viewNode:getChildAutoType('com_myRank/txt_name')--GTextField
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.list_type = viewNode:getChildAutoType('list_type')--GList
	--{autoFieldsEnd}:ExtraordinarylevelPvP.GodMarketRankView
	--Do not modify above code-------------
end

function GodMarketRankView:_initListener( )

end

function GodMarketRankView:_initUI( )
	self:_initVM()
	self:_initListener()
	self.list_type:setItemRenderer(
        function(index, obj)
            local title = obj:getChildAutoType("title")
            if index == 0 then
				obj:setSelected(true)
				self.typeCtrl:setSelectedIndex(0)
				GodMarketModel:getRankData(1)
                title:setText(Desc.godmarket_desc13) --godmarket_desc13="贡献排行"
			else
                title:setText(Desc.godmarket_desc15) --godmarket_desc15="Boss伤害排行"
            end
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    if index == 0 then
						self.typeCtrl:setSelectedIndex(0)
						GodMarketModel:getRankData(1)
                    else
						self.typeCtrl:setSelectedIndex(1)
						GodMarketModel:getRankData(2)
                    end
                end,
                100
            )
        end
    )
    self.list_type:setNumItems(2)
end

function GodMarketRankView:godmarket_rankData(_,data)
	local type = data.type
	local rank = data.data
	if #rank>0 then
		local myRankInfo={}
		local rankIndex=0
		--TableUtil.sortByMap( rank , { {key="dan",asc=true},{key="score",asc=true}} )
		for i=1 ,#rank,1  do
			local rankItem=rank[i]
			 if rankItem.playerId==PlayerModel.userid then
				myRankInfo=rankItem
				rankIndex=i
			 end
		end
		local myRankc1 = self.com_myRank:getController("c1")
		local myRankc3 = self.com_myRank:getController("c3")
		local playerHead=self.com_myRank:getChildAutoType("headItem");
		local img_myduanwei=self.com_myRank:getChildAutoType("img_myduanwei");
		local myduanweidesc=self.com_myRank:getChildAutoType("myduanweidesc");	
		local txt_myRank=self.com_myRank:getChildAutoType("txt_myRank");	
		local txt_mycombat=self.com_myRank:getChildAutoType("txt_combat");
		local txt_myname=self.com_myRank:getChildAutoType("txt_name");
		local typeCtrl=self.com_myRank:getController("typeCtrl");
		
		typeCtrl:setSelectedIndex(type - 1) 
		if next(myRankInfo) then
			self.com_myRank:setVisible(true)
			myRankc3:setSelectedIndex(0)
			if rankIndex<=3 then
				myRankc1:setSelectedIndex(rankIndex-1)
			else
				myRankc1:setSelectedIndex(3)
			end
			txt_myRank:setText(rankIndex) 
				local dan=myRankInfo.dan or 1
				if myRankInfo.name==nil then 
					txt_myname:setText("")
				else
					txt_myname:setText(myRankInfo.name.."")
				end
				local  combat=myRankInfo.combat or 0
				txt_mycombat:setText(Desc.materialCopy_str5.." "..StringUtil.transValue(combat))
				local heroItem = BindManager.bindPlayerCell(playerHead)
				heroItem:setHead(myRankInfo.head, myRankInfo.level,nil,nil,myRankInfo.headBorder)
				playerHead:removeClickListener(100)
				playerHead:addClickListener(
				function(...)
					ViewManager.open("ViewPlayerView",{playerId = myRankInfo.playerId,serverId = myRankInfo.serverId})
				end,100)
		else
			self.com_myRank:setVisible(false)
			myRankc1:setSelectedIndex(3)
			myRankc3:setSelectedIndex(1)
		end
		local myRankc2 = self.com_myRank:getController("c2")
		myRankc2:setSelectedIndex(1)

		self.c1:setSelectedIndex(0)
		self.list_rank:setVirtual()
		self.list_rank:setItemRenderer(
			function(index, obj) 
			local serverInfo=rank[index+1]
			local c1 = obj:getController("c1")
			local c2 = obj:getController("c2")
			local typeCtrl = obj:getController("typeCtrl");
			typeCtrl:setSelectedIndex(type - 1)
			c2:setSelectedIndex(0)
			if index<=2 then
				c1:setSelectedIndex(index)
			else
				c1:setSelectedIndex(3)
			end
			local txt_order=obj:getChildAutoType("$txt_order");	
			txt_order:setText(index+1) 
			local txt_name=obj:getChildAutoType("txt_name");
			if serverInfo.name==nil then 
				txt_name:setText("")
			else
				txt_name:setText(serverInfo.name.."")
			end
			local txt_combat=obj:getChildAutoType("txt_combat");
			local  combat=serverInfo.combat or 0
			txt_combat:setText(Desc.materialCopy_str5.." "..StringUtil.transValue(combat))
			local playerHead=obj:getChildAutoType("headItem");
			local heroItem = BindManager.bindPlayerCell(playerHead)
			heroItem:setHead(serverInfo.head, serverInfo.level,nil,nil,serverInfo.headBorder)
			playerHead:removeClickListener(100)
			playerHead:addClickListener(
				function(...)
					ViewManager.open("ViewPlayerView",{playerId = serverInfo.playerId,serverId = serverInfo.serverId})
				end,100
			)
			
			local btn_record=obj:getChildAutoType("btn_record");	
			btn_record:removeClickListener(100)
			btn_record:addClickListener(
				function(...)
					--ViewManager.open("ViewPlayerView",{playerId = serverInfo.playerId,serverId = serverInfo.serverId})
					BattleModel:requestBattleRecord(serverInfo.bossBattle)
				end,100
			)
			local dan=serverInfo.dan or 1--ExtraordinarylevelPvPModel:getDanByscore(serverInfo.score)
			local duanweidesc=obj:getChildAutoType("duanweidesc");	
			duanweidesc:setText(serverInfo.score)
			end
		)
		self.list_rank:setNumItems(#rank)
	else
		self.c1:setSelectedIndex(1)
	end
end


return GodMarketRankView