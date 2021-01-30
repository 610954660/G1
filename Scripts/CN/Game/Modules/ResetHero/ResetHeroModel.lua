-- add by zn
-- description

local ResetHeroModel = class("ResetHeroModel", BaseModel)

function ResetHeroModel:ctor()
    self.resetType = 1;
end

function ResetHeroModel:resetHero(type, data)
    local info = {
        uuid = data.uuid,
		type = type
    }
    RPCReq.Hero_HeroStarReset(info, function ()
        Dispatcher.dispatchEvent("ResetHero_reset");
    end)
end

return ResetHeroModel