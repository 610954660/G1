--道具tips
--added by xhd 技能按钮群
local SkillTipsBtnPanel = class("SkillTipsBtnPanel",View)
function SkillTipsBtnPanel:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsBtnPanel"
	self._isFullScreen = false
   
	
	self.list_btns = false
	
	self._data = args.data
	self._btnData = {}
end


-- [子类重写] 初始化UI方法
function SkillTipsBtnPanel:_initUI( ... )
	self.list_btns = self.view:getChildAutoType("list_btns")
	
	self.list_btns:setItemRenderer(function (index,obj)
			local data = self._btnData[index + 1]
			obj:setTitle(data.title)
			obj:removeClickListener(333)
			obj:addClickListener(function ( ... )
				self:onClick(data.name)
			end,333)
		end)
	print(1,self._data)
	table.insert(self._btnData, {name = "qiexiaBtn", title = DescAuto[323]}) -- [323]="卸下"
	table.insert(self._btnData, {name = "changeBtn", title = DescAuto[324]}) -- [324]="切换"
	self.list_btns:setData(self._btnData)
	self.list_btns:resizeToFit(self.list_btns:getNumItems())
end

function SkillTipsBtnPanel:onClick(itemName)
	if(itemName == "qiexiaBtn") then
		local params = {}
    	local skillArr = {}
    	table.insert(skillArr,0)
		params.id = RuneSystemModel:getCurBjRuneID()
		params.skillIds = skillArr
		params.onSuccess = function (res )
		    --printTable(1,res)
	    	if RuneSystemModel:getCurBjRuneID() == res.id then
	    		RuneSystemModel:setRuneArrDataName( res.id,"skills",res.skills)
	    		RuneSystemModel:checkRuneRedDot( )
	    		Dispatcher.dispatchEvent(EventType.update_smallPage)
	    	end
		end
		RPCReq.Rune_SkillChoose(params, params.onSuccess)
		ViewManager.close("ItemTips")
	elseif(itemName == "changeBtn") then
		ViewManager.open("RuneSkillView")
		ViewManager.close("ItemTips")
	end
	
end

-- [子类重写] 准备事件
function SkillTipsBtnPanel:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function SkillTipsBtnPanel:_enter()
end

-- [子类重写] 移除后执行
function SkillTipsBtnPanel:_exit()
end


return SkillTipsBtnPanel
