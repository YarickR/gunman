// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_UI/TutorialFrame" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_Scale ("Scale", float) = 1
		_Offset_Skew ("Height, Width; Horizontal Skew", vector) = (1,1,0,0)
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
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha
			
            CGPROGRAM
			#define TEST
            
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
			uniform float _ColorMul;
			uniform float3 _Offset_Skew;
			uniform float _Scale;

			struct appdata {
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
				half3 normals : NORMAL;
			};

			struct v2f {
				half4 pos : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex = v.vertex * float4(_Scale.xx, 1.0f, 1.0f) + v.normals.xyzz * float4(_Offset_Skew.xy, 0, 0) + float4(sign(v.normals.y) * _Offset_Skew.z * (_Offset_Skew.y - 120.0f * _Scale), 0, 0, 0);
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor) * _ColorMul;
				o.color.a = v.color.a * alphaBlendFactor;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color;
				fixed4 tex = tex2D(_MainTex, i.texcoord).rgbr;
				color = tex * i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
