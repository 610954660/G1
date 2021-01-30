local PopularVoteShopController = class("PopularVoteShopController", Controller)

function PopularVoteShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.HeroVoteShop then
		return 	
	end
	local gift = params and params.trialShop and params.trialShop.gift or {}
	ModelManager.PopularVoteModel:initShopData(gift)
end

return PopularVoteShopController