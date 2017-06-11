// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/TrailAlphaBlend" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Multiplier", Color) = (1,1,1,1)
		_ColorMul ("Color Multiplier", float) = 3
    }
    SubShader {
    	Tags { 
    		"Queue"="Transparent" 
    		"RenderType"="Transparent" 
    	}
		Pass {
			Name "FORWARD"
			Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            ZWrite Off
            Blend One OneMinusSrcAlpha
           
            CGPROGRAM
            #define UNITY_PASS_FORWARDBASE
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
 
            #include "UnityCG.cginc"
 
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _ColorMul;
           
            // Struct Input || VertOut
            struct appdata {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };
           
            //VertIn
            struct v2f {
                half4 pos : POSITION;
                half2 texcoord : TEXCOORD0;
                half4 preMulAlphaColor_alphaBlendFactor : COLOR;
            };
 
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				float distance = length(v.vertex.x + v.vertex.z);
				#define textureScaleU 2.0f
				#define scrollingSpeed 0.4f
				o.texcoord.x = o.texcoord.x - distance * scrollingSpeed - o.texcoord.x * scrollingSpeed * 2.5f; //world position based scrolling uv
				o.texcoord.x *= scrollingSpeed * 1.2;

 				o.preMulAlphaColor_alphaBlendFactor.a = ( 1.0f - saturate(( max( max(v.color.r, v.color.g), v.color.b) - 0.5f) * 2.0f)) * v.color.a;
 				o.preMulAlphaColor_alphaBlendFactor.rgb = v.color.rgb * v.color.a * _ColorMul * _Color.rgb * _Color.a;
                return o;
            }
           
 
            fixed4 frag (v2f i) : COLOR
            {
                float4 col;
                fixed tex = tex2D(_MainTex, i.texcoord).r;
 
                col.rgb = tex * i.preMulAlphaColor_alphaBlendFactor.rgb;
                col.a = tex * i.preMulAlphaColor_alphaBlendFactor.a;
                return col;
               
            }
            ENDCG          
        }
    }
    FallBack "Diffuse"
}