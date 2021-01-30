--查看关卡
local PushMapInvestigationView,Super = class("PushMapInvestigationView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ItemCell = require "Game.UI.Global.ItemCell"
local ModuleType = GameDef.ModuleType
function PushMapInvestigationView:ctor( ... )
	self._packName = "PushMap"
	self._compName = "PushMapInvestigationView"
	self._rootDepth = LayerDepth.PopWindow
    self.img_tietu=false;
    self.txt_desc=false;
	self.rightPanel = false
    self.list_desc=false;
    self.btn_plot=false;
    self.btn_goUpgrade=false;
	self.Btn_rank=false;
    self.Btn_enter=false;
    self.txt_fight=false;
    self.img_bg=false;
end

-------------------常用------------------------
--UI初始化
function PushMapInvestigationView:_initUI( ... )
	self.rightPanel = self.view:getChild('rightPanel');
    self.text_guanka=self.view:getChild('text_guanka');
    self.img_tietu=self.view:getChild('img_tietu');
    self.txt_desc=self.view:getChild('txt_desc');
    self.list_desc=self.rightPanel:getChild('list_desc');
    self.btn_plot=self.view:getChild('btn_plot');
    self.btn_goUpgrade=self.rightPanel:getChild('btn_goUpgrade');
	self.Btn_rank=self.view:getChild('Btn_rank');
    self.Btn_enter=self.rightPanel:getChild('Btn_enter');
    self.txt_fight=self.rightPanel:getChild('txt_fight');
    self.txt_limitLv=self.rightPanel:getChild('txt_limitLv');
    self.text_chaptername=self.view:getChild('text_chaptername'); 
    self.c1=self.rightPanel:getController('c1');
    self.c2=self.rightPanel:getController('c2');
    --self:setBg("pusMapPointbg.jpg")
    self:showInvestigationView()
    self:showJuqingBtn()
    self:showFigthText()
    self:showisThreeBtn()
end

function PushMapInvestigationView:showisThreeBtn()
    local cityId=self._args.cityId;
    local chapterId=self._args.chapterId;
    local pointId=self._args.pointId;
    local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
    if not configInfo then
        return
    end
    local playerlv=PlayerModel.level
    if playerlv>=configInfo.openLv then
        local itemStar= PushMapModel:getPointStar(cityId,chapterId,pointId);
        if itemStar>=3 then
			
            self.c2:setSelectedIndex(1)
        else
            self.c2:setSelectedIndex(0)
        end
    else
        self.c2:setSelectedIndex(2)
        local str=string.format( "探长%s级可开启",configInfo.openLv)
        self.txt_limitLv:setText(str)
		local saveValue = FileCacheManager.getStringForKey(PlayerModel.userid..FileDataType.PUSHMAP_GOUPGRADE,"0",nil,true)
		if saveValue == "0" then
			Dispatcher.dispatchEvent(EventType.guide_open,{guideMode = 2,guideName = "zuozhan"})
			FileCacheManager.setStringForKey(PlayerModel.userid..FileDataType.PUSHMAP_GOUPGRADE,"1",nil,true)
		end
    end
    local isPass=PushMapModel:CurPointisPassed(cityId,chapterId,pointId)
    if isPass==true then
        self.c1:setSelectedIndex(1)
    else
        self.c1:setSelectedIndex(0)
    end
end

function PushMapInvestigationView:showFigthText()
    local cityId=self._args.cityId;
    local chapterId=self._args.chapterId;
    local pointId=self._args.pointId;
    local itemType= PushMapModel:getPointType(cityId,chapterId,pointId);
    if itemType==3 then--剧情
        self.txt_fight:setText(0)
    else
       local config= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
       local fighId= config.fightfd;
       local fightNum= PushMapModel:getMonsterFigthByFightId(fighId)
        self.txt_fight:setText(StringUtil.transValue(fightNum))
    end
end

function PushMapInvestigationView:showJuqingBtn()
    local curMaxPoint=PushMapModel:getCurPointIndex(self._args.cityId,self._args.chapterId)--当前关卡
    local cityId=self._args.cityId;
    local chapterId=self._args.chapterId;
    local pointId=self._args.pointId;
    local itemType= PushMapModel:getPointType(cityId,chapterId,pointId);
    if itemType==2 then
        self.btn_plot:setVisible(false);
    else
        if  curMaxPoint<=self._args.pointId then
            self.btn_plot:setVisible(false);
        else
            self.btn_plot:setVisible(true);
        end
    end
end

function PushMapInvestigationView:showInvestigationView()
    local cityId=self._args.cityId;
    local chapterId=self._args.chapterId;
    local pointId=self._args.pointId;
	local fightId = PushMapModel:getPushMapCurFightId()
    PushMapModel.battleCity={cityId=cityId,chapterId=chapterId,pointId=pointId}
	local newFightId = PushMapModel:getPushMapCurFightId()
	if fightId ~= newFightId then
		Dispatcher.dispatchEvent(EventType.pushMap_point_change)
		Dispatcher.dispatchEvent(EventType.module_check, ModuleType.PushMap , newFightId)
	end
    local configInfo=DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId];
    if not configInfo then
        return
    end
    self.text_guanka:setText(cityId.."-"..chapterId.."-"..pointId);
    self.text_chaptername:setText(configInfo.sidnamedesc);  
    self.img_tietu:setURL(PushMapModel:getInvesyingSidbg(configInfo.sidbg));
    self.txt_desc:setText(configInfo.siddesc);
    local rewardArr=PushMapModel:getPointRewardDesc(cityId,chapterId,pointId) 
    printTable(12,'dasfewq1>>>>>>',cityId,chapterId,pointId,rewardArr)
    self.list_desc:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            obj:addClickListener(function( ... )
            end,100)
            local rewardItem=rewardArr[index+1];
            local text_desc=obj:getChild('text_desc');
            text_desc:setText(rewardItem.desc)
            local img_icon=obj:getChild('img_icon');
            if rewardItem['reward'] then
                local rewardType=rewardItem['reward'].type
                local rewardCode=rewardItem['reward'].code
                local rewardAmount=rewardItem['reward'].amount
                local URL=ItemConfiger.getItemIconByCodeAndType(rewardType,rewardCode)
                img_icon:setURL(URL)
                local txt_num=obj:getChild('txt_num');
                txt_num:setText(rewardAmount)
            end
            local gCtr=obj:getController("c1")
            local itemStar= PushMapModel:getPointStarPassList(cityId,chapterId,pointId);
            if itemStar and itemStar[index+1]==true then
                gCtr:setSelectedIndex(1)
            else
                gCtr:setSelectedIndex(0)
            end
        end
    )
    self.list_desc:setNumItems(#rewardArr)
    self:showPassReward(configInfo);
end

function PushMapInvestigationView:showPassReward(configInfo)
    local fightReward= DynamicConfigData.t_chaptersPointFightFd[configInfo.fightfd]; 
    if not fightReward then
        return 
    end
    for i = 1, 3, 1 do
        local key='itemCell'..i;
        local cell= self.rightPanel:getChild(key);
        local itemcell = BindManager.bindItemCell(cell)
        local award = fightReward.reward[i]
        itemcell:setData(award.code, award.amount, award.type)
        itemcell:setFrameVisible(false) 
        cell:removeClickListener(100)
        cell:addClickListener(function( ... )
            itemcell:onClickCell()
        end,100)
    end

    for i = 1, 3, 1 do
        local imgKey='img_onhook'..i;
        local txtKey='txt_onhook'..i;
        local imgCell= self.rightPanel:getChild(imgKey);
        local txtCell= self.rightPanel:getChild(txtKey);
        local greward= fightReward.greward[i]
        local URL=ItemConfiger.getItemIconByCodeAndType(greward.type,greward.code)
        imgCell:setURL(URL)
        txtCell:setText(greward.amount..'/分')
    end
end


--UI初始化
function PushMapInvestigationView:_initEvent(...)
    self.Btn_rank:addClickListener(
        function(...)
            ViewManager.open("PublicRankView", {type = GameDef.RankType.Chapters})
        end
    )
    self.btn_plot:addClickListener(
        function(...)
            local info=self._args
            local cityId=info.cityId
            local chapterId=info.chapterId
            local pointId=info.pointId
            local chaptInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
            local storyId=chaptInfo.storyid
            if storyId[1]~=0 then
                ViewManager.open("PushMapFilmView",{step = storyId[1]})
            end
        end
    )

	self.btn_goUpgrade:addClickListener(
        function(...)
            ViewManager.open("PushMapOnhookRewardView")
        end
    )
  
    local info=self._args
    local cityId=info.cityId
    local chapterId=info.chapterId
    local pointId=info.pointId
    local chaptInfo= DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
	self.Btn_enter:addClickListener(
        function(...)
            PushMapModel:PushMapQuickEnter(cityId,chapterId,pointId)
            ViewManager.close('PushMapInvestigationView');
        end  
        )
end

--刷新等级
function PushMapInvestigationView:player_levelUp( ... )
    self:showisThreeBtn()
end

--initEvent后执行
function PushMapInvestigationView:_enter( ... )

end

--页面退出时执行
function PushMapInvestigationView:_exit( ... )
--	self.itemcellArrs = {}

end

-------------------常用------------------------

return PushMapInvestigationView