--added by wyang 公会大厅
local GuildskillsView, Super = class("GuildskillsView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local moneyComp = require "Game.UI.Global.moneyComp"
function GuildskillsView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildskillsView"
    self._rootDepth = LayerDepth.Window

    self.btn_reset = false
    self.btn_agreed = false
    self.list_professional = false
    self.list_card = false
    self.list_attr = false
    self.img_contribution = false
    self.txt_guildNum = false
    self.txt_contribution = false
    self.txt_gold = false
    -- self.txt_cost = false
    -- self.txt_cost1 = false
    -- self.txt_resetgold = false
    self.heroInfo = false
    -- self.img_cost = false
    -- self.img_cost1 = false
    -- self.img_resetgold=false
    self.membership_Ctr=false
    self.btn_full=false
    self.img_gold=false
    self.curId=1
    self.costFull=false;
    self.moneyComp=false
    self.itemcell=false
    self.costItem = false
    self.costItem1 =false
    self.costItem2 =false
    self.upgradeCost=false
end

-------------------常用------------------------
--UI初始化
function GuildskillsView:_initUI(...)
    self:setBg("bg_guildSkills.jpg");
    local viewRoot= self.view
    self.membership_Ctr=viewRoot:getController('c1');
    self.btn_reset = viewRoot:getChild("btn_reset")
    self.btn_agreed = viewRoot:getChild("btn_agreed")
    self.list_professional = viewRoot:getChild("list_professional")
    self.list_card = viewRoot:getChild("list_card")
    self.list_attr = viewRoot:getChild("list_attr")
    self.img_contribution = viewRoot:getChild("img_contribution")
    self.txt_guildNum = viewRoot:getChild("txt_guildNum")
    self.txt_contribution = viewRoot:getChild("txt_contribution")
    self.img_gold = viewRoot:getChild("img_gold")
    self.txt_gold = viewRoot:getChild("txt_gold")
    -- self.txt_cost = viewRoot:getChild("txt_cost")
    -- self.txt_cost1 = viewRoot:getChild("txt_cost1")
    -- self.txt_resetgold = viewRoot:getChild("txt_resetgold")
    -- self.img_cost = viewRoot:getChild("img_cost")
    -- self.img_cost1 = viewRoot:getChild("img_cost1")
    -- self.img_resetgold = viewRoot:getChild("img_resetgold")
    self.btn_full = viewRoot:getChild("btn_full")
    local costItem = viewRoot:getChild("costItem")
    local costItem1 = viewRoot:getChild("costItem1")
    local costItem2 = viewRoot:getChild("costItem2")
    self.costItem = BindManager.bindCostItem(costItem)
    self.costItem1 = BindManager.bindCostItem(costItem1)
    self.costItem2 = BindManager.bindCostItem(costItem2)
    self.moneyComp = viewRoot:getChild("moneyComp") 
    -- self.itemcell = moneyComp.new(self.moneyComp)
    local value=  PlayerModel:getMoneyByType(6)
    -- self.itemcell:isShowFirstMoney(true)
    -- self.itemcell:showFirstMoney(6,value)
	self.showMoneyType = {
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.GuildContri},
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		} --显示的货币类型，从左到右排列
    self.moneyBar = BindManager.bindMoneyBar(self.moneyComp)
    self.moneyBar:setData(self.showMoneyType)
    self:initList()
end

function GuildskillsView:initList(...)
    self.heroInfo = GuildModel:getguildskillInfo()
    local temp = {}
    local configInfo=DynamicConfigData.t_guildSkill
    for key, value in pairs(configInfo) do
        temp[#temp + 1] = key
    end
    table.sort(temp,function(a,b)
        return a<b
    end)
    self.list_professional:setItemRenderer(
        function(index, obj)
            local id = temp[index + 1]
            local skillLV = GuildModel:getguildskillLevel(id)
            local level = obj:getChild("level")
            level:setText(skillLV ..Desc.guild_checkStr28)
            --local title = obj:getChild("title")
            --title:setText(GuildModel:getGuildskillTypeName(id))
            --local iconUrl = GuildModel:getGuildProfessionalIcon(id)
            --local icon = obj:getChild("icon")
            --icon:setURL(iconUrl)
            local red=  RedManager.getTips("V_Guild_SKILLITEM"..id);
            if red==nil then
                  red=false
            end
            printTable(152,"2222222QQQQQQQQQQQQQ1111111",red,id)
            local img_red= obj:getChild('img_red')
            img_red:setVisible(red)
            --RedManager.register("V_Guild_SKILLITEM"..id,img_red , ModuleId.Guild.id )

            if id == self.curId then
                self.curId=id
                obj:setSelected(true);
                self:showListView(id)
            else
                obj:setSelected(false);
            end
            obj:removeClickListener(100)
             --池子里面原来的事件注销掉
            obj:addClickListener(
                function(...)
                    -- RedManager.updateValue("V_Guild_SKILLITEM"..id, false);  
                    -- GuildModel:setguildFirstLoginState("GuildSkillRed"..id)
                    local id = temp[index + 1];
                    self.curId=id
                    self:showListView(id)
                end,
                100
            )
        end
    )
    self.list_professional:setNumItems(#temp)
end

function GuildskillsView:showListView(id)
    self:showHeroList(id);
    self:showAttrList(id);
    self:showPerksSkill(id);
    self:showCost(id);
end

function GuildskillsView:showPerksSkill(id)--公会被动技能
    local skillMap= GuildModel:getCurskillId(id)
    printTable(31,"11111111112",skillMap)
    for i = 1, #skillMap, 1 do
        local skillCell= self.view:getChildAutoType("$skillCel"..i) 
        local skillCel= skillCell:getChildAutoType("skillCel") 
        local arrInfo=skillMap[i]
        local skillId=arrInfo["skillId"]
        local isLock=arrInfo["isLock"]
        local conf = DynamicConfigData.t_skill[skillId];
        local cell = BindManager.bindSkillCell(skillCel)
        cell:setData(skillId)
        skillCel:removeClickListener(100);
         local lockCtrl = cell.view:getController("lockCtrl")
         if isLock==false then
            lockCtrl:setSelectedIndex(0)
         else
            lockCtrl:setSelectedIndex(1)
         end
         skillCel:addClickListener(function ()
            if conf then
                ViewManager.open("ItemTips", {codeType = CodeType.GUIILD_SKILL,guild=id, id = skillId,data = conf})
            end
        end,100)
        local lv= GuildModel:getCurskillLv(id,skillId)
        local txt_skillName= skillCell:getChildAutoType("txt_skillName") 
        if isLock==true then
           local str= DynamicConfigData.t_skill[skillId].unlock
            txt_skillName:setText(ColorUtil.formatColorString1(str,"#F43636"))   
        else
            txt_skillName:setText(ColorUtil.formatColorString1("Lv."..lv,"#282D36"))  
        end
    end
end

function GuildskillsView:showCost(id)
    local curLv= GuildModel:getguildskillLevel(id)
    local ConfigInfo=DynamicConfigData.t_guildSkill[id]
    local configCost= ConfigInfo[curLv+1]
    if configCost==nil then
        self.membership_Ctr:setSelectedIndex(1)
        return;
    else
        self.membership_Ctr:setSelectedIndex(0)
    end
    local curCost=configCost.cost;  
    self.upgradeCost=curCost
    self.costItem:setData(curCost[1].type, curCost[1].code, curCost[1].amount, true)
    self.costItem1:setData(curCost[2].type, curCost[2].code, curCost[2].amount, true)
    self.costItem2:setData(2, 2, 20, true)
    -- local iconUrl =  ItemConfiger.getItemIconByCodeAndType(2,curCost[1].code)
    -- local iconUrl1 =  ItemConfiger.getItemIconByCodeAndType(2,curCost[2].code)
    local has1=  PlayerModel:getMoneyByType(curCost[1].code)
    local has2=  PlayerModel:getMoneyByType(curCost[2].code)
    -- local color=ColorUtil.itemColorStr[1]
    -- local color2=ColorUtil.itemColorStr[1]
    -- if has1<curCost[1].amount then
    --     color=ColorUtil.itemColorStr[6]
    -- end
    -- if has2<curCost[2].amount then
    --     color2=ColorUtil.itemColorStr[6]
    -- end
    if has1<curCost[1].amount or has2<curCost[2].amount then
        self.btn_agreed:setGrayed(true);
        self.costFull=false
    else
        self.btn_agreed:setGrayed(false);
        self.costFull=true
    end
    -- self.txt_cost:setText(ColorUtil.formatColorString(curCost[1].amount, color));
    -- self.txt_cost1:setText(ColorUtil.formatColorString(curCost[2].amount, color2));
    -- self.img_cost:setURL(iconUrl) 
    -- self.img_cost1:setURL(iconUrl1)
    -- local iconUrl2 =  ItemConfiger.getItemIconByCodeAndType(2,2)
    -- self.img_resetgold:setURL(iconUrl2);
    -- self.txt_resetgold:setText(20);
    -- local type= GameDef.MoneyType.GuildContri
    -- local Contri=  PlayerModel:getMoneyByType(type)
    -- local ContriUrl =  ItemConfiger.getItemIconByCodeAndType(2,type)
    -- self.txt_contribution:setText(Contri)
    -- self.img_contribution:setURL(ContriUrl)
    -- local Contri1=  PlayerModel:getMoneyByType(1)
    -- local ContriUrl1 =  ItemConfiger.getItemIconByCodeAndType(2,1)
    -- self.txt_gold:setText(Contri1)
    -- self.img_gold:setURL(ContriUrl1)
end

function GuildskillsView:showAttrList(id)
    local curLv= GuildModel:getguildskillLevel(id)
    local ConfigInfo=DynamicConfigData.t_guildSkill[id]
    local configCurAttr={}
    if ConfigInfo[curLv]==nil then
        configCurAttr=ConfigInfo[curLv+1].attribute;
    else
        configCurAttr=ConfigInfo[curLv].attribute;
    end
    local curAttr={}
    local curIdex=1
    for key, value in pairs(configCurAttr) do
        if tonumber(key)<=3 then 
            local pos=(2*tonumber(key)-1)
            -- table.insert(curAttr,pos,value)
            curAttr[pos] = value
        else
            -- table.insert(curAttr,curIdex*2,value)
            curAttr[curIdex*2] = value
            curIdex=curIdex+1
        end
    end
    local configNextAttr={}  ;
    if ConfigInfo[curLv+1]==nil then
        configNextAttr=ConfigInfo[curLv].attribute
    else
        configNextAttr=ConfigInfo[curLv+1].attribute
    end
    printTable(9,'>>>>>>>>>>>111',curAttr)
    local nextAttr={}
    local nextIdex=1
    for key, value in pairs(configNextAttr) do
        if tonumber(key)<=3 then 
            --table.insert(nextAttr,(2*tonumber(key)-1),value)
            nextAttr[(2*tonumber(key)-1)]=value;
        else
            --table.insert(nextAttr,nextIdex*2,value)
            nextAttr[nextIdex*2]=value;
            nextIdex=nextIdex+1
        end
    end
    self.list_attr:setItemRenderer(function(index,obj)
        obj:removeClickListener()--池子里面原来的事件注销掉
        local value = curAttr[index + 1]
        local next = nextAttr[index + 1]
        local zero= curAttr[index + 1].value
        if curLv==0 then
            zero=0;
        else
            zero=value.value;
        end
        local curTxt = obj:getChild("n0")
        local addTxt = obj:getChild("n1")
        local attrName=GMethodUtil:getFightAttrName(value.id)
        printTable(9,'>>>>>>>',attrName)
        curTxt:setText(GMethodUtil:getFightAttrName(value.id))
        local add=next.value-zero;
        local attrValue=GMethodUtil:getFightAttrName(value.id,zero)
        local str= CardLibModel:formatColorString( attrValue,'#FFFFFF')
        local attrAdd=GMethodUtil:getFightAttrName(value.id,add)
        local str1=CardLibModel:formatColorString('(+'..attrAdd..')','#1DF140')
        if add>0 then
            addTxt:setText(str..str1)
        else
            addTxt:setText(str)
        end
		end
	)
	self.list_attr:setNumItems(#curAttr);
end

function GuildskillsView:showHeroList(id)
     local heroList=  self.heroInfo[id]
     if heroList and next(heroList)~=nil  then
        table.sort(heroList,function(a,b)
            if a.has==b.has then
                if  a.has==true then
                    if a.heroStar==b.heroStar then
                       return a.heroId<b.heroId
                    else
                        return a.heroStar>b.heroStar
                    end
                end
                return a.heroId<b.heroId
            else
                return  a.has;
            end
        end)
     end
     --printTable(9,'///////',heroList.heroId,heroList.heroName)
     self.list_card:setItemRenderer(function(index,obj)
        obj:removeClickListener()--池子里面原来的事件注销掉
        local heroItem= heroList[index+1];
        local cardItem = BindManager.bindCardCell(obj)
		if heroItem.fashion then
			local a = 1
		end
        cardItem:setData(heroItem, true)
        if heroItem and heroItem.has==false then
        cardItem:setSelected(5);
        else
        cardItem:setSelected(0);
        end
        printTable(9,'///////',heroItem.heroId,heroItem.heroName,heroItem.category,heroItem.heroStar)
     end
)
local count=0;
if heroList and next(heroList)~=nil then
   count=#heroList
end
self.list_card:setNumItems(count);
end

function GuildskillsView:money_change()--货币更新
    GuildModel:setGuildSkillRed()--公会技能红点
end


function GuildskillsView:guild_up_guildSkillupLv(...)
    local temp = {}
    local configInfo=DynamicConfigData.t_guildSkill
    for key, value in pairs(configInfo) do
        temp[#temp + 1] = key
    end
    self.list_professional:setNumItems(#temp)
    self:showAttrList(self.curId);
    self:showCost(self.curId);
end


function GuildskillsView:guild_up_guildSkillResetLv(...)
    local temp = {}
    local configInfo=DynamicConfigData.t_guildSkill
    for key, value in pairs(configInfo) do
        temp[#temp + 1] = key
    end
    self.list_professional:setNumItems(#temp)
    self:showAttrList(self.curId);
    self:showCost(self.curId);
end

--事件初始化
function GuildskillsView:_initEvent(...)
    local help= self.view:getChildAutoType("frame"):getChildAutoType("btn_help");
    help:removeClickListener()
    help:addClickListener(
        function(...)
            local info={}
            info['title']=Desc.help_StrTitle8
            info['desc']=Desc.help_StrDesc8
            ViewManager.open("GetPublicHelpView",info) 
        end
    )
    self.btn_full:addClickListener(
        function(...)
          RollTips.show(Desc.guild_checkStr29)
        end
    )
    self.btn_agreed:addClickListener(
        function(...)
            if   self.costFull==true then
                GuildModel:skillLevelUp(self.curId)
            else
                ModelManager.PlayerModel:isCostEnough(self.upgradeCost)
                -- RollTips.show(Desc.guild_checkStr30)
            end
        end
    )
    self.btn_reset:addClickListener(
        function(...)
            local enough=ModelManager.PlayerModel:isCostEnough({{type =GameDef.GameResType.Money, code = 2, amount=20}})
        if  enough then
            local skillName=   GuildModel:getGuildskillTypeName(self.curId)
                local  maxApplyNum ,createCost ,renameCost= GuildModel:getGuildCreateCost();
                local info = {}
                info.text = Desc.CohesionReward_str79..GMethodUtil.getRichTextMoneyImgStr(2) ..ColorUtil.formatColorString1(20, "#6AFF60")..Desc.guild_checkStr31..skillName..Desc.guild_checkStr32
                info.type = "yes_no"
                info.mask = true
                info.onYes = function()
                GuildModel:skillReset(self.curId)
                end
                info.align = 'left';
                info.title = Desc.CohesionReward_str80
                Alert.show(info)
            end   
        end
    )
end

--initEvent后执行
function GuildskillsView:_enter(...)
end

--页面退出时执行
function GuildskillsView:_exit(...)
    self.curId=1
    -- self.itemcell:clearEventListeners()
end

-------------------常用------------------------

return GuildskillsView
