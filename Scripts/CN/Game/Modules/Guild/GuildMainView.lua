--added by wyang 公会大厅
local GuildMainView, Super = class("GuildMainView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildMainView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildMainView"
    self._rootDepth = LayerDepth.Window
    self._btnListData = false
    self.pageCtrl = false
    self.btn_setting = false
    self.showJurisdiction = false

    --公会详情
    self.mainbtn_manager = false
    self.maintxt_guildName = false
    self.maintxt_level = false
    self.mainpg_exp = false
    self.maintxt_vitality = false
    self.maintxt_playerNum = false
    self.maintxt_masterName = false
    self.maintxt_notice = false
    self.mainbtn_editNotice = false
    self.mainbtn_manage = false
    self.mainimg_head = false
	self.mainlist_guildPlayer = false
	
	--公会动态
    self.recordList = false
    self.format_normal="%m/%d";
	self.format_normal1 = "%H:%M:%S";
	self.timeStr = "%s"
	self.msToString = TimeLib.msToString

    --公会申请列表
    self.membership_Ctr=false
	self.membership_guildNum=false
	self.Membership_agreedNum=false
	self.Membership_guildPlayer=false
	self.Membership_agreed=false
	self.Membership_ignore=false

	--查找公会列表
	self.btn_refresh = false
	self.btn_search = false
	self.txt_input = false
    self.list_guild = false
    self.recommend_Ctr=false
end

--添加红点
function GuildMainView:_addRed(...)
    
end
-------------------常用------------------------
--UI初始化
function GuildMainView:_initUI(...)
    local posTion = GuildModel.guildList.myGuildPosition
    self.showJurisdiction = self.view:getChild("list_jurisdiction")
    self.pageCtrl = self.view:getController("c1")
    self:setBg("handbook_hero.jpg")
    self:initMainViewCom()
	self:initDynamicCom()
	self:initMembershipCom()
	self:initRecommendCom()
    self.showJurisdiction:setItemRenderer(
        function(index, obj)
            local itemData = self._btnListData[index + 1]
            obj:setTitle(itemData.lable)
            obj:setIcon(GuildModel:getjurisdictionIcon(itemData.action))
            if itemData.action==2 then
              local red=  RedManager.getTips('V_Guild_APPLYRED');
              if red==nil then
                    red=false
              end
              local img_red= obj:getChild('img_red')
              RedManager.register( "V_Guild_PANDECT" ,img_red , ModuleId.Guild.id )
            end

            obj:removeClickListener(100) --需要移除事件，不然会连续点好几次
            obj:addClickListener(
                function(...)
                    local item = self._btnListData[index + 1]
                    self:onManagerBtnClick(item.action)
                end,
                100
            )
            if index == 0 then
                self:onManagerBtnClick(0)
                obj:setSelected(true)
            end
        end
    )
    self:showManagerBtns(posTion)
end

function GuildMainView:showManagerBtns(priority)
    local array = DynamicConfigData.t_guildPosition[priority]
    local settingData = GuildModel._btnListSetting
    local listData = {}
    for _, v in ipairs(settingData) do
        if v.priority==0 then
            table.insert(listData, v)
        end
        if (table.indexof(array.privilegeList, v.priority)) ~= false then
            table.insert(listData, v)
        end
    end
    self._btnListData = listData
    self.showJurisdiction:setData(self._btnListData)
    --self.showJurisdiction:resizeToFit(table.getn(self._btnListData))
end

function GuildMainView:onManagerBtnClick(action)
    if (action == 0) then -- 公会详情
        self.pageCtrl:setSelectedIndex(0)
        self:initMainview()
    elseif (action == 1) then -- 公会动态
		self.pageCtrl:setSelectedIndex(1)
		self:initDynamicView()
    elseif (action == 2) then --入会申请
        RedManager.updateValue("V_Guild_APPLYRED", false);  
		self.pageCtrl:setSelectedIndex(2)
		self:initMembershipView()
    elseif (action == 3) then --查找公会
        self.pageCtrl:setSelectedIndex(3)
        GuildModel:getRecommendGuild(1)
        self:initRecommend()
    end
end

function GuildMainView:initMainViewCom()
    self.mainbtn_manager = self.view:getChild("btn_manager")
    self.maintxt_guildName = self.view:getChildAutoType("txt_guildName")
    self.maintxt_level = self.view:getChildAutoType("txt_level")
    self.mainpg_exp = self.view:getChildAutoType("pg_exp")
    self.maintxt_vitality = self.view:getChildAutoType("txt_vitality")
    self.maintxt_playerNum = self.view:getChildAutoType("txt_playerNum")
    self.maintxt_masterName = self.view:getChildAutoType("txt_masterName")
    self.maintxt_notice = self.view:getChildAutoType("txt_notice")
    self.mainbtn_editNotice = self.view:getChildAutoType("btn_editNotice")
    self.mainbtn_manage = self.view:getChildAutoType("btn_manage")
    self.mainimg_head = self.view:getChildAutoType("img_head")
    self.mainlist_guildPlayer = self.view:getChildAutoType("list_guildPlayer")
    
end

function GuildMainView:initDynamicCom()
    self.recordList = self.view:getChild("n46")
    
end

function GuildMainView:initMembershipCom()
    self.membership_Ctr=self.view:getController('c2');
	self.membership_guildNum=self.view:getChild('txt_guildNum');
	self.Membership_agreedNum=self.view:getChild('txt_agreedNum');
	self.Membership_guildPlayer=self.view:getChild('list_guildapplyPlayer');
	self.Membership_agreed=self.view:getChild('btn_agreed');
	self.Membership_ignore=self.view:getChild('btn_ignore');
end

function GuildMainView:initRecommendCom()
    self.recommend_Ctr=self.view:getController('c3');
	self.btn_refresh = self.view:getChildAutoType("btn_refresh")
	self.btn_search = self.view:getChildAutoType("btn_search")
	local txt_input = self.view:getChildAutoType("txt_input")
	self.txt_input = BindManager.bindTextInput(txt_input)
	self.list_guild = FGUIUtil.getChild(self.view, "list_guild", "GList")
	
end


function GuildMainView:initMainview(...)
    self:showMainView()
    self:showMainList()
end

function GuildMainView:showMainList()
    local arrInfo = GuildModel.guildList.guildPlayer;
    local info= GuildModel:playersSort(arrInfo);
    local infoMap= GuildModel.guildList.memberMap;
	self.mainlist_guildPlayer:setVirtual()
    self.mainlist_guildPlayer:setItemRenderer(
        function(index, obj)
            local playerId =info[index + 1]
            local itemInfo =infoMap[playerId];
            local sex=obj:getChildAutoType("sex")
            sex:setURL(PathConfiger.getGuildHeroSexIcon(itemInfo.sex or 1));
            local headItem=obj:getChild("headItem")
            local heroItem = BindManager.bindPlayerCell(headItem)
            heroItem:setHead(itemInfo.icon, itemInfo.level,nil,nil,itemInfo.headBorder)
            local txt_name = obj:getChild("txt_name")
            txt_name:setText(itemInfo.name)
            local post = obj:getChild("post")
            post:setText(GuildModel:getGuildPosition(itemInfo.position))
            local money = obj:getChild("money")
            money:setText(itemInfo.activeScore)
            local txt_online = obj:getChild("txt_online")
            local txt_noonlinetime = obj:getChild("txt_noonlinetime")
            local c1= obj:getController("c1")
            if itemInfo.onlineState==1 then
                c1:setSelectedIndex(0)
                txt_online:setText(Desc.chatView_str22)
            else
                c1:setSelectedIndex(1)
                local online = GuildModel:getGuildOnline(itemInfo)
                txt_noonlinetime:setText(online)
            end
             local fight = obj:getChild("fight")
             fight:setText(StringUtil.transValue(itemInfo.combat))
            local com_xialaList= obj:getChild("com_xialaList")
            local com_xialaListBtn=com_xialaList:getChild("n5")
            local pos = GuildModel.guildList["myGuildPosition"]
            local listData ,listValue=  GuildModel:getPostionPromotionBtn(pos);
            if #listData==0 then
                com_xialaList:setVisible(false);
            else
                com_xialaList:setVisible(true);
                com_xialaList:setItems(listData) ;
                com_xialaList:setValues(listValue);
                com_xialaList:setIcons({'Icon/guild/guildcomBox2.png','Icon/guild/guildcomBox1.png','Icon/guild/guildcomBox3.png','Icon/guild/guildcomBox4.png'});
                com_xialaList:setSelectedIndex(0);
                com_xialaList:removeEventListener(FUIEventType.Changed);
                com_xialaList:addEventListener(FUIEventType.Changed,function( context )
                local value= tonumber(com_xialaList:getValue());
                com_xialaListBtn:setSelected(false);
                if (value == 11) then --提升职位
                    local playerId =itemInfo.playerId
                    local position =itemInfo.position
                    GuildModel:setMemberPosition(playerId, position - 1,1,itemInfo.name)
                elseif (value == 12) then --降低职位
                    local playerId =itemInfo.playerId
                    local position =itemInfo.position
                    GuildModel:setMemberPosition(playerId, position + 1,2,itemInfo.name)
                elseif (value == 13) then --任命会长
                    local info = {}
                    info.text = Desc.guild_checkStr19..itemInfo.name..Desc.guild_checkStr20
                    info.type = "yes_no"
                    info.mask = true
                    info.onYes = function()
                        local playerId = itemInfo.playerId
                        GuildModel:transferLeader(playerId,itemInfo.name)
                    end
                    Alert.show(info)
                elseif (value == 14) then --踢出公会
                    local info = {}
                    info.text = Desc.guild_checkStr21..itemInfo.name..Desc.guild_checkStr22
                    info.type = "yes_no"
                    info.mask = true
                    info.onYes = function()
                        local playerId = itemInfo.playerId
                        GuildModel:kickMember(playerId,itemInfo.name)
                    end
                    Alert.show(info)
                end
                end);
            end
            local btn_money= obj:getChild("btn_money")
            btn_money:removeClickListener(100)
            btn_money:addClickListener(
                function(...)
                   RollTips.show(Desc.guild_checkStr33..itemInfo.activeScore)
                end,
                100
            )
            local btn_head= obj:getChild("btn_head")
            headItem:removeClickListener(100)
            headItem:addClickListener(
                function(...)
                    ViewManager.open("ViewPlayerView",{playerId = itemInfo.playerId})
                end,
                100
            )
            btn_head:removeClickListener(100)
            btn_head:addClickListener(
                function(...)
                    ViewManager.open("ViewPlayerView",{playerId = itemInfo.playerId})
                end,
                100
            )
        end
    )
    self.mainlist_guildPlayer:setNumItems(#info)
end

function GuildMainView:showMainView()
    local info = GuildModel.guildList
    self.mainimg_head:setURL(GuildModel:getGuildHead(info.icon))
    local posTion = GuildModel.guildList.myGuildPosition
    self.mainbtn_editNotice:setVisible(GuildModel:getPostionNoticeBtn(posTion))
    self.maintxt_guildName:setText(info.name)
    local bianhao = self.view:getChildAutoType("txt_bianhao")
    bianhao:setText(info.id)
    self.maintxt_level:setText(Desc.guild_checkStr18..info.level)
    local configInfo = DynamicConfigData.t_guildLevel[info.level+1]
    if configInfo==nil then
        configInfo=DynamicConfigData.t_guildLevel[info.level]
    end
    local maxExp = configInfo.exp
    local curGuildconfig=DynamicConfigData.t_guildLevel[info.level]
    printTable(10,'>>>>>>>>>>>>>>>>>>>>;;;;asdfaf',maxExp,info.exp)
    self.mainpg_exp:setMax(maxExp)
    self.mainpg_exp:setValue(info.exp)
    self.maintxt_vitality:setText(info.activeScore)
    local maxNum = curGuildconfig.limitNum
    self.maintxt_playerNum:setText(info.memberNum .. "/" .. maxNum)
    self.maintxt_masterName:setText(info.leaderName)
    self.maintxt_notice:setText(info.notice)
end

function GuildMainView:initDynamicView(...)
    local info = GuildModel.guildRecord;
	self.recordList:setVirtual()
	self.recordList:setItemRenderer(
		function(index, obj)
			local item = GuildModel.guildRecord[index + 1];
			local text1= obj:getChild('n7')
            text1:setText(item.str);
            local timeLabel= obj:getChild('n14')
			timeLabel:setText(string.format(self.timeStr, self.msToString(item.info.timeStamp*1000, self.format_normal)))
			local timeLabel1= obj:getChild('n13')
            timeLabel1:setText(string.format(self.timeStr, self.msToString(item.info.timeStamp*1000, self.format_normal1)))
			-- btn_sure:removeClickListener(100)
			-- btn_sure:addClickListener(
			--     function(...)
			--     end,
			--     100
			-- )
		end
	)
	self.recordList:setNumItems(#info)
	if #info > 6 then
		self.recordList:scrollToView(#info-1, true, true)
	end
end

function GuildMainView:initMembershipView(...)
	self:showMembershipText();
	self:showMembershipList();
end

function GuildMainView:showMembershipText( ... )
	local info=GuildModel.guildList;
	local configInfo=DynamicConfigData.t_guildLevel[info.level];
	local maxNum=configInfo.limitNum
	self.membership_guildNum:setText(ColorUtil.formatColorString1(info.memberNum, "#6aff60")..'/'..maxNum)
	local List=GuildModel.guildApplyList or {}
	local  maxApplyNum ,createCost ,renameCost= GuildModel:getGuildCreateCost();
	self.Membership_agreedNum:setText(ColorUtil.formatColorString1(#List, "#6aff60")..'/'..maxApplyNum);
end

function GuildMainView:showMembershipList( ... )
    local info=GuildModel.guildApplyList
    printTable(8,'>>>>>>>>>>>>>>>>打印的list',info)
	self.Membership_guildPlayer:setItemRenderer(
        function(index, obj)
            local recommend=GuildModel.guildApplyList;
            local info=recommend[index+1];
            local playerHead = obj:getChildAutoType("playerHead")
            local heroItem = BindManager.bindPlayerCell(playerHead)
            heroItem:setHead(info.icon, info.level,nil,nil,info.headBorder)
            local sex=obj:getChildAutoType("sex")
            sex:setURL(PathConfiger.getGuildHeroSexIcon(info.sex or 1));
            local txt_name= obj:getChild('txt_name')  
            txt_name:setText(info.playerName);
            local txt_contribution= obj:getChild('txt_contribution')  
            txt_contribution:setText(StringUtil.transValue(info.combat));
		   local btn_no=obj:getChild('btn_no')
		   btn_no:removeClickListener(100)
		   btn_no:addClickListener(
                function(...)
					local item=recommend[index+1];
					GuildModel:acceptJoinGuild(item.playerId,2);
                end,100
			)
			local btn_sure=obj:getChild('btn_sure')
			btn_sure:removeClickListener(100)
            btn_sure:addClickListener(
                function(...)
                    local item=recommend[index+1];
					GuildModel:acceptJoinGuild(item.playerId,1);
                end,100
            )
        end
    )
    if #info>0 then
        self.membership_Ctr:setSelectedIndex(0)
    else
        self.membership_Ctr:setSelectedIndex(1)
    end
    self.Membership_guildPlayer:setNumItems(#info)
end

function GuildMainView:initRecommend(  )
	local recommend=GuildModel.recommendedguildlist;
	self.list_guild:setVirtual()
	self.list_guild:setItemRenderer(
		function(index, obj)
			local recommend=GuildModel.recommendedguildlist;
			local info=recommend[index+1];
			local guildIcon= obj:getChild('icon')
			guildIcon:setURL(GuildModel:getGuildHead(info.icon))
			local txt_name= obj:getChild('txt_name')  
			txt_name:setText(info.name);
			local txt_lv= obj:getChild('txt_lv')  
			txt_lv:setText(Desc.guild_checkStr18..info.level);
			local configInfo=DynamicConfigData.t_guildLevel[info.level];
			local maxNum=configInfo.limitNum
			local txt_num= obj:getChild('txt_num')  
			txt_num:setText(ColorUtil.formatColorString1(info.memberNum,"#3794ff")..'/'..maxNum);
			local txt_contribution= obj:getChild('txt_contribution')  
			txt_contribution:setText(info.activeScore);
			obj:removeClickListener(100)
			obj:addClickListener(
				function(...)
					local item=recommend[index+1];
                    ViewManager.open("GuildApplyView",{item,2})
                    GuildModel:serchGuildById(item.id)
				end,100
			)
		end
    )
    if #recommend>0 then
        self.recommend_Ctr:setSelectedIndex(0)
    else
        self.recommend_Ctr:setSelectedIndex(1)
    end
    self.list_guild:setNumItems(#recommend)
end


--工会基础信息刷新刷新
function GuildMainView:guild_up_guildBaseInfoPosTion()
    local posTion = GuildModel.guildList.myGuildPosition
    self:showManagerBtns(posTion)
end

--工会基础信息刷新刷新
function GuildMainView:guild_up_guildBaseInfo()
	self:showMainView()
end
--工会成员刷新
function GuildMainView:guild_up_guildPlayerList()
	self:showMainList()
end

--公会动态刷新
function GuildMainView:guild_up_recordList()
    local info = GuildModel.guildRecord;
    self:initDynamicView()
	self.recordList:setNumItems(#info)
end

--公会申请列表刷新
function GuildMainView:guild_up_ApplyList( ... )
	self:showMembershipText();
    local info=GuildModel.guildApplyList
    if #info>0 then
        self.membership_Ctr:setSelectedIndex(0)
    else
        self.membership_Ctr:setSelectedIndex(1)
    end
	self.Membership_guildPlayer:setNumItems(#info)
end

--公会查找列表刷新
function GuildMainView:guild_up_recommendedList(_, id)
local recommend=GuildModel.recommendedguildlist;
if #recommend>0 then
    self.recommend_Ctr:setSelectedIndex(0)
else
    self.recommend_Ctr:setSelectedIndex(1)
end
self.list_guild:setNumItems(#recommend)
end


--事件初始化
function GuildMainView:_initEvent(...)
    self.mainbtn_manager:addClickListener(
        function(...)
            ViewManager.open("GuildManageListView")
        end
    )
    self.mainbtn_editNotice:addClickListener(
        function(...)
            ViewManager.open("GuildEditNoticeView")
        end
    )

	self.Membership_agreed:addClickListener(function ( ... )--管理按钮
		GuildModel.guildAllagreed()
	end)	
    self.Membership_ignore:addClickListener(function ( ... )--管理按钮
		GuildModel.guildAllignor()
	end)	
	
	self.btn_refresh:addClickListener(
        function(...)
            GuildModel:getRecommendGuild(GuildModel.guildRecommendIndex+1);
        end
	)
	self.btn_search:addClickListener(
        function(...)
            local str = self.txt_input:getText();
            GuildModel:serchGuildByName(str);
        end
    )
end




--initEvent后执行
function GuildMainView:_enter(...)
end

--页面退出时执行
function GuildMainView:_exit(...)
end

-------------------常用------------------------

return GuildMainView
