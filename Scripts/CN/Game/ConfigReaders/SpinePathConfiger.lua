---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-11-14 15:10:04
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
--一些spine文件的配置路径
---@class SpinePathConfiger
return {
	--人物出场特效
	BornEffect={
		path = "Effect/battle",
		downEffect=  "Ef_battle_enter_down",
		upEffect="Ef_battle_enter_up",
	},
	--人物复活特效
	RevivedEffect={
		path = "Effect/battle",
		upEffect="effect_fuhuo",
	},
    --战斗开始特效
	BeginEffect={
		path = "Effect/UI",
		--downEffect=  "Ef_battle_enter_down",
		upEffect="Ef_zhandoukaishi_up",
	},
	--战斗标记特效
	SwordEffect={
		path = "Effect/battle",
		upEffect="efx_zhandoubiaozhi",
	},
	--骰子特效
	CrapsEffect={
		path = "Effect",
		upEffect="shaizi",
		animatin_o="orange_",
		animatin_b="blue_"
	},
	--圆圈特效
	CircleEffect={
		path = "Effect/battle",
		upEffect="efx_tongyongyuankuang",
		animations={
			[1]="tongyongyuankuang_chong", --仙
			[2]="tongyongyuankuang_zi",    --魔
			[3]="tongyongyuankuang_lu",  --兽
			[4]="tongyongyuankuang_hong",  --人
			[5]="tongyongyuankuang_lan",   --械
		}
	},	
	--宝箱打开特效
	BoxEffect={
		path = "Effect/UI",
		upEffect="Ef_yuanzheng_baoxiang",
		animation="baoxiang_chuxian"
	},
	
	qianZiHeEffect={
		path = "Effect/UI",
		upEffect="qianzhihe",
		animation="animation"
	}
	
}