local GuildHeadView, Super = class("GuildHeadView", Window)

function GuildHeadView:ctor()
    LuaLogE("GuildHeadView ctor")
    self._packName = "Guild"
    self._compName = "GuildHeadView"
    self._rootDepth = LayerDepth.PopWindow
    -- self._maskType = 1
    -- self._isFullScreen = true
    self.curSeledId = false
    self.closeBtn1=false
    self.sureBtn = false
    self.headInfo = false
    self.headList = false
    self.txt_desc = false
    self.curIndex = false
end

function GuildHeadView:_initUI()
    LuaLogE("GuildHeadView _initUI")
    printTable(9,'>>>>>>>>>>>>>',self._args)
	self.headList = self.view:getChild("list_head")
	self.txt_desc = self.view:getChild("txt_desc")
    self.headList:setVirtual()
    local headInfo = DynamicConfigData.t_guildIcon
    self.headList:setItemRenderer(
        function(index, obj)
            if self._args[1] == headInfo[index + 1].icon then
                self.curSeledId = self._args[1]
                obj:setSelected(true)
				self.txt_desc:setText(headInfo[index + 1].desc)
            end
            local icon = obj:getChild("frameLoader")
            local iconIdex = headInfo[index + 1].icon
            icon:setURL(GuildModel:getGuildHead(iconIdex))
            obj:removeClickListener(100)
             --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local iconIdex = headInfo[index + 1].icon
                    self.curSeledId = iconIdex;
					self.txt_desc:setText(headInfo[index + 1].desc)
                end,
                100
            )
        end
    )
    self.headList:setNumItems(#headInfo)

    --LoginModel:readSavedServerInfo()
    --[[self.headInfo = {}
	local cardInfo = ModelManager.CardLibModel:getCardHaveHeroId()
	for k,v in pairs(PlayerModel.headInfo) do
		local temp = {}
		temp.id = v.id
		temp.image = v.image
		temp.isHave = false
		if cardInfo[v.id] then
			temp.isHave = true
		end
		table.insert(self.headInfo,temp)
	end
	
	table.sort(self.headInfo,function(a,b)
		if a.isHave and  b.isHave == false then
			return true
		else
			return  false
		end
		
	end)--]]
    self.closeBtn1 = self.view:getChildAutoType("btn_close")

    self.closeBtn1:addClickListener(
        function()
            self:closeView()
        end
    )

    self.sureBtn = self.view:getChildAutoType("Btn_sure")

    self.sureBtn:addClickListener(
        function()
            --[[RPCReq.GamePlay_Modules_Rename_head({id = self.headInfo[self.curIndex].id},function(args)
					print(33,"head chang callback")
					printTable(33,args)
					if args.ret == 0 then
						Alert.show(Desc.player_changesuccess)
						PlayerModel.head = args.id
						--self.address:setText(PlayerModel.address)
						Dispatcher.dispatchEvent(EventType.player_headreset,args.id)
					else
						RollTips.show("error.code = "..args.ret)
					end
				end)--]]
				Dispatcher.dispatchEvent(EventType.guild_up_headId,self.curSeledId)	
            self:closeView()
        end
    )

    --[[self.headList = self.view:getChildAutoType("list")
	
	self.headList:setItemRenderer(function(index,obj)
			--obj:removeClickListener()--池子里面原来的事件注销掉
			if self.headInfo[index+1].isHave then
				obj:addClickListener(function(context)
						print(33,index)
						self.curIndex = index+1
					end)
			else
				obj:removeClickListener()
				obj:addClickListener(function(context)
						RollTips.show(Desc.player_renamecode8)
					end)
			end
			local gloader = obj:getChildAutoType("frameLoader")
			local icon = 
			gloader:setURL(self.headInfo[index+1].image)
			if self.headInfo[index+1].isHave == false then
				gloader:setGrayed(true)
			end
		end
	)
	self.headList:setNumItems(#self.headInfo);
	self.headList:setSelectedIndex(0)
	self.curIndex = 1--]]
end

function GuildHeadView:_initEvent(...)
    --self:addEventListener(EventType.login_chooseServer,self)
end

function GuildHeadView:loadDict(...)
   
end

return GuildHeadView
