
-- 帮助系统 (常见问题)
-- added by zn

local StrongItem = require "Game.Modules.HelpSystem.StrongItem";
local HelpSysQuestionView, Super = class("HelpSysQuestionView", Window);

function HelpSysQuestionView:ctor ()
    self._packName = "HelpSystem";
    self._compName = "HelpSysQuestionView";

    -- 常见问题
    self.list_question = false;
end

function HelpSysQuestionView:_initUI()

    -- 常见问题
    self.list_question = self.view:getChild("list_question");
    self.list_question:setItemRenderer(function (idx, obj)
        if (not obj.lua_script) then
            obj.lua_script = StrongItem.new(obj, 1);
        end
        obj.lua_script:setIndex(idx + 1);
    end)
    self.list_question:setNumItems(#DynamicConfigData.t_Problem);

end

return HelpSysQuestionView