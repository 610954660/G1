--added by xhd 
--黑名单
local caozuoType = GameDef.FriendListType.Blacklist
local FriendblacklistView,Super = class("FriendblacklistView", View)
function FriendblacklistView:ctor()
	self._packName = "Friend"
	self._compName = "FriendblacklistView"
	self._isFullScreen = false
	self.list = false
	self.noControl = false
	self.data = false
end

function FriendblacklistView:_initUI( )
    self.list = self.view:getChildAutoType("list")
    self.noControl = self.view:getController("c1")

    self:init_listShow()

    local params = {}
    params.type = caozuoType
    params.onSuccess = function (res )
        --printTable(1,res)
       self.data = res.list
       ModelManager.FriendModel:initData(caozuoType,res.list)
	   if (tolua.isnull(self.view)) then return end;
       self:update_list()
    end
    RPCReq.Friend_List(params, params.onSuccess)
end

function FriendblacklistView:init_listShow( ... )
    self.list:setItemRenderer(function(index,obj)
		obj:getController('c1'):setSelectedPage('black');
	   local name_label = obj:getChildAutoType("name_label") --名称
	--    local levi_label = obj:getChildAutoType("levi_label") --等级
	   local warNum = obj:getChildAutoType("warNum") --战力
	   local Guildtxt = obj:getChildAutoType("Guildtxt") --工会
	   local genderControl = obj:getChildAutoType("gender"):getController("c1") --性别控制

	   local agreeBtn = obj:getChildAutoType("btn_remove") --移除

	   local headBtn = obj:getChildAutoType("headBtn") --头像
	   --local headIcon = headBtn:getChildAutoType("icon")
       local curData = self.data[index+1]
		local headItem = BindManager.bindPlayerCell(headBtn)
		headItem:setHead(curData.head, curData.level, curData.playerId,nil,curData.headBorder)

       name_label:setText(curData.name)
    --    levi_label:setText("等级："..curData.level)
       --headIcon:setURL(PlayerModel:getUserHeadURL(curData.head))
       warNum:setText(StringUtil.transValue(curData.tower))
       if curData.guild and curData.guild>0 and curData.guildName then
       	 Guildtxt:setText(curData.guildName)
       else
       	 Guildtxt:setText(Desc.Friend_check_txt4)
       end
       if curData.sex==1 then
       	genderControl:setSelectedIndex(0)
       else
       	genderControl:setSelectedIndex(1)
       end
		agreeBtn:removeClickListener(333)
	   agreeBtn:addClickListener(function( ... )
		local function onYes ()
			local params = {}
		    params.type =0
		    params.playerId =curData.playerId
		    params.onSuccess = function (res )
		        -- print(1,"Friend_RemoveBlack")
		        -- printTable(1,res)
		        if res.list then
		        	ModelManager.FriendModel:unLockBlack(res.list[1])
		        end
		    end
		    RPCReq.Friend_RemoveBlack(params, params.onSuccess)
		end
		local info = {
			text=string.format(Desc.Friend_check_txt9, curData.name),
			type="yes_no",
			onYes=onYes,
		}
		Alert.show(info);
       	    
       end,333)
	end)
end

function FriendblacklistView:update_list( ... )
	self.list:setData(self.data)
	if #self.data <= 0 then
		self.noControl:setSelectedIndex(1)
	else
		self.noControl:setSelectedIndex(0)
	end
end

function FriendblacklistView:black_update_list(  )
	self.data = ModelManager.FriendModel:getData(caozuoType)
	self:update_list()
end

function FriendblacklistView:_initEvent( )

	
end

--页面退出时执行
function FriendblacklistView:_exit( ... )
	print(1,"EmailView _exit")
end


return FriendblacklistView