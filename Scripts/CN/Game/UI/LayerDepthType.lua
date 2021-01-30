--fgui不同根节点层级划分
LayerDepth = {
    Zero = 0,
    MainUI = 200,  --主界面
	PopMainUI = 201,  --主界面上的界面 用于跟MainUI共存
    Window = 300,  --常用界面 功能模块
    PopWindow = 301,  --Window 上的界面 只能显示一个
	
	WindowUI = 304,  --Window 上的界面 可以显示N个
	
    FaceWindow = 305,  --表情
    AlertWindow = 310,
    Tips = 320, --tip弹出界面
    Top = 400,
    Message = 410,--公告面板
	Guide = 599,   --新手引导

    Alert = 500,   --通用提示框
    RollTips = 510,   --RollTips
    OverGame = 600,   --浮动于游戏上方，例如webPage

    UIEffect = 8000, --特效
}

