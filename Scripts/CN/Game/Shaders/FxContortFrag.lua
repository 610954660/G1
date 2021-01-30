return [[
varying P_MEDIUM vec2 v_texcoordOut;

#ifdef HAS_VERTEX_COLOR
    varying P_MEDIUM vec4 v_colorOut;
#endif

#ifdef HAS_NORMAL
    varying vec3 v_normal;
#endif

#ifdef HORIZON_KILL
    varying P_MEDIUM float v_clipDist;
#endif

uniform P_MEDIUM vec4 u_color;

#ifdef ALPHA_KILL
    uniform P_MEDIUM float u_alphaKillThreshold;
#endif

#ifdef TEXTURE_SEC
    uniform sampler2D u_textureSec;
    #ifdef HAS_COLOR_SEC
        varying P_MEDIUM vec3 v_colorSec;
    #else
        uniform P_MEDIUM vec3 u_colorSec;
    #endif
    varying P_MEDIUM vec2 v_texcoordOutSec;
    #ifdef TEXTURE_MASK
        uniform sampler2D u_textureMask;
    #endif
#endif

#ifdef HAS_DOF
    uniform P_MEDIUM float u_dofDistance;
    uniform P_MEDIUM float u_dofIntensity;
#endif

#ifdef HAS_FOG
    uniform P_MEDIUM vec4 u_fogColor;
    varying float v_fogDensity;
#endif

void main(void)
{
    #ifdef HORIZON_KILL
        if(v_clipDist < 0.0)
        {
            discard;
        }
    #endif

    #ifdef TEXTURE_MAIN
    	vec2 uvMain = v_texcoordOut;

    	#ifdef TEXTURE_SEC
    	    vec2 uvOffset = texture2D(u_textureSec, v_texcoordOutSec).xy - vec2(0.5);
    	    #ifdef HAS_COLOR_SEC
    	       uvOffset *= v_colorSec.xy;
    		#else
    	       uvOffset *= u_colorSec.xy;
    	    #endif
    	   uvMain += uvOffset;
        #endif

        #ifdef TEXTURE_RGD
    	    P_MEDIUM vec4 col = vec4(texture2D(CC_Texture0, uvMain).rgb, texture2D(CC_Texture1, uvMain).r);
        #else
    	    P_MEDIUM vec4 col = texture2D(CC_Texture0, uvMain);
        #endif
    #else
        P_MEDIUM vec4 col = vec4(1.0);
    #endif

    #ifdef ALPHA_KILL
        #ifdef ALPHA_KILL_INV
            if(col.a > u_alphaKillThreshold)
        #else
            if(col.a <= u_alphaKillThreshold)
        #endif
        {
            discard;
        }
    #endif

    #ifdef HAS_VERTEX_COLOR
        col *= u_color * v_colorOut;
    #else
        col *= u_color;
    #endif

    #ifdef HAS_FOG
        col = mix(col, u_fogColor, v_fogDensity);
    #endif
        
    gl_FragColor = col;
}

]]