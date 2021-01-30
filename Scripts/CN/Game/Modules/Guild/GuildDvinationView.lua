--added by wyang 公会大厅
local GuildDvinationView, Super = class("GuildDvinationView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
function GuildDvinationView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildDvinationView"
    self._rootDepth = LayerDepth.Window
    self.txt_remaining=false
    self.txt_remaining1=false
    self.itemList={}
    self.timeContro=false
    self.timeContro1=false
    self.txt_qipao=false
    self.btn_divination=false
    self._updateTimeId={}
    self.animationList={}
    self.postion={{-280,-60,-180},{-230,100,-145},{-90,200,-145},{105,200,-45},{243,100,-45},{298,-70,45}}
    self.animatioanIng=false
end

-------------------常用------------------------
--UI初始化
function GuildDvinationView:_initUI(...)
    local viewRoot=self.view;
    self.txt_remaining=viewRoot:getChild('txt_remaining')
    self.txt_remaining1=viewRoot:getChild('txt_remaining1')
    self.txt_extra=viewRoot:getChild('txt_extra') 
    self.img_reward=viewRoot:getChild('img_reward') 
    self.txt_rewardnum=viewRoot:getChild('txt_rewardnum') 
    self.com_tishengshouqi=viewRoot:getChild('com_tishengshouqi') 
    self.txt_upluck=self.com_tishengshouqi:getChild('txt_upluck') 
    self.bar_luck = self.view:getChildAutoType("bar_luck")
    self.btn_sure=viewRoot:getChild('btn_sure') 
    self.btn_luck=viewRoot:getChild('btn_luck') 
    self.btn_divination=viewRoot:getChild('btn_divination') 
    self.timeContro = viewRoot:getController("c1")
    self.timeContro1 = viewRoot:getController("c2")
    self.txt_qipao= viewRoot:getChild("txt_qipao")
    self.com_face= viewRoot:getChild("com_face")
    self.txt_luck=self.com_face:getChild('txt_luck') 
    self.img_shouqi=self.com_face:getChild('img_shouqi') 
    self.btn_faceclose = viewRoot:getChild("btn_faceclose")  
    self.img_ball=viewRoot:getChild("img_ball")  
    self.img_tiao=viewRoot:getChild("img_tiao")  
    self:playAniMation(self.img_ball,4,{0,0})
    GuildModel:setFrameViewBg(viewRoot,GuildModel:getDvinationBg())
    self:showView()
end
 
function GuildDvinationView:_addRed(...)
    local img_red=self.view:getChild('img_red')
    RedManager.register( "V_Guild_DIVINATIONRED" ,img_red , ModuleId.Guild.id )
end

function GuildDvinationView:showView(isPlay)
    local serverInfo= GuildModel.guildGuildDivunation;
    printTable(22,'占卜的数据',serverInfo)
    if  next(serverInfo)==nil then
        return 
    end
    local divinationCount,retryCount =GuildModel:getGuildDivinationCount();
    local color="#6AFF60"
    local color1="#6AFF60"
    if divinationCount==0 then
        color="#ff6464"
    end
    if retryCount==0 then
        color1="#ff6464"
    end
    if tolua.isnull(self.txt_remaining) then
        return
    end
    self.txt_remaining:setText(ColorUtil.formatColorString1(divinationCount,color))
    self.txt_remaining1:setText(ColorUtil.formatColorString1(retryCount,color1) )
    local cellNum=serverInfo.cellNum
    local configInfo= DynamicConfigData.t_divination[cellNum]
    if configInfo then
        local iconUrl = PathConfiger.getMoneyIcon(configInfo.extraReward[1].code) --ItemConfiger.getItemIconByCodeAndType(configInfo.extraReward[1].type, configInfo.extraReward[1].code)
        self.img_reward:setURL(iconUrl)
        self.txt_rewardnum:setText(configInfo.extraReward[1].amount)
    else
        local configInfoNo=DynamicConfigData.t_divination[1]
        local iconUrl =PathConfiger.getMoneyIcon(configInfoNo.extraReward[1].code)-- ItemConfiger.getItemIconByCodeAndType(2,5)
        self.img_reward:setURL(iconUrl)
        self.txt_rewardnum:setText('0')
    end
    local curReward=serverInfo.cellRewardMap
    for i = 1, 6, 1 do
        local cellItem=self.view:getChild("itemCell"..i)
        local cell=cellItem:getChild("itemCell")
        local gCtr=cellItem:getController("c1");
        local itemInfo=curReward[i];
        if  itemInfo==nil then
            gCtr:setSelectedIndex(0)
        else
            local txt_num=cellItem:getChildAutoType("txt_num")
            local amount=itemInfo.rewardList[1].amount
            txt_num:setText(amount.."")
            if isPlay and isPlay.tag==true and  i>isPlay.num then
                gCtr:setSelectedIndex(0)
            else
                gCtr:setSelectedIndex(1)
            end
            local itemcell = BindManager.bindItemCell(cell)
            local itemData = ItemsUtil.createItemData({data = itemInfo.rewardList[1]})
            itemcell:setItemData(itemData)
            printTable(12,"dasfeqwinIodsfadInfowsdaf",itemData)
            local qulityUrl=GuildModel:getQualityFrame(itemData.__itemInfo.color)
            itemcell:setFrameVisible(false)
            itemcell:setQualityFrameURL(qulityUrl)
            itemcell:setNoFrame(false)--显示品质框
            itemcell:setAmount(0)
            cell:removeClickListener(100)
            cell:addClickListener(function( ... )
            	itemcell:onClickCell()
			end,100)
        end
 end

 if cellNum==0 then
    self.timeContro:setSelectedIndex(0)
 else
    self.timeContro:setSelectedIndex(1)
 end
 local barTitle= self.bar_luck:getChild('title')
 barTitle:setVisible(false)
 self.bar_luck:setMin(0)
 self.bar_luck:setMax(100)
 self.bar_luck:tweenValue(serverInfo.luckyVal, 0.5)
 if serverInfo.luckyVal==100 then
    self:playAniMation(self.img_tiao,3,{0,0})
 else
    if  not tolua.isnull(self.animationList[13]) then
        SpineUtil.clearEffect(self.animationList[13])
    end
 end
 local text,desctext,face= GuildModel:getGuildLuckText(serverInfo.luckyVal);
 self.txt_luck:setTitle(text);
 self.img_shouqi:setURL(face)
 local num=self.txt_qipao:getChild("num")
 num:setText(Desc.guild_checkStr13..serverInfo.luckyVal)
 local desc=self.txt_qipao:getChild("desc")
desc:setText(desctext)
local img_shouqi=self.txt_qipao:getChild("img_shouqi")
img_shouqi:setURL(face)
end


function GuildDvinationView:playAniMation(parent,type,pos,iswin)

    -- for key, value in pairs(self.animationList) do
    --     if tonumber(key) ~=13 and tonumber(key) ~=14 and tonumber(key) ~=15 then
    --         SpineUtil.clearEffect(value)
    --         self.animationList[key]=nil
    --     end
    -- end
    -- for key, value in pairs(self._updateTimeId) do
    --     Scheduler.unschedule(value)
    --     self._updateTimeId[key]=nil
    -- end
    if type==1 then--祈愿特效点击祈愿
        self.animatioanIng=true
        if not self.animationList[7] then
         self.animationList[7]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
        end
        if  tolua.isnull(self.animationList[7]) then
            return
        end
        self.animationList[7]:setAnimation(0, "qiyuan", false)
        self.animationList[7]:setCompleteListener(function(name)
            printTable(26,"sdafdsaf>>>>>>>>sadfa//////",name)
         if name=="qiyuan" then
         end
         end)
           self._updateTimeId[2]  = Scheduler.scheduleOnce(1,function()
            self._updateTimeId[2] = false
            local serverInfo= GuildModel.guildGuildDivunation;
            if  next(serverInfo)==nil then
                return 
            end
            local cellNum=serverInfo.cellNum
            printTable(26,'占卜的数据',cellNum,self.animationList)
            for i = 1,cellNum, 1 do
             if not self.animationList[i] then
                 self.animationList[i]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
               end
            if not self.animationList[30+i] then
                self.animationList[30+i]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
            end
            if tolua.isnull(self.animationList[30+i]) then
                return 
            end
            self.animationList[30+i]:setPosition(cc.p(self.postion[i][1], self.postion[i][2]))
            self.animationList[30+i]:setVisible(false)
                if not tolua.isnull(self.animationList[i])  then
                 self.animationList[i]:setAnimation(0, "feixing", false)
                 self.animationList[i]:setRotation(self.postion[i][3])
                 self.animationList[i]:setVisible(true)
                 self.animationList[i]:setPosition(cc.p(0,0))
                 local action1 = cc.MoveBy:create(0.3, cc.p(self.postion[i][1], self.postion[i][2]))
                 local action2 = cc.CallFunc:create(function()
                 end)
                 local action = cc.Sequence:create(action1,action2)
                 self.animationList[i]:stopAllActions()
                 self.animationList[i]:runAction(action)
                end
            end
            if not self._updateTimeId[1] then
             self._updateTimeId[1]  = Scheduler.scheduleOnce(0.3,function()
                self.animatioanIng=false
                 self._updateTimeId[1] = false
                 for i = 1, cellNum, 1 do
                    if tolua.isnull(self.view) then
                        return
                    end 
                     local cellItem=self.view:getChild("itemCell"..i)
                     local gCtr=cellItem:getController("c1");
                     gCtr:setSelectedIndex(1)
                     if  tolua.isnull(self.animationList[i]) then
                        return
                    end
                     self.animationList[i]:setVisible(false)
                     self.animationList[i]:setPosition(cc.p(0,0))
                     self.animationList[30+i]:setAnimation(0, "baozha", false)
                     self.animationList[30+i]:setVisible(true)
                 end
             end)
          end

           end)
        -- skeletonNode:setEventListener(function(name)
        --  printTable(20,"sdafdsaf",name)
        --  if name=="qiyuan" then
        --      skeletonNode:setAnimation(0, "feixing", false)
        --  elseif name=="feixing" then
        --      skeletonNode:setAnimation(0, "baozha", false)
        --  end
        --  end)
        --  skeletonNode:setCompleteListener(function(name)
        --      printTable(20,"sdafdsaf111111111",name)
        --  end)
        elseif type==2 then--改运特效
            self.animatioanIng=true
            if iswin and iswin.result==true then--改运成功
                printTable(26,"sdafdsaf>>>>>>>>win")
                if not self.animationList[7] then
                    self.animationList[7]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
                   end
                   if tolua.isnull(self.animationList[7]) then
                        return
                    end
                   self.animationList[7]:setAnimation(0, "qiyuan", false)
                   self.animationList[7]:setCompleteListener(function(name)
                    end)
                      self._updateTimeId[2]  = Scheduler.scheduleOnce(1,function()
                       self._updateTimeId[2] = false
                       for i = iswin.old+1,iswin.curNum, 1 do
                        if not self.animationList[i] then
                            self.animationList[i]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
                          end
                            if tolua.isnull(self.animationList[i]) then
                                return
                            end
                       if not self.animationList[30+i] then
                           self.animationList[30+i]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
                       end
                       if tolua.isnull(self.animationList[30+i]) then
                            return
                        end
                       self.animationList[30+i]:setPosition(cc.p(self.postion[i][1], self.postion[i][2]))
                       self.animationList[30+i]:setVisible(false)
                            if not tolua.isnull(self.animationList[i])  then
                            self.animationList[i]:setAnimation(0, "feixing", false)
                            self.animationList[i]:setRotation(self.postion[i][3])
                            self.animationList[i]:setVisible(true)
                            self.animationList[i]:setPosition(cc.p(0,0))
                            local action1 = cc.MoveBy:create(0.3, cc.p(self.postion[i][1], self.postion[i][2]))
                            local action2 = cc.CallFunc:create(function()
                            end)
                            local action = cc.Sequence:create(action1,action2)
                            self.animationList[i]:stopAllActions()
                            self.animationList[i]:runAction(action)
                           end
                       end
                       if not self._updateTimeId[1] then
                        self._updateTimeId[1]  = Scheduler.scheduleOnce(0.3,function()
                            self.animatioanIng=false
							if tolua.isnull(self.view) then return end
                            self._updateTimeId[1] = false
                            for i = iswin.old+1,iswin.curNum, 1 do
                                local cellItem=self.view:getChild("itemCell"..i)
                                local gCtr=cellItem:getController("c1");
                                gCtr:setSelectedIndex(1)
                                if  tolua.isnull(self.animationList[i]) then
                                    return
                                end
                                self.animationList[i]:setVisible(false)
                                self.animationList[i]:setPosition(cc.p(0,0))
                                self.animationList[30+i]:setAnimation(0, "baozha", false)
                                self.animationList[30+i]:setVisible(true)
                            end
                        end)
                     end
           
                      end)
                else
                self.animatioanIng=false
                printTable(26,"sdafdsaf>>>>>>>>error")
                if not self.animationList[12] then
                  self.animationList[12]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
                end
                if not tolua.isnull(self.animationList[12]) then
                    self.animationList[12]:setAnimation(0, "gaiyun_shibai", false)
                end
            end
        elseif type==3 then--手气条特效
            if not self.animationList[13] then
             self.animationList[13]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
            end
            if not tolua.isnull(self.animationList[13]) then
                self.animationList[13]:setAnimation(0, "nengliuang_tiao", true)
            end
            self.animatioanIng=false
        elseif type==4 then--场景特效
            if not self.animationList[14] then
                self.animationList[14]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
            end
            if not tolua.isnull(self.animationList[14]) then
                self.animationList[14]:setAnimation(0, "nengliang_ta", true)
            end
            if not self.animationList[15] then
             self.animationList[15]= SpineUtil.createSpineObj(parent,{x=pos[1],y=pos[2]}, "qiyuan", "Effect/UI", "gonghui_qiyuan", "gonghui_qiyuan",false) 
            end
            if  not tolua.isnull(self.animationList[15]) then
                self.animationList[15]:setAnimation(0, "nengliang_qiu", true)
            end
            self.animatioanIng=false
    end
  
end


--事件初始化
function GuildDvinationView:_initEvent(...)
    local help= self.view:getChildAutoType("frame"):getChildAutoType("btn_help");
    help:removeClickListener()
    help:addClickListener(
        function(...)
            local info={}
            info['title']=Desc.help_StrTitle11
            info['desc']=Desc.help_StrDesc11
            ViewManager.open("GetPublicHelpView",info) 
        end
    )
    self.btn_divination:addClickListener(
        function(...)
            if self.animatioanIng==true then
                -- RollTips.show("正在获取奖励")
                return
            end
           -- self:playAniMation(self.img_ball,1,{0,0})
            local cost=0
            local info=DynamicConfigData.t_guildSystemParam
            for key, value in pairs(info) do 
                cost=value.divinationCost
            end
            GuildModel:divinationReq();
            local serverInfo= GuildModel.guildGuildDivunation;
            if  next(serverInfo)==nil then
                return 
            end
           if serverInfo.luckyVal>=cost then
           
           end
        end
    )
    self.btn_sure:addClickListener(
        function(...)
            GuildModel:divinationRewardReq()
        end
    )
    self.btn_luck:addClickListener(
        function(...)
            if self.animatioanIng==true then
                -- RollTips.show("正在获取奖励")
                return
            end
            GuildModel:divinationRetryReq()
        end
    )

    self.com_tishengshouqi:addClickListener(--提升手气
        function(...)
            local helpCount= GuildModel:getGuildupLuckCount()
            local serverInfo= GuildModel.guildGuildDivunation;
            if serverInfo and serverInfo.helpCount>=helpCount then
                    RollTips.show(Desc.guild_checkStr14)
            else
                local info = {}
                info.text = Desc.guild_checkStr15
                info.type = "yes_no"
                info.mask = true
                info.onYes = function()
                    GuildModel:divinationLuckyReq() 
                    Dispatcher.dispatchEvent(EventType.update_chatClientGuildDivination, nil)
                end
                Alert.show(info)
            end
        end
    )
    self.com_face:addClickListener(
    function(...)
        local idex=self.timeContro1:getSelectedIndex()
        if idex==1 then
            self.timeContro1:setSelectedIndex(0)
        else
            self.timeContro1:setSelectedIndex(1)
        end
    end
)

self.btn_faceclose:addClickListener(
    function(...)
        local idex=self.timeContro1:getSelectedIndex()
        if idex==1 then
            self.timeContro1:setSelectedIndex(0)
        else
            self.timeContro1:setSelectedIndex(1)
        end
    end
)

end

function GuildDvinationView:guild_up_guildDivinationXiaoGuo(_, isWin)
    printTable(159,"效果1》》》",isWin)
    self:showView({tag=true,num=isWin.old})
    self:playAniMation(self.img_ball,2,{0,0},isWin)
    local red=  RedManager.getTips("V_Guild_DIVINATIONRED");
    if not red then
        red=false
    end
    local img_red=self.view:getChild('img_red')
    img_red:setVisible(red)
end

function GuildDvinationView:guild_up_guildDivinationPlayTexiao(_, isWin)
    printTable(159,"效果2》》》",isWin)
    self:showView({tag=true,num=0})
    self:playAniMation(self.img_ball,1,{0,0})
    local red=  RedManager.getTips("V_Guild_DIVINATIONRED");
    if not red then
        red=false
    end
    local img_red=self.view:getChild('img_red')
    img_red:setVisible(red)
end

function GuildDvinationView:guild_up_guildDivination(...)
    printTable(159,"效果3》》》")
    self:showView()
    local red=  RedManager.getTips("V_Guild_DIVINATIONRED");
    if not red then
        red=false
    end
    local img_red=self.view:getChild('img_red')
    img_red:setVisible(red)
end

--initEvent后执行
function GuildDvinationView:_enter(...)
    print(1, "GuildDvinationView _enter")
end

--页面退出时执行
function GuildDvinationView:_exit(...)
    print(1, "GuildDvinationView _exit")
    self.animatioanIng=false
    SpineUtil.clearEffect(self.animationList)
    for key, value in pairs(self._updateTimeId) do
        Scheduler.unschedule(value)
        value=false
    end
  
end

-------------------常用------------------------

return GuildDvinationView
