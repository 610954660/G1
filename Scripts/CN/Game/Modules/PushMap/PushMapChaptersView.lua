--added by wyang 公会管理列表
local PushMapChaptersView,Super = class("PushMapChaptersView",Window)
function PushMapChaptersView:ctor( ... )
	self._packName = "PushMap"
	self._compName = "PushMapChaptersView"
	--self._rootDepth = LayerDepth.Window
    self.btn_help=false;
    self.btn_task=false;
    self.btn_worldmap=false;
    self.list_chapter=false;
    self._updateTimeId=false
    self.guochangyun=false
    self.chapterAnim={}
end

-------------------常用------------------------
--UI初始化
function PushMapChaptersView:_initUI( ... )
    printTable(9,'打开的章节界面1')
    self.btn_help=self.view:getChild('btn_help');
    self.btn_worldmap=self.view:getChild('btn_worldmap');
    self.btn_task=self.view:getChild('btn_task');
    self.list_chapter=self.view:getChild('list_chapter');
    self.img_animation=self.view:getChild('img_animation');
    self.list_chapter:setSize(display.width, display.height)
    self.list_chapter:setPosition(-(display.width - self.view:getWidth())/2, 0)
    printTable(12,"asdffffffff",self._args)
    self.list_chapter:setVisible(false)
    self.btn_worldmap:setVisible(false)
	self.guochangyun= SpineUtil.createSpineObj(self.img_animation,{x=0,y=0}, "animation", "Effect/UI", "Ef_guochangyun", "Ef_guochangyun",false) 
	self.guochangyun:setCompleteListener(function(name)
		   end)
           self._updateTimeId = Scheduler.scheduleOnce(0.5,function()
            self._updateTimeId=false
           -- local curIndex= PushMapModel:getCurChapterIndex(self._args.cityId);
           -- if self.chapterAnim[curIndex] then
                --self.chapterAnim[curIndex]:setAnimation(0, "animation", true)
            --end 
             self.btn_worldmap:setVisible(true)
			  self.list_chapter:setVisible(true)
		  end)

	self:showChaptersView()
	
	
end

--添加红点
function PushMapChaptersView:_addRed(...)
	local img_red=self.btn_worldmap:getChild('img_red')
    RedManager.register("V_CHAPTERREWARDRED", img_red, ModuleId.PushMap.id)
end


function PushMapChaptersView:showChaptersView()
    local chaptersInfo=DynamicConfigData.t_chapters[self._args.cityId];
    if chaptersInfo==nil then
        return;
    end
    local chaptNum=#chaptersInfo;
    local curIndex= PushMapModel:getCurChapterIndex(self._args.cityId);
    printTable(12,'当前打印的城市afadsf',curIndex)
	self.list_chapter:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(5)
            -- obj:addClickListener(
            --     function(context)
            --     end,
            --     5
            -- )
           local img_map1=obj:getChild('img_map1')
           img_map1:setURL(PushMapModel:getChatperMapBg1(chaptersInfo[1].mapid));
           for i = 1, chaptNum, 1 do
            local chaptItem =UIPackageManager.createGComponent("PushMap", "pushMapchapterItem")
            local chaptInfo= chaptersInfo[i]
            if chaptItem then
                local hasRed=PushMapModel:getPushMapchapterRed(self._args.cityId,i)
                local imgred=chaptItem:getChildAutoType("img_red")
                local img_anileft=chaptItem:getChildAutoType("img_anileft") 
                local img_aniright=chaptItem:getChildAutoType("img_aniright")
                imgred:setVisible(hasRed)
                local x=chaptInfo.site[1]
                local y=chaptInfo.site[2]
                obj:addChild(chaptItem)
                chaptItem:setPosition(x,y)
                    local curStar,allStar= PushMapModel:getChatpterCurStarAndAllStar(self._args.cityId,i);
                    chaptItem:setVisible(true)
                    local ctext=chaptItem:getChild('ctext')
                    ctext:setText(chaptInfo.cid)
                    local title=chaptItem:getChild('title') 
                    title:setText(chaptInfo.cname)
                    local txt_curstar=chaptItem:getChild('txt_curstar') 
                    txt_curstar:setText(ColorUtil.formatColorString1(curStar,"#6AFF60")..'/'..allStar )
                    local tips= chaptItem:getChild('img_tips')
                    tips:setURL('Icon/pushMap/pusMapPoint1001.jpg');
                    local gCtr=chaptItem:getController("button")
                    gCtr:setSelectedIndex(0)
                    local isRight=chaptInfo.site[3]
                    if isRight-1==0 then --左
                        if not self.chapterAnim[i] then
                            self.chapterAnim[i]=PushMapModel:getChapterAnim(img_anileft)
                         end  
                    else
                        if not self.chapterAnim[i] then
                            self.chapterAnim[i]=PushMapModel:getChapterAnim(img_aniright)
                         end  
                    end
                    local c1=chaptItem:getController("c1")
                    if curIndex==i then
                  
                        c1:setSelectedIndex(1)
                    elseif curIndex>i then
                        c1:setSelectedIndex(2)
                        if self.chapterAnim[i] then
                            SpineUtil.clearEffect(self.chapterAnim[i])
                        end
                    else
                        c1:setSelectedIndex(0)
                        if self.chapterAnim[i] then
                            SpineUtil.clearEffect(self.chapterAnim[i])
                        end
                    end
                    -- if self.chapterAnim[i] then
                    --     self.chapterAnim[i]:setVisible(false)
                    -- end
                    local c2=chaptItem:getController("c2")
                    c2:setSelectedIndex(isRight-1)
                    if curIndex==i then
                        if isRight-1==0 then --左
                            self.chapterAnim[i]:setScaleX(-1)
                        else
                            self.chapterAnim[i]:setScaleX(1)
                        end
                    end
                    if curIndex>=i then
                        chaptItem:setVisible(true)
                    else
                        chaptItem:setVisible(false)
                    end
                    chaptItem:removeClickListener(5)
                    chaptItem:addClickListener(
                    function(context)
                        local chaptInfo= chaptersInfo[i]
                        local cityId=chaptInfo.city
                        local chapterId=chaptInfo.cid
                        --ViewManager.close('PushMapChaptersView')   
                        PushMapModel:getHangUpState()
                        ViewManager.close('PushMapChaptersView')
                        ViewManager.open('PushMapCheckPointView',{cityId=cityId,chapterId=chapterId,hasAni=true})   
                    end,
                    5
                )
                end
            end
        end
    )
    self.list_chapter:setNumItems(1)
end

function PushMapChaptersView:pushMap_updatePointInfo(...)
    printTable(9,'刷新当前章节星数')
	self:showChaptersView();
    --self.list_chapter:setNumItems(1)
end


--UI初始化
function PushMapChaptersView:_initEvent(...)
    self.btn_task:addClickListener(
        function(...)
            ViewManager.open("TaskView")  
        end
    )
    self.btn_help:addClickListener(
        function(...)
            local info={}
            info['title']=Desc.help_StrTitle1
            info['desc']=Desc.help_StrDesc1
            ViewManager.open("GetPublicHelpView",info) 
        end
    )
    self.btn_worldmap:addClickListener(
        function(...)
            ViewManager.close('PushMapChaptersView')
            ViewManager.open("PushMapWorldMapView");
        end
    )
end

--initEvent后执行
function PushMapChaptersView:_enter( ... )

end

--页面退出时执行
function PushMapChaptersView:_exit( ... )
    SpineUtil.clearEffect(self.chapterAnim)
    SpineUtil.clearEffect(self.guochangyun)
    Scheduler.unschedule(self._updateTimeId)
    ViewManager.close('PushMapWorldMapView')
end
-------------------常用------------------------

return PushMapChaptersView