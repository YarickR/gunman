// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/AlphaBlend_RGBtoAlpha_Atlas_EraseAlpha" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
		_FramesCount ("Frame Count", float) = 4.0
		_AlphaSmoothFactor ("Alpha Smooth Factor", float) = 0.1
		_MinAlpha ("Min Alpha", float) = 0.1
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
            Blend SrcAlpha OneMinusSrcAlpha
			
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
			uniform float _FramesCount;
			uniform float _AlphaSmoothFactor;
			uniform float _MinAlpha;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				half3 uv_frameLifetime : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = _Color;
				o.color.rgb *= _ColorMul * i.color.rgb;
				o.uv_frameLifetime.xy = TRANSFORM_TEX(i.uv, _MainTex);
				float onedivFramesCount = 1.0f / _FramesCount;
				o.uv_frameLifetime.y *= onedivFramesCount;
				float frame = saturate(i.color.a - 0.0001f) * _FramesCount;
				o.uv_frameLifetime.z = saturate(1.0f - frac(frame) - _MinAlpha);
				o.uv_frameLifetime.y += onedivFramesCount * floor(frame);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.uv_frameLifetime.xy);
				color.a = (color.r + color.g + color.b) * 0.33333f;
				color = smoothstep( saturate(i.uv_frameLifetime.z - _AlphaSmoothFactor),
									saturate(i.uv_frameLifetime.z + _AlphaSmoothFactor),
									color.a).rrrr;
				color *= i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
