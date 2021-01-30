local DetectiveAgencyView = class("DetectiveAgencyView", Window)

function DetectiveAgencyView:ctor()
	self._packName = "DetectiveAgency"
	self._compName = "DetectiveAgencyView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self.timeId = false
end

--编辑器不能修改图片填充 只能使用代码的方式实现
function DetectiveAgencyView:doScriptAciton()
	if self.timeId then
		Scheduler.unschedule(self.timeId)
		self.timeId = false
	end		
    local lineMapBtns = {
		self.view:getChildAutoType("btn_title"),
		self.view:getChildAutoType("btn_archives"),
		self.view:getChildAutoType("btn_upStar"),
		self.view:getChildAutoType("btn_reset"),
		self.view:getChildAutoType("btn_decompose"),
		self.view:getChildAutoType("btn_back"),
		self.view:getChildAutoType("btn_change"),
		self.view:getChildAutoType("btn_heroFetter"),
		self.view:getChildAutoType("btn_herohelp"),
		self.view:getChildAutoType("btn_heroreset"),
	}
	--获取特效播放的坐标
	local spinePArr = {}
	for i=1,#lineMapBtns do
		table.insert(spinePArr,self.view:getChildAutoType("point"..i))
	end

	local lineArr = {}
	for i=1,#lineMapBtns do
		table.insert(lineArr,self.view:getChildAutoType("line"..i))
		lineArr[i]:setFillAmount(0)
		lineMapBtns[i]:setVisible(false)
	end
	
	local curNum = 0
	local function updateCall(interval)
		curNum = curNum + 4*2
		for i=1,#lineMapBtns do
			lineArr[i]:setFillAmount(curNum/100)
		end
		print(1,curNum)
		if curNum == 16 then
			for i=1,#lineMapBtns do
			    SpineUtil.createSpineObj(spinePArr[i], vertex2(0,0),"ui_mingzichuxian_up", "Spine/ui/detectiveAgency", "yanjiusuo_texiao", "yanjiusuo_texiao",false)
			end
		end
		if curNum >=100 then
			for i=1,#lineMapBtns do
				lineMapBtns[i]:setVisible(true)
			end
			Scheduler.unschedule(self.timeId)
			self.timeId = false
		end
	end
	
	self.timeId = Scheduler.schedule(updateCall,0,0)
end

function DetectiveAgencyView:_initUI()
	self.frame = self.view:getChildAutoType("frame")
	self.btn_help = self.frame:getChildAutoType("btn_help")
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
        local info={}
        info['title']=Desc["help_StrTitle196"]
        info['desc']=Desc["help_StrDesc196"]
        ViewManager.open("GetPublicHelpView",info) 
    end)

	self.bg = self.view:getChildAutoType("bg")
	self.bg:setIcon(PathConfiger.getBg("DetectiveAgency.jpg"))
	self.view:getChildAutoType("btn_archivesTouch"):addClickListener(function()
		ViewManager.open("HerobookView")
	end)
	self.view:getChildAutoType("btn_archives"):addClickListener(function()
		ViewManager.open("HerobookView")
	end)
	self.view:getChildAutoType("btn_resetTouch"):addClickListener(function()
		ViewManager.open('HeroResetView')
	end)
	self.view:getChildAutoType("btn_reset"):addClickListener(function()
		ViewManager.open('HeroResetView')
	end)
	self.view:getChildAutoType("btn_decomposeTouch"):addClickListener(function()
		ViewManager.open('CardDetailsDecompose')
	end)
	self.view:getChildAutoType("btn_decompose"):addClickListener(function()
		ViewManager.open('CardDetailsDecompose')
	end)
	self.view:getChildAutoType("btn_upStarTouch"):addClickListener(function()
		ViewManager.open('HeroUpStarView')
		--if RedManager.getTips("M_DetectiveAgency") then
			--local dayStr = DateUtil.getOppostieDays()
			--FileCacheManager.setBoolForKey("M_DetectiveAgency" .. dayStr, true)
			--RedManager.addMap("M_DetectiveAgency",{"M_ELVES","M_HANDBOOK"})
		--end
		RedManager.updateValue("V_HERO_UPSTAR", false)
	end)
	self.view:getChildAutoType("btn_upStar"):addClickListener(function()
		ViewManager.open('HeroUpStarView')
		--if RedManager.getTips("M_DetectiveAgency") then
			--local dayStr = DateUtil.getOppostieDays()
			--FileCacheManager.setBoolForKey("M_DetectiveAgency" .. dayStr, true)
			--RedManager.addMap("M_DetectiveAgency",{"M_ELVES","M_HANDBOOK"})
			RedManager.updateValue("V_HERO_UPSTAR", false)
		--end
	end)
	self.view:getChildAutoType("btn_backTouch"):addClickListener(function()
		ViewManager.open("ResetHeroView")
	end)
	self.view:getChildAutoType("btn_back"):addClickListener(function()
		ViewManager.open("ResetHeroView")
	end)
	self.view:getChildAutoType("btn_changeTouch"):addClickListener(function()
		ModuleUtil.openModule(ModuleId.Elves_Attribute.id, true);
	end)
	self.view:getChildAutoType("btn_change"):addClickListener(function()
		ModuleUtil.openModule(ModuleId.Elves_Attribute.id, true);
	end)
	self.view:getChildAutoType("btn_titleherohelp"):addClickListener(function()--探员帮助
		ModuleUtil.openModule(ModuleId.Help);
	end)
	self.view:getChildAutoType("btn_herohelp"):addClickListener(function()--探员帮助
		ModuleUtil.openModule(ModuleId.Help);
	end)
	self.view:getChildAutoType("btn_imgheroreset"):addClickListener(function()--探员转换
		ModuleUtil.openModule(ModuleId.CardResetthe.id);	
	end)
	self.view:getChildAutoType("btn_heroreset"):addClickListener(function()--探员转换
		ModuleUtil.openModule(ModuleId.CardResetthe.id);	
	end)
	self.view:getChildAutoType("btn_titleTouch"):addClickListener(function()
		ViewManager.open("HandbookTitleView")
	end)
	self.view:getChildAutoType("btn_title"):addClickListener(function()
		ViewManager.open("HandbookTitleView")
	end)
	self.btn_heroFetterIcon = self.view:getChildAutoType("btn_heroFetterIcon")
	self.btn_heroFetterIcon:addClickListener(function()
		ViewManager.open("HeroFettersView")
	end)
	self.btn_heroFetter = self.view:getChildAutoType("btn_heroFetter")
	self.btn_heroFetter:addClickListener(function()
		ViewManager.open("HeroFettersView")
	end)
	RedManager.register("M_HeroFetters", self.btn_heroFetter:getChildAutoType("img_red"))

	self.btn_title = self.view:getChildAutoType("btn_title")
	RedManager.register("M_HANDBOOK", self.btn_title:getChildAutoType("img_red"))

	self.btn_change = self.view:getChildAutoType("btn_change")
	RedManager.register("M_ELVES", self.btn_change:getChildAutoType("img_red"))

	self.btn_upStar = self.view:getChildAutoType("btn_upStar")
	RedManager.register("M_HERO_LEVELUP", self.btn_upStar:getChildAutoType("img_red"))

	self:doScriptAciton()
	
end
function DetectiveAgencyView:_exit()
	if self.timeId then
		Scheduler.unschedule(self.timeId)
		self.timeId = false
	end
end
return DetectiveAgencyView