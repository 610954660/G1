
local TalentController = class("TalentController", Controller)


function TalentController:cardView_activeSkillSuc(_, data, skillId)
    ViewManager.open("TalentActiveSucView", {skillId= skillId});
end

function TalentController:CardView_showTanlentLearnSuc(_, data, param)
    ViewManager.open("TalentLearnSucView", {skillId = param.skillId, newInfo = data, oldInfo = param.old})
end

return TalentController;