--章节奖励
local PushMapChapterRewardView,Super = class("PushMapChapterRewardView",Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function PushMapChapterRewardView:ctor( ... )
	self._packName = "PushMap"
	self._compName = "PushMapChapterRewardView"
	self._rootDepth = LayerDepth.PopWindow
	self.text_guanka=false;
	self.text_star=false;
	self.list_reward=false;
end

-------------------常用------------------------
--UI初始化
function PushMapChapterRewardView:_initUI( ... )
	self.text_guanka=self.view:getChild('text_guanka');
	self.text_star=self.view:getChild('text_star');
	self.list_reward=self.view:getChild('list_reward');
	self:showChaptersRewardView()
end


function PushMapChapterRewardView:showChaptersRewardView()
    local cityId=self._args[1];
    local chapterId=self._args[2];
    local text=PushMapModel:getChapterRewardText(cityId,chapterId)
    self.text_guanka:setText('关卡['..text..']');
    local curStar,allStar= PushMapModel:getChatpterCurStarAndAllStar(cityId,chapterId);
    self.text_star:setText(GMethodUtil.getSizeString(curStar, 26)..ColorUtil.formatColorString1('/'..allStar,"#ffffff"));
    local rewardArr=DynamicConfigData.t_chapters[cityId][chapterId].dropid;
	self.list_reward:setItemRenderer(
        function(index, obj)
            local ItemInfo = rewardArr[index + 1]
            local star=ItemInfo.star;
            local pos=ItemInfo.pos;
            local txt_remine=obj:getChild('txt_remine'); 
            txt_remine:setText(pos..'.收集满'..ColorUtil.formatColorString1(star,"#119717")..'个星星')
            local configReward=DynamicConfigData.t_reward[ItemInfo.dropId]
            if configReward==nil then
                return;
            end
            local rewardlist=obj:getChild('list_reward')
            self:showReward(rewardlist,configReward.item1)
            local btn=obj:getChild('Btn_get')
            local getState= PushMapModel:getChatpterRewardRecord(cityId,chapterId,pos)
            local c1= obj:getController("c1")
            if curStar<star then
                c1:setSelectedIndex(0)
            else
                if getState==0 then
                    c1:setSelectedIndex(1)
                else
                    c1:setSelectedIndex(2)
                end
            end
            btn:removeClickListener(5)
            btn:addClickListener(
                function(context)
                    PushMapModel:receiveStarReward(cityId,chapterId,pos)  
                end,
                5
            )

            local Btn_no=obj:getChild('Btn_no')
            Btn_no:removeClickListener(5)
            Btn_no:addClickListener(
                function(context)
                    local City,chapter,curLevel= PushMapModel:getChapterlessthanThreeStar(cityId,chapterId)
                    if City==0 then
                        --RollTips.show("你已三星通关")
                        local CurCity,Curchapter,CurcurLevel= PushMapModel:getCurCityAndrChapterAndLevel()
                        if PushMapModel.jumpEnterState==true then--跳过
                            PushMapModel:PushMapQuickEnter(CurCity,Curchapter,CurcurLevel)
                        else
                            ViewManager.open('PushMapInvestigationView',{cityId=CurCity,chapterId=Curchapter,pointId=CurcurLevel})
                        end
                    else
                        printTable(155,"最大的商颠颠地阿杜你",City,chapter,curLevel)
                        if PushMapModel.jumpEnterState==true then--跳过
                            PushMapModel:PushMapQuickEnter(City,chapter,curLevel)
                        else
                            ViewManager.open('PushMapInvestigationView',{cityId=City,chapterId=chapter,pointId=curLevel})
                        end
                    end
                end,
                5
            )
        end
    )
    self.list_reward:setNumItems(#rewardArr)
end

function PushMapChapterRewardView:pushMap_chapterRewardRecord( ... )
    -- body
    local cityId=self._args[1];
    local chapterId=self._args[2];
    local rewardArr=DynamicConfigData.t_chapters[cityId][chapterId].dropid;
    self.list_reward:setNumItems(#rewardArr)
end

--UI初始化
function PushMapChapterRewardView:showReward(list,rewardInfo)
    list:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            local itemcell = BindManager.bindItemCell(obj)
			local award =rewardInfo[index+1]
			itemcell:setData(award.code, award.amount, award.type)
            itemcell:setFrameVisible(false)
            obj:addClickListener(function( ... )
            	itemcell:onClickCell()
			end,100)
        end
    )
    list:setNumItems(#rewardInfo)
end

--UI初始化
function PushMapChapterRewardView:pushMap_updatePointInfo(...)
    self:showChaptersRewardView()
end

--UI初始化
function PushMapChapterRewardView:_initEvent(...)

end


--initEvent后执行
function PushMapChapterRewardView:_enter( ... )

end

--页面退出时执行
function PushMapChapterRewardView:_exit( ... )
--	self.itemcellArrs = {}

end

-------------------常用------------------------

return PushMapChapterRewardView