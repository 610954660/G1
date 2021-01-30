--[[
	name: VoidlandRankView
	author: zn
]]

local RankView = require "Game.Modules.Rank.RankView"
local VoidlandRankView, Super = class("VoidlandRankView", RankView)

function VoidlandRankView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandRankView";
	self._rootDepth = LayerDepth.Window
end

function VoidlandRankView:_initUI()
	Super._initUI(self);
	if self.list_type then
		self.list_type:setItemRenderer(
			function(index, obj) 
				local info = self._groupData[index + 1]
				obj:setTitle(info.groupTab);
				-- obj:setIcon(PathConfiger.getFairyLandRankBtnIcon(info.rankType - 26));
				-- obj:getController("size"):setSelectedIndex(0)
				obj:removeClickListener(100)
				obj:addClickListener(function(...)
					self:updateRankData()
                end,100)
			end
		)
		self.list_type:setData(self._groupData)
		self.list_type:setSelectedIndex(self._currentIndex - 1)
	end
end

function VoidlandRankView:updateRankInfo(rankType)
	Dispatcher.dispatchEvent(EventType.voidland_updateRank, self._rankData);
end

--这个方法给特殊排行榜继承后加需要特殊处理的内容
function VoidlandRankView:updateItemSpec(obj, rank, info, isMine)
	-- 点击查看
	if info then
		obj:removeClickListener(100)
		-- obj:addClickListener(function()
			-- local id = isMine and PlayerModel.userid or info.id;
			-- local arrayType = VoidlandModel.modeType == 1 and GameDef.BattleArrayType.DreamLandSingle or GameDef.BattleArrayType.DreamLandMultiple;
			-- ViewManager.open("FriendCheckView",{playerId = id, arrayType = arrayType});
			-- Dispatcher.dispatchEvent("HeroInfo_Show", {playerId = id})
		-- end,100)
	end
	-- 最高通关
	local history = obj:getChildAutoType("txt_history");
	local data = VoidlandModel:getPointInfoById(info.value, self:getCruRankType())
	history:setText(string.format(Desc.Voidland_point, data.nodeId, data.index));
	-- 英雄列表
	local heroData = (info.extraData and info.extraData.dreamLand) and info.extraData.dreamLand or {};
	local list_hero = obj:getChildAutoType("list_hero");
	list_hero:setItemRenderer(function(idx, obj)
		local d = heroData[idx + 1];
		local conf = DynamicConfigData.t_hero[d.code];
		if (not obj.heroCell) then
			obj.heroCell = BindManager.bindHeroCell(obj);
		end
		if (conf) then
			d.category = conf.category;
			obj.heroCell:setBaseData(d);
		end

		obj:removeClickListener();
		obj:addClickListener(function ()
			local id = isMine and PlayerModel.userid or info.id;
			-- local array = info.extraData and info.extraData.dreamLand or {};
			Dispatcher.dispatchEvent("HeroInfo_Show", {playerInfo = {playerId = id}, heroArray = heroData, index = idx + 1});
		end)
	end)
	list_hero:setNumItems(#heroData);
end

return VoidlandRankView