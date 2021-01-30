
return [[
	#ifdef GL_ES
		precision mediump float;
	#endif

	varying vec2 v_texCoord;	
	uniform vec2 unit_matrix;	
	uniform float blurRaius;	//模糊半径
	uniform float sampleNum;	//采样数

	void main(void)
	{
		if (blurRaius > 0.0 && sampleNum > 1.0)
		{
			vec4 col = vec4(0);

			float r = blurRaius;
			float step = r/sampleNum;
			float count = 0.0;
			for(float x = -r; x < r; x += step)
			{
				for(float y = -r; y < r; y += step)
				{
					float weight = (r - abs(x)) * (r - abs(y));
					col += texture2D(CC_Texture0, v_texCoord + vec2(x*unit_matrix.x,y*unit_matrix.y)) * weight;
					count += weight; 
				}
			}
			gl_FragColor = col/count;
		}
		else
		{
			gl_FragColor = texture2D(CC_Texture0, v_texCoord).rgba;
		}
	}
]]