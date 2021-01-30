--Date :2021-01-04
--Author : generated by FairyGUI
--Desc : 

local GLLegendsBattleTeamView,Super = class("GLLegendsBattleTeamView", Window)

function GLLegendsBattleTeamView:ctor()
	--LuaLog("GLLegendsBattleTeamView ctor")
	self._packName = "GuildLeagueOfLegends"
	self._compName = "GLLegendsBattleTeamView"
	self._rootDepth = LayerDepth.PopWindow
	self.data = self._args.info or false;
end

function GLLegendsBattleTeamView:_initEvent( )
	
end

function GLLegendsBattleTeamView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:GuildLeagueOfLegends.GLLegendsBattleTeamView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.guildIcon1 = viewNode:getChildAutoType('guildIcon1')--GLoader
	self.guildIcon2 = viewNode:getChildAutoType('guildIcon2')--GLoader
	self.list_team1 = viewNode:getChildAutoType('list_team1')--GList
	self.list_team2 = viewNode:getChildAutoType('list_team2')--GList
	self.txt_combat1 = viewNode:getChildAutoType('txt_combat1')--GTextField
	self.txt_combat2 = viewNode:getChildAutoType('txt_combat2')--GTextField
	self.txt_name1 = viewNode:getChildAutoType('txt_name1')--GTextField
	self.txt_name2 = viewNode:getChildAutoType('txt_name2')--GTextField
	--{autoFieldsEnd}:GuildLeagueOfLegends.GLLegendsBattleTeamView
	--Do not modify above code-------------
end

function GLLegendsBattleTeamView:_initUI( )
	self:_initVM()
	if (self.data) then
		for side, info in pairs(self.data) do
			GuildLeagueOfLegendsModel:getGuildTeamInfo(info.guildId);
			local baseInfo = GuildLeagueOfLegendsModel.guildMap[info.guildId] or false;
			if (baseInfo) then
				local icon = self["guildIcon"..side];
				local txt_combat = self["txt_combat"..side];
				local txt_name = self["txt_name"..side];
				icon:setIcon(GuildModel:getGuildHead(baseInfo.guildIcon));
				txt_combat:setText(StringUtil.transValue(baseInfo.combat));
				txt_name:setText(baseInfo.guildName);
			end
		end
	end
end

function GLLegendsBattleTeamView:GLOL_guildTeam(_, guildId, team)
	if (self.data) then
		local arr = GuildLeagueOfLegendsModel:rebuildTeamInfo(team.battleArray or {})
		if (guildId == self.data[1].guildId) then
			self:upTeamList(self.list_team1, arr);
		elseif (guildId == self.data[2].guildId) then
			self:upTeamList(self.list_team2, arr);
		end
	end
end

function GLLegendsBattleTeamView:upTeamList(listItem, team)
	listItem:setItemRenderer(function(idx, obj)
		local data = team[idx + 1];
		local no = obj:getChildAutoType("txt_no");
		local combat = obj:getChildAutoType("txt_combat");
		local cards = obj:getChildAutoType("list_cards");
		
		no:setText(string.format(Desc.GLOL_str1, idx + 1));
		combat:setText(string.format(Desc.GLOL_str2, data.combat));
		local heroInfos = data.heroInfos;
		cards:setItemRenderer(function(i, o)
			local d = heroInfos[i + 1];
			if (not o.cell) then
				o.cell = BindManager.bindCardCell(o);
			end
			d.heroId = d.code;
			d.heroStar = d.star;
			o.cell:setData(d, true);
		end)
		cards:setNumItems(#heroInfos or 0)
	end)
	listItem:setNumItems(math.min(#team, 30));
end

return GLLegendsBattleTeamView