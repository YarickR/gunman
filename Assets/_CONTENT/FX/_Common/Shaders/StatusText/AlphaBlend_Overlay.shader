// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/StatusText/AlphaBlend_Overlay" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha
            
            CGPROGRAM
			#define TEST
            #define COLOR_MULTIPLIER 3.0f
            
            #define UNITY_PASS_FORWARDBASE
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float4 _Color;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;

			struct appdata {
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				half3 texcoord_alphaBlendFactor : TEXCOORD0;
				half4 preMulAlphaColor_vertexAlpha : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.texcoord_alphaBlendFactor.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.preMulAlphaColor_vertexAlpha.rgb = v.color.rgb * v.color.a * COLOR_MULTIPLIER;
				o.texcoord_alphaBlendFactor.z = saturate(max(max(v.color.r, v.color.g), v.color.b) * COLOR_MULTIPLIER - 1.0f); // 0 = alphablend, 1 = additive blend
				o.preMulAlphaColor_vertexAlpha.a = v.color.a * (1.0f - o.texcoord_alphaBlendFactor.z);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				float4 col;
				fixed4 tex = tex2D(_MainTex, i.texcoord_alphaBlendFactor.xy);

				col.a = tex.a * i.preMulAlphaColor_vertexAlpha.a;
				col.rgb = tex.rgb * saturate(tex.a + i.texcoord_alphaBlendFactor.z) * i.preMulAlphaColor_vertexAlpha.rgb;
				return col;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
