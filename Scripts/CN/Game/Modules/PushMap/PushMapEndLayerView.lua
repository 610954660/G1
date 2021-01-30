local PushMapEndLayerView,Super = class("PushMapEndLayerView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function PushMapEndLayerView:ctor()
	LuaLogE("PushMapEndLayerView ctor")
	self._packName = "PushMap"
	self._compName = "PushMapEndLayerView"
	self._rootDepth = LayerDepth.Window
	self.list_desc =false
	self.list_reward =false
	self.timer = false
end

function PushMapEndLayerView:_initUI()
	LuaLogE("PushMapEndLayerView _initUI")
	--self.c1 =  self.view:getController("c1")
	self.view:getTransition("tween"):playReverse()
	self.view:getTransition("tween"):stop()
	self.timer = Scheduler.schedule(function()
		if tolua.isnull(self.view) then
			return
		end
		self.view:getTransition("tween"):play(function() end)
	end,0.05,1)
	self.list_desc = {}
	self.list_reward = self.view:getChildAutoType("list_reward"):getChildAutoType("list_reward")
	self.view:getChildAutoType("list_reward"):getChild("img_mask"):setTouchable(false)
	for i = 1,3 do
		self.list_desc[i] = self.view:getChildAutoType("desc"..i)
	end
	self:updateView()
end

function PushMapEndLayerView:_exit()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
end

function PushMapEndLayerView:updateView()
	local isSuccess = PushMapModel.isWin
	-- if isSuccess==true then
	-- 	self.c1:setSelectedIndex(0)
	-- else
	-- 	self.c1:setSelectedIndex(1)
	-- end
	-- self.bg:addClickListener(function ( ... )
	-- 	ViewManager.close("PushMapEndLayerView")
	-- end)
	local cityId=PushMapModel.city or 1	--# 最新城市
	local chapterId= PushMapModel.point or 1 	--# 最新章节
	local pointId= PushMapModel.level or 1	--# 最新关卡
	local star = PushMapModel.star or 0 --# 最新星数
	local starList = PushMapModel.starList or 0 --# 当前挑战最新星数列表
	local rewardArr=PushMapModel:getPointRewardDesc(cityId,chapterId,pointId) 
	printTable(10,'>??????????????',self._args,isSuccess,rewardArr)
	printTable(9,'>>>>>>>>>>>>>>>>',cityId,chapterId,pointId,star,rewardArr)

    self:updateDesc(rewardArr,starList)
	if isSuccess then
		local rewardPre = PushMapModel.reward
		printTable(10,'>??????????????111',rewardPre)
		local c2=self.view:getController('c2')
		if next(rewardPre)  then
			c2:setSelectedIndex(1)
		else
			c2:setSelectedIndex(0)
		end

		self.list_reward:setItemRenderer(function(index,obj)
			local cellObj = obj:getChild("itemCell")
			cellObj:setVisible(false)
			local itemcell = BindManager.bindItemCell(cellObj)
        	local award =rewardPre[index + 1]
        	itemcell:setData(award.code, award.amount, award.type)
			itemcell:setFrameVisible(false)
			cellObj:addClickListener(function( ... )
				itemcell:onClickCell()
			end)

			Scheduler.schedule(function()
				if tolua.isnull(self.view) then
					return
				end
				cellObj:setVisible(true)
				local rotate = cc.RotateBy:create(0.15,{x = 0,y = 180,z = 0})
				local rotate2 = cc.RotateBy:create(0.15,{x = 0,y = -180,z = 0})
				local callBack = cc.CallFunc:create(function()
					SpineUtil.createSpineObj(cellObj, vertex2(cellObj:getWidth()/2,cellObj:getHeight()/2), "wuti_chuxian", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan",false)
				end)
				cellObj:displayObject():runAction(cc.Sequence:create(rotate,callBack,rotate2))
			end,index * 0.125,1)
		end)

		Scheduler.schedule(function()
			if tolua.isnull(self.view) then
				return
			end
			self.list_reward:setNumItems(#rewardPre)
		end,0.6,1)
	end
end

function PushMapEndLayerView:_initEvent( ... )
end

function PushMapEndLayerView:updateDesc(rewardArr,starList)
	for i = 1,3 do
		self.list_desc[i]:removeClickListener(100)
		self.list_desc[i]:addClickListener(function( ... )
		end,100)
		local rewardItem=rewardArr[i]
		self.list_desc[i]:getChild('text_desc'):setText(rewardItem.desc)
		local gCtr = self.list_desc[i]:getController("c1")

		if rewardItem.reward then
			local rewardType=rewardItem.reward.type
			local rewardCode=rewardItem.reward.code
			local rewardAmount=rewardItem.reward.amount
			local url = ItemConfiger.getItemIconByCodeAndType(rewardType,rewardCode)

			self.list_desc[i]:getChild('img_icon'):setURL(url)
			self.list_desc[i]:getChild('txt_num'):setText(rewardAmount)
		end

		if starList and starList[i] == true then
			printTable(999,"推图奖励",rewardItem)
			if rewardItem.reward then
				gCtr:setSelectedIndex(0)
			else
				gCtr:setSelectedIndex(1)
			end
		else
			gCtr:setSelectedIndex(2)
		end
	end
end

function PushMapEndLayerView:_exit()
	--Dispatcher.dispatchEvent(EventType.pushmap_updateAwardList)

	local isSuccess = PushMapModel.isWin
	if isSuccess==true then
		if self._args and tonumber(self._args.film)~=0 then
			ViewManager.open("PushMapFilmView",{step =self._args.film,isShowGuochangyun=true})
		else
			Dispatcher.dispatchEvent(EventType.pushMap_figthendInfo)
		end
	end
end

function PushMapEndLayerView:PlayRewardAnim()

end

return PushMapEndLayerView
