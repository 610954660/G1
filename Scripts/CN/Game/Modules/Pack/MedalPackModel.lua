-- add by zn
-- 荣誉勋章背包

local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local MedalPackModel = class("MedalPackModel", PackBaseModel);

function MedalPackModel:initRedMap()
    HonorMedalModel:checkRed();
end

return MedalPackModel;