
local GuildskillsOpenView, Super = class("GuildskillsOpenView", Window)
function GuildskillsOpenView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildskillsOpenView"
    self._rootDepth = LayerDepth.PopWindow
    self._updateTimeId=false
end

-------------------常用------------------------
--UI初始化
function GuildskillsOpenView:_initUI(...)
    local skillId=self._args.id
    local skillCell= self.view:getChildAutoType("$skillCel") 
	if tolua.isnull(self.view) then return end
	self.view:getTransition("t0"):play(function( ... )
                          end);
    self.view:setTouchable(false);
    self._updateTimeId  = Scheduler.scheduleOnce(0.5,function()
                self._updateTimeId = false
                self.view:setTouchable(true);
        end)
    local conf = DynamicConfigData.t_skill[skillId];
    local cell = BindManager.bindSkillCell(skillCell)
    cell:setData(skillId)
    skillCell:removeClickListener(100);
     local lockCtrl = cell.view:getController("lockCtrl")
    lockCtrl:setSelectedIndex(0)
    skillCell:addClickListener(function ()
        if conf then
            ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId,data = conf})
        end
    end,100)
    local txt_skillName= self.view:getChildAutoType("txt_skillName") 
    txt_skillName:setText(conf.skillName)
    local  txt_skillDesc=self.view:getChildAutoType("$txt_skillDesc") 
	txt_skillDesc:setText(conf.showName)
end

--页面退出时执行
function GuildskillsOpenView:_exit(...)
    if self._updateTimeId then
        Scheduler.unschedule(self._updateTimeId)
    end

end

-------------------常用------------------------

return GuildskillsOpenView
