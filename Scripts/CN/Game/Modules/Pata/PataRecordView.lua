local PataRecordView,Super = class("PataRecordView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"

function PataRecordView:ctor()
	LuaLogE("PataRecordView ctor")
	self._packName = "Pata"
	self._compName = "PataRecordView"

	self._rootDepth = LayerDepth.PopWindow

	self.bg = false
	self.list_rank = false
	self.noData=false
	self.closeBtn=false
end

function PataRecordView:_initUI()

	self.list_rank=self.view:getChildAutoType("list_rank")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	self.noData=self.view:getChildAutoType("noData")
	self.closeBtn:addClickListener(function ( ... )
			--ViewManager.close("FriendCheckView")
			self:closeView()
	end)
	self:updateView()

	
end

--id			1:integer		#玩家id
--name			2:string		#名字
--level			3:integer		#等级
--head 			4:integer		#头像
--combat 		5:integer		#战力
--sec			6:integer		#时间
--type 			7:integer		#类型 好友1  会友2 好友会友3
--recordId		8:string		#战斗id


function PataRecordView:updateView()
	--更新玩家列表
	local rankData = self._args.data or {}
	printTable(086,rankData)
	self.list_rank:setItemRenderer(function(index,obj)
			local rData=rankData[index+1]
			local combat=obj:getChildAutoType("combat")
			local playerName=obj:getChildAutoType("playerName")
			local recordTime=obj:getChildAutoType("recordTime")
			local recorFrame=obj:getChildAutoType("recorFrame")
			local sex=obj:getChildAutoType("sex")
			if index%4==0 then
				sex:setURL(PathConfiger.getHeroSexIcon(2))
			else
				sex:setURL(PathConfiger.getHeroSexIcon(1))
			end
			--if index<3 then
				--recorFrame:setURL(PathConfiger.getRankListFrame(1+index))
			--else
				--recorFrame:setURL(PathConfiger.getRankListFrame(4))
			--end
			local hero = BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
			hero:setHead(rData.head, rData.level,rData.id,nil,rData.headBorder)
			combat:setText(StringUtil.transValue(rData.combat))
			playerName:setText(rData.name)
			if rData.sec then
				recordTime:setText("通关时间:"..TimeLib.getNormalDay(rData.sec))
			end
			local recordBtn=obj:getChildAutoType("recordBtn")
			recordBtn:addClickListener(function ()
				BattleModel:requestBattleRecord(rData.recordId)
			end)
	
	end)
	self.list_rank:setData(rankData)
	if next(rankData)~=nil then
		self.noData:setVisible(false)
	else
		self.noData:setVisible(true)
	end

end




function PataRecordView:_initEvent( ... )

end

function PataRecordView:_exit()
end

return PataRecordView
