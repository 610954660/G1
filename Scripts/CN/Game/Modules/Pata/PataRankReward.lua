local PataRankReward,Super = class("PataRankReward", View)
local ItemCell = require "Game.UI.Global.ItemCell"

function PataRankReward:ctor()
	LuaLogE("PataRankReward ctor")
	self._packName = "Pata"
	self._compName = "PataRankReward"

	self._rootDepth = LayerDepth.PopWindow

	self.bg = false
	self.listRank = false
	self.listReward = false
	self.listInfo=false
	self.btnGet = false
	self.txtNoReward =false

end
--初始化界面处理
function PataRankReward:_initUI()
	LuaLogE("PataRankReward _initUI")
	
	self.bg =  self.view:getChildAutoType("bg")
	self.listRank =  self.view:getChildAutoType("list_rank")
	self.listReward =  self.view:getChildAutoType("list_reward")
	self.listInfo=self.view:getChildAutoType("list_info")
	self.btnGet =  self.view:getChildAutoType("btn_get")
	self.txtNoReward =  self.view:getChildAutoType("txt_noReward")
	self.spineParent=self.view:getChildAutoType("spineParent")

	self:updateView()
	local spine1 =  SpineUtil.createSpineObj(self.spineParent, Vector2.zero, "gongxihuode", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",false)
	spine1:setAnimation(0,"gongnengjiesuo_down",true)
end
--更新界面处理
function PataRankReward:updateView()
	--更新前3列表
	--name			0:string		#名字
	--level			1:integer		#等级
	--head			2:integer		#头像
	--value			3:integer		#层数
	--id			4:integer	#玩家id
	local rankData = self._args.topInfo or {}
	
	local floor = self._args.level
	self.listRank:setItemRenderer(function(index,obj)			

			local rankIndex=index+1
			local changeIndex=rankIndex
			if rankIndex==1 then
				changeIndex=2
			end
			if rankIndex==2 then
				changeIndex=1
			end
			local heroObj=obj:getChildAutoType("heroCell")
			local rData = rankData[changeIndex] or nil
			if rData==nil then
				--txtName:setText( "虚位以待" )
				--xtFloor:setText( "" )
				--头像显示啥呢
			else
				local hero = BindManager.bindPlayerCell(heroObj)
				obj:getController("rank"):setSelectedPage(changeIndex)
				hero:setHead(rData.head, rData.level,rData.id,nil,rData.headBorder)			
			end
		end
	)
	self.listRank:setNumItems(3)
	self.listInfo:setItemRenderer(function(index,obj)
			
			local rankIndex=index+1
			local changeIndex=rankIndex
			if rankIndex==1 then
				changeIndex=2
			end
			if rankIndex==2 then
				changeIndex=1
			end
			local rData = rankData[changeIndex] or nil
			if rData==nil then
				--txtName:setText( "虚位以待" )
				--xtFloor:setText( "" )
				--头像显示啥呢
			else
				obj:getChildAutoType("playName"):setText(rData.name)
				obj:getChildAutoType("floorIndex"):setText("第"..rData.value.."层")
			end
		end
	)
	self.listInfo:setNumItems(3)
	
	
	
	
	-- --更新奖励信息
	local cfg_tower = DynamicConfigData.t_tower[ 2000 ]
	local floorInfo = cfg_tower[ floor ] or DT  -- ? 需要测试下。	
	local cfg_reward = floorInfo.extraRewardPre
	
	
	--local cfg_tower = DynamicConfigData.t_tower[self._args.activeType]
	--local floorInfo = cfg_tower[self.args.passFloor] or DT
	
	local rewards = false
	if cfg_reward~= nil then
		rewards = cfg_reward.item1
	end	
	if rewards == false then
		self.listReward:setNumItems(0)
	else
		self.listReward:setItemRenderer(function(index,obj)
				local itemcell = BindManager.bindItemCell(obj)
				local itemData = ItemsUtil.createItemData({data = floorInfo.extraRewardPre[index + 1]})
				itemcell:setItemData(itemData)		
				obj:removeClickListener(100)
				obj:addClickListener(function( ... )
						itemcell:onClickCell()
				end,100)
			end
		)
		self.listReward:setData(floorInfo.extraRewardPre)
	end
	self.txtNoReward:setVisible( rewards == false )	
end
--事件监听
function PataRankReward:_initEvent( ... )
	self.btnGet:addClickListener(function ( ... )	
		--如果已经领取的话，直接关闭界面
		local rankCount = ModelManager.MaterialCopyModel:getCopyCount( GameDef.GamePlayType.TowerTopInfo )	
		if rankCount~=0 then
			ViewManager.close("PataRankReward")
			return
		end

		--领取奖励处理
		local onSuccess = function( res )
			print(1,"排行奖励领取成功")
			ViewManager.close("PataRankReward")
			--更新数据
		end
		RPCReq.Copy_GetTowerTopReward({}, onSuccess)
	end)
end
--退出销毁处理
function PataRankReward:_exit()
end

return PataRankReward

