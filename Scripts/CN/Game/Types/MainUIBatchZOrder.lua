local MainUIBatchZOrder = {}
--裁剪层级放到最低，才能保证正确裁剪
MainUIBatchZOrder.FunctionIconSissor = -150

--主角头像部分
MainUIBatchZOrder.PlayerAvatarImage = -130
MainUIBatchZOrder.PlayerTextNormal  = -129
MainUIBatchZOrder.PlayerTextBMFont  = -128
MainUIBatchZOrder.PlayerEffect  = -127
MainUIBatchZOrder.PlayerScrollView  = -126


--小地图、通知栏
MainUIBatchZOrder.NoticeIcon = -110
MainUIBatchZOrder.NoticeEffect = -109
MainUIBatchZOrder.NoticeText = -108

-- 主界面drawcall优化
MainUIBatchZOrder.FunctionIconBack2 = -101
MainUIBatchZOrder.FunctionIconBack = -100
MainUIBatchZOrder.FunctionIcon = -99
MainUIBatchZOrder.FunctionIconAtlats = -98
MainUIBatchZOrder.FunctionIconEffect = -97
MainUIBatchZOrder.FunctionIconFont = -96
MainUIBatchZOrder.FunctionIconFontAtlats = -95
MainUIBatchZOrder.FunctionIconRedDot = -94
MainUIBatchZOrder.CrossFunctionIconRedDot = -93

--技能按钮
MainUIBatchZOrder.SkillBtn = -90
MainUIBatchZOrder.SkillBtnProgress = -89
MainUIBatchZOrder.SkillBtnCDText = -88
MainUIBatchZOrder.SkillBtnCDEffect = -87

--任务面板

MainUIBatchZOrder.TaskTraceItemImage = -80
MainUIBatchZOrder.TaskTraceItemAmount = -79
MainUIBatchZOrder.TaskTraceItemText = -78
MainUIBatchZOrder.TaskTraceItemEffect = -77

return MainUIBatchZOrder
