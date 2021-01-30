

local SpineTest = {}


--shader 代码暂时写这里
local vert = [[
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#endif
void main()
{
	gl_Position = CC_PMatrix * a_position;
	v_fragmentColor = a_color;
	v_texCoord = a_texCoord;
}
]]

local frag = [[
#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec2 my_size;                   // 纹理大小，纹理坐标范围为0-1

void main(void)
{
	
	float a_limit = 0.1;                // 透明度限制，低于该值即视为透明
	
	vec4 color1 = texture2D(CC_Texture0, v_texCoord);
	gl_FragColor = color1;
	if(color1.a >= a_limit)
	{
		gl_FragColor = vec4(0.0,0.0,0.0,0.0);
		return;                         // 非透明像素点不做处理
	}
	vec2 unit = 1.0 / my_size.xy;       // 单位坐标
	float step = 30.0;                  // 30度
	float width = 6.0;                  // 描边宽度
	float width_step = 2.0;             // 描边宽度_步长
	vec4 border = vec4(0.36,0.917,0.737,0.6);// 边框颜色
	
	// 遍历四周所有像素点
	for(float i = 0.0; i < 360.0; i += step)
	{
		// 当前角度的偏移坐标
		vec2 offset = vec2(cos(i) * unit.x, sin(i) * unit.y);
		// 当前像素点偏移坐标下的像素点
		vec4 color2 = texture2D(CC_Texture0, v_texCoord + offset * width);
		if(color2.a >= a_limit)
		{
			for(float w = 0.0; w <= width; w += width_step)
			{
				vec4 color3 = texture2D(CC_Texture0, v_texCoord + offset * w);
				if (color3.a >= a_limit)
				{
					gl_FragColor = border * (1.0 - (w/width));      // 不透明则将当前像素点设为边框
					return;
				}
			}
		}
	}
}
]]
local size = cc.size(200,200)--node:getBoundingBox()
local glprogram = cc.GLProgram:createWithByteArrays(vert,frag);
local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram);
glprogramstate:setUniformVec2("my_size", {x= size.width,y=size.height});

function SpineTest:setShader(node)
	--print(33,node:getGLProgramState())
	node:setGLProgramState(glprogramstate);
	--local size = node:getTexture():getContentSizeInPixels()
	--local size = node:getBoundingBox()
	--local size = cc.size(400,300)
	--printTable(33,"getBoundingBox ",size)
	--glprogramstate:setUniformVec2("my_size", {x= size.width,y=size.height});
	--glprogramstate:setUniformVec3("u_outlineColor", cc.vec3(1.0, 1.0, 0.0));
	--glprogramstate:setUniformFloat("u_radius", 0.01);
	--glprogramstate:setUniformFloat("u_threshold", 1.75);


	--glprogramstate:setUniformVec2("outlineSize", cc.p(5, 5));
	--glprogramstate:setUniformVec3("outlineColor", cc.vec3(1,0,0));
	--glprogramstate:setUniformVec3("foregroundColor", cc.vec3(1,1,1));

end



function SpineTest:outLine(node)
	--node:setVisible(true)
	--node:update(0)
	--暂时固定大小
	local lineNode = node.lineNode
	local canvas = node.canvas
	local posx,posy = node:getPosition()
	--print(33,"spine getBoundingBox ")
	--printTable(33,"spine getBoundingBox ",size)
	--print(33,"pox:"..posx.."  posy:"..posy)
	
	if not canvas then
		--local size = cc.size(300,250)--node:getBoundingBox()
		if size.width < 1 then
			return
		end
		canvas = cc.RenderTexture:create(size.width,size.height)
		canvas:retain()
		node.canvas = canvas
	end


	canvas:beginWithClear(0,0,0,0)
	--canvas:begin()

	node:setPosition(size.width/2,0)
	node:visit()

	canvas:endToLua()

	node:setPosition(posx,posy)

	if not lineNode  then
		lineNode = cc.Sprite:createWithTexture(canvas:getSprite():getTexture())
		lineNode:setAnchorPoint(0.5,0)
		lineNode:setFlippedY(true);
		lineNode:setPosition(posx, posy)
		node:getParent():addChild(lineNode,8)
		self:setShader(lineNode)
		node.lineNode = lineNode
	else
		lineNode:setTexture(canvas:getSprite():getTexture())

	end


	


	--return lineNode,canvas
end

function SpineTest:TestOutLine(parent)
	
	cc.Director:getInstance():setDisplayStats(true)
	--local parent = ViewManager.getParentLayer(LayerDepth.Alert):displayObject()
	local bg = cc.Sprite:create("Map/100001.jpg")
	parent:addChild(bg)
	bg:setPosition(display.width/2, display.height/2)
	bg:setAnchorPoint(0.5,0.5)
	
	local spinefile = {"Spine/libai","Spine/houyi","Spine/miyue_001","Spine/yinte","Spine/yinte",
		"Spine/ganjimoxie","Spine/ganjimoxie_002","Spine/libai_002","Spine/libai_003","Spine/yinte002",
		"Spine/yinte003","Spine/win","Spine/libai","Spine/libai","Spine/libai",
		"Spine/libai","Spine/libai","Spine/libai","Spine/libai","Spine/libai","Spine/libai"}
	local spinePosX = {0,-200,200,-400,400,-600,600,0,-200,200,-400,400,-600,600,0,-200,200,-400,400,-600,600}
	local spinePosY = {0,0,0,0,0,0,0,-200,-200,-200,-200,-200,-200,-200,200,200,200,200,200,200,200}
	for i = 1, 12 do
		local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile("Spine/houyi"..".skel","Spine/houyi"..".atlas",1,ModelManager.SettingModel:useMinMapMode())
		parent:addChild(skeletonNode,6)
		skeletonNode:setPosition(display.width/2+spinePosX[i],display.height/2+spinePosY[i])
		skeletonNode:setAnimation(0, "stack1", true);
		skeletonNode:setAnchorPoint(0.5,0.5)
		--skeletonNode:setScale(2.5)
		--skeletonNode:setColor({r=255,g=0,b=0})

		--local ghostSp --= self:addGhost2(skeletonNode)
		--skeletonNode:setSpineOutLine(cc.c4b(0,0,0,0))
		--self:setShader(skeletonNode)
		Scheduler.schedule(function ()

				self:outLine(skeletonNode)
			end,0,-1)
	end
end


function SpineTest:showSpine(parent)

	local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile("Spine/houyi"..".skel","Spine/houyi"..".atlas",1,ModelManager.SettingModel:useMinMapMode())
	skeletonNode:setPosition(display.width/2,display.height/2)
	skeletonNode:setAnimation(0, "stack1", true);
	skeletonNode:setAnchorPoint(0.5,0.5)
	parent:addChild(skeletonNode,6)
end

return  SpineTest