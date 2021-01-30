local PataPlayerView,Super = class("PataPlayerView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"

function PataPlayerView:ctor()
	LuaLogE("PataPlayerView ctor")
	self._packName = "Pata"
	self._compName = "PataPlayerView"

	self._rootDepth = LayerDepth.PopWindow

	self.listPlayer = false
	self.closeBtn=false
end

function PataPlayerView:_initUI()
	LuaLogE("PataPlayerView _initUI")


	self.listPlayer =  self.view:getChildAutoType("list_player")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	self.closeBtn:addClickListener(function ( ... )
			self:closeView()
	end)

	self:updateView()
end

function PataPlayerView:updateView()
	--更新玩家列表
	local rankData = self._args.infos or {}
	self.listPlayer:setItemRenderer(function(index,obj)
			--local txtName = obj:getChildAutoType("txt_name")
			--local txtLv = obj:getChildAutoType("txt_lv")
			--local txtType = obj:getChildAutoType("txt_type")
			--local imgIcon = obj:getChildAutoType("img_icon")
			local rData = rankData[index+1] or nil
			if rData~=nil then
				--txtName:setText( rData.name )
				--txtLv:setText( "等级："..rData.level )
				--local typeStr = ""
				--if rData.type == 1 then typeStr = "好友" 
				--elseif rData.type ==2 then typeStr = "公会"
				--elseif rData.type ==3 then typeStr = "好+会"
				--end
				--txtType:setText( typeStr )
				--imgIcon:setURL(PlayerModel:getUserHeadURL(rData.head))
				--local heroCell = BindManager.bindHeroCellShow(obj)
				local hero = BindManager.bindPlayerCell(obj)
				hero:setHead(rData.head, rData.level,rData.id,rData.name,rData.headBorder)
				obj:addClickListener(function()
					--打开玩家具体信息
					ViewManager.open("ViewPlayerView",{playerId = rData.id})
				end)
			end
			
		end
	)
	self.listPlayer:setData(rankData)
end




function PataPlayerView:_initEvent( ... )

end

function PataPlayerView:_exit()
end

return PataPlayerView
