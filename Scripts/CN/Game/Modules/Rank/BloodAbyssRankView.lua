--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local BloodAbyssRankView,Super = class("BloodAbyssRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 

local ItemCell = require "Game.UI.Global.ItemCell"
function BloodAbyssRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "BloodAbyssRankView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.no_reward=false
	self.list_reward = false
	self.mydata = data
end

-------------------常用------------------------
--UI初始化
function BloodAbyssRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	
	self.c1=self.view:getController('c1')

	
end

--[[function BloodAbyssRankView:updateRankInfo(rankType)
	local reward={};
	if #self._rankData>0 then
		local hurt=self._rankData[1].value
		reward=GuildModel:getGuildFirstRankReward(rankType,hurt)
	end
	self.list_reward:setVirtual()
	self.list_reward:setItemRenderer(
		function(index, obj) 
		   	local itemcell = BindManager.bindItemCell(obj)
        	local award = reward[index + 1]
        	itemcell:setData(award.code, award.amount, award.type)
            itemcell:setFrameVisible(false)
            obj:addClickListener(function( ... )
            	itemcell:onClickCell()
			end)
		end
	)
	local count=0
	if next(self._rankData)~=nil then
		count=#reward
	end
	if count==0 then
		self.c1:setSelectedIndex(0)
	else
		self.c1:setSelectedIndex(1)
	end
	--self.no_reward:setVisible(count==0)
	self.list_reward:setNumItems(count)
end--]]

function BloodAbyssRankView:setWinTtile(title)
	
	if self._frame then self._frame:setTitle(BloodAbyssModel:getCurRankName()) end
end

--这个方法给特殊排行榜继承后加需要特殊处理的内容
function BloodAbyssRankView:updateItemSpec(obj, rank, info, isMine)
	if not info then return end
	local btn_record = obj:getChildAutoType("btn_record")
	local headItem = obj:getChildAutoType("headItem")
	local txt_attr1 = obj:getChildAutoType("txt_attr1")
	local txt_attr2 = obj:getChildAutoType("txt_attr2")
	txt_attr1:setText(StringUtil.transValue(info.exParam.param1 or ""))
	txt_attr2:setText(info.value)
	
	
	obj:removeClickListener(100)   --移除通用处理添加的监听 
	headItem:removeClickListener(100)
	headItem:addClickListener(
		function(...)

			ViewManager.open("ViewPlayerView",{playerId = info.id})
			
		end,100
	)
		
	btn_record:removeClickListener(100)
	btn_record:addClickListener(
		function(...)

			BattleModel:requestBattleRecord(info.battleId,nil,GameDef.BattleArrayType.BloodAbyss)
		end,100)
	
end


--事件初始化
function BloodAbyssRankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function BloodAbyssRankView:_enter( ... )
	print(1,"BloodAbyssRankView _enter")
end


--页面退出时执行
function BloodAbyssRankView:_exit( ... )

	print(1,"BloodAbyssRankView _exit")
end

-------------------常用------------------------

return BloodAbyssRankView