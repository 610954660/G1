--Create By GQY
--TIME:2020/8/21 15:08

local NewServerGiftController = class("NewServerGiftController", Controller)

function NewServerGiftController:init()
end

function NewServerGiftController:_initListeners()

end

function NewServerGiftController:Activity_UpdateData(name,args)
    if args and args.newServerGift then
        printTable(999,"新服专享",args)
        ModelManager.NewServerGiftModel:setGifts(args.newServerGift)
        Dispatcher.dispatchEvent("update_NewServerGiftList")
    end
end

function NewServerGiftController:Activity_NewServerGift_GetReward(name,id)
    RPCReq.Activity_NewServerGift_GetReward({id = id})
end

return NewServerGiftController