---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local RetrieveViewController = class("RetrieveViewController",Controller)

-- type 			1:integer	#回收系统类型
-- vipLv			2:integer	#刷新时vip等级
-- normalTimes		3:integer	#普通可回收次数
-- vipTimes		4:integer  	#当前vip可增加次数
-- ids				5:*integer	#当前可找回的ids
function RetrieveViewController:Retrieve_Info(_,info)
    -- info={
    --     infos={
    --             [1000]={
    --                     vipTimes=0,
    --                     vipLv=0,
    --                     type=1000,
    --                     normalTimes=4,
    --                     ids={
    --                     },
    --             },
    --     },
    -- }
    printTable(156,"资源找回下发数据",info)
    if info.infos then
        RetrieveModel:setRetrieveInfo(info.infos)--设置找回数据
    else
        RetrieveModel.retrieveInfo={}
    end
    RetrieveModel:upRetrieveRed()
     Dispatcher.dispatchEvent(EventType.RetrieveView_refreshPanal)
end


return RetrieveViewController
