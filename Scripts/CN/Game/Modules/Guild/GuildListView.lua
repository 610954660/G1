--added by wyang 公会列表
local GuildListView, Super = class("GuildListView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildListView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildListView"
    self._rootDepth = LayerDepth.Window
    self.curHeadId = 1
    self.btn_refresh = false
    self.btn_create = false
    self.btn_search = false
    self.txt_createInput = false
    self.list_guild = false
    self.btn_changeHead = false
    self.txt_input = false
    self.btn_cancel = false
    self.img_head = false
    --self.img_createCost=false
    self.txt_createCost=false
    self.pageCtrl=false
end

-------------------常用------------------------
--UI初始化
function GuildListView:_initUI(...)
    self:centerScreen()
    self:setBg("handbook_hero.jpg")
    self.list_creat=self.view:getChildAutoType("list_creat")
    local createGuild = self.view:getChild("createGuild")
    self.btn_changeHead = createGuild:getChildAutoType("btn_changeHead")
    local txt_createInput = createGuild:getChildAutoType("txt_input")
    self.txt_createInput = BindManager.bindTextInput(txt_createInput)
    self.txt_createInput:setMaxLength(6)
    self.btn_cancel = createGuild:getChildAutoType("btn_cancel")
    self.btn_create = createGuild:getChildAutoType("btn_create")
    self.img_head = createGuild:getChildAutoType("img_head")
    --self.img_createCost = createGuild:getChildAutoType("img_cost")
    self.txt_createCost = createGuild:getChildAutoType("txt_createCost")
    --推荐公会列表
    self.pageCtrl = self.view:getController("c2")
    self.btn_refresh = self.view:getChildAutoType("btn_refresh")
    self.btn_search = self.view:getChildAutoType("btn_search")
	local txt_input = self.view:getChildAutoType("txt_input")
	self.txt_input = BindManager.bindTextInput(txt_input)
    self.list_guild = FGUIUtil.getChild(self.view, "list_guild", "GList")
    
    self.list_creat:addEventListener(FUIEventType.ClickItem,function( context )
		local cindex= self.list_creat:getChildIndex(context:getData())
        local index = self.list_creat:childIndexToItemIndex(cindex)+1;
		if index==1 then
            GuildModel:getRecommendGuild(1);
        end
	end);
    self:showView()
	
end

function GuildListView:showView(...)
    self.img_head:setURL(GuildModel:getGuildHead(self.curHeadId))
    local recommend=GuildModel.recommendedguildlist;
    local  maxApplyNum ,createCost ,renameCost= GuildModel:getGuildCreateCost();
    self.txt_createCost:setText(createCost);
    --self.img_createCost:setURL('')
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
            txt_lv:setText(string.format("%s%s",info.level,Desc.CohesionReward_str29));
            local configInfo=DynamicConfigData.t_guildLevel[info.level];
            local maxNum=configInfo.limitNum
            local txt_num= obj:getChild('txt_num')
            if info.memberNum==nil then
                txt_num:setText(ColorUtil.formatColorString1("0","#3794ff").."/"..maxNum);
                else
                txt_num:setText(ColorUtil.formatColorString1(info.memberNum,"#3794ff") .."/"..maxNum);
            end  
            local txt_contribution= obj:getChild('txt_contribution')  
            txt_contribution:setText(info.activeScore);
            obj:removeClickListener(100)
            obj:addClickListener(
                function(...)
                    local item=recommend[index+1];
                    ViewManager.open("GuildApplyView",{item,1})
                    GuildModel:serchGuildById(item.id)
                end,100
            )
        end
    )
    if #recommend>0 then
        self.pageCtrl:setSelectedIndex(0)
    else
        self.pageCtrl:setSelectedIndex(1)
    end
    self.list_guild:setNumItems(#recommend)
end

--事件初始化
function GuildListView:_initEvent(...)
    self.btn_refresh:addClickListener(
        function(...)
            GuildModel:getRecommendGuild(GuildModel.guildRecommendIndex+1);
        end
    )
    self.btn_changeHead:addClickListener(
        function(...)
            ViewManager.open("GuildHeadView", {self.curHeadId})
        end
    )

   --[[ self.btn_cancel:addClickListener(
        function(...)
            self:closeView()
        end
    )--]]

    self.btn_create:addClickListener(
        function(...)
			if (StringUtil.isOnlyNumberOrCharacter(self.txt_createInput:getText())) then
				RollTips.show(Desc.input_tips2);
				return;
            end
            
            local newText=StringUtil.filterString(self.txt_createInput:getText())
            if newText ~= self.txt_createInput:getText() then  
                RollTips.show(Desc.input_tips3); 
                return 
            end


            local  maxApplyNum ,createCost ,renameCost= GuildModel:getGuildCreateCost();
            local info = {}
            info.text =Desc.CohesionReward_str30..GMethodUtil.getRichTextMoneyImgStr(2) ..ColorUtil.formatColorString1(renameCost, "#6AFF60")..Desc.CohesionReward_str31
            info.type = "yes_no"
            info.mask = true
            info.onYes = function()
                local str = self.txt_createInput:getText()
                GuildModel:createGuild(str,self.curHeadId);
            end
            Alert.show(info)
        end
    )

    self.btn_search:addClickListener(
        function(...)
            local str = self.txt_input:getText();
            GuildModel:serchGuildByName(str);
        end
    )
end


function GuildListView:guild_up_recommendedList(_, id)
local recommend=GuildModel.recommendedguildlist;
if #recommend>0 then
    self.pageCtrl:setSelectedIndex(0)
else
    self.pageCtrl:setSelectedIndex(1)
end
self.list_guild:setNumItems(#recommend)
end


function GuildListView:guild_up_headId(_, id)
    self.curHeadId = id
    self.img_head:setURL(GuildModel:getGuildHead(id))
end

--initEvent后执行
function GuildListView:_enter(...)
end

--页面退出时执行
function GuildListView:_exit(...)
    --	self.itemcellArrs = {}
    self.txt_input:setText("")
end

-------------------常用------------------------

return GuildListView
