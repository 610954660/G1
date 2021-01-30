--added by wyang
--道具框封裝
local PlayerCell = class("PlayerCell")
function PlayerCell:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	
	self._code = false
	self._level = false
	self._star = false
	
	self.frameLoader = false
	self.iconLoader = false
	--self.list_star = false
	--等级label
	self.levelLabel = false
	self.relationLoader = false
	self.playerName=false
	self.ismeCtrl = false
	self.showLvCtrl = false
	self.showBgCtrl = false
	
	self.playerId=false

end

function PlayerCell:clear()
	self.levelLabel:setText("")
	--self:setStar(0)
end

function PlayerCell:init( ... )
	self.frameLoader = self.view:getChildAutoType("frameLoader")
	self.iconLoader = self.view:getChildAutoType("iconLoader")
	self.levelLabel = self.view:getChildAutoType("level")
	self.relationLoader = self.view:getChildAutoType("relationLoader")
	self.playerName = self.view:getChildAutoType("playerName")
	self.ismeCtrl = self.view:getController("ismeCtrl")
	self.showLvCtrl = self.view:getController("showLv")
	self.showBgCtrl = self.view:getController("showBg")
	--self.list_star = self.view:getChildAutoType("_GList$stars")
end



--直接设设置code的数据
function PlayerCell:setHead(head, level, playerId,name,frameId)
	if not head or not level then return end
	if head == 0 then
		self.iconLoader:setURL(nil)
	else
		self.iconLoader:setURL(PathConfiger.getHeroOfMonsterIcon(head))
	end

	self.frameLoader:setURL(PathConfiger.getHeadFrame(frameId))
	
	self.levelLabel:setText("Lv."..level)
	
	if name and self.playerName then
		self.playerName:setText(name)
	end
	if playerId then
		self.playerId=playerId
	end

	--是不是自己
	if playerId == PlayerModel.userid then
		--self.ismeCtrl:setSelectedIndex(1)
		self:setReleation()
	else
		--self.ismeCtrl:setSelectedIndex(0)
		self:setReleation(playerId)
	end
end


--设置关系图标
function PlayerCell:setReleation(playerId)
	if(playerId) then
		local relation = 0
		local isFriend = ModelManager.FriendModel:IsMyFriend(playerId)
		local isSameGuild = ModelManager.GuildModel:isTogetherGuild(playerId)
		if isFriend and isSameGuild then
			relation = 3
		elseif isFriend then
			relation = 1
		elseif isSameGuild then
			relation = 2
		end
		
		if relation > 0 then
			self.relationLoader:setVisible(true)
			local path = PathConfiger.getRelationIcon(relation)
			self.relationLoader:setURL(path)
		else
			self.relationLoader:setVisible(false)
		end
	else
		self.relationLoader:setVisible(false)
	end
end


function PlayerCell:setData(code,level, playerId)
	self._code = code
	self._level = level
	-- self._star = star
	self.iconLoader:setURL(PathConfiger.getHeroCardex(code))
	self.levelLabel:setText("等级："..level)
	self:setReleation(playerId)
end

function PlayerCell:setShowLv(show)
	self.showLvCtrl:setSelectedIndex(show and 1 or 0)
end

function PlayerCell:setShowBg(show)
	self.showBgCtrl:setSelectedIndex(show and 1 or 0)
end


function PlayerCell:setShowName(show)
	if self.playerName then
		self.playerName:setVisible(show)
	end
end



--退出操作 在close执行之前 
function PlayerCell:__onExit()
    print(1,"PlayerCell __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

function PlayerCell:showRelation(show)
	self.view:getController("relationCtrl"):setSelectedIndex(show and 1 or 0);
end

return PlayerCell