// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Gunsmith/FiredGround" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite Off
            Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
            
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
				float2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float4 stoneUV_waveUV : TEXCOORD0;
				half4 preMulAlphaColor_vertexAlpha : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.stoneUV_waveUV.xy = TRANSFORM_TEX(v.texcoord, _MainTex) * half2(1.0f, 0.5f);
				o.stoneUV_waveUV.zw = o.stoneUV_waveUV.xy + frac(half2(-_Time.y*0.7f, 0.5f));
				o.preMulAlphaColor_vertexAlpha.rgb = v.color.rgb * COLOR_MULTIPLIER;
				o.preMulAlphaColor_vertexAlpha.a = v.color.a;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 col;
				col = tex2D(_MainTex, i.stoneUV_waveUV.xy);
				half4 waveColor;
				waveColor.rgb = tex2D(_MainTex, i.stoneUV_waveUV.zw).rgb;
				waveColor.a = tex2D(_MainTex, i.stoneUV_waveUV.xy ).a;

				col.a = col.a * i.preMulAlphaColor_vertexAlpha.a;
				col.rgb = col.rgb * i.preMulAlphaColor_vertexAlpha.rgb * saturate(waveColor.rgb * waveColor.a + 0.5);
				return col;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
