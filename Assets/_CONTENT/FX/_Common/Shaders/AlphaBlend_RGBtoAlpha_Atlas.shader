// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/AlphaBlend_RGBtoAlpha_Atlas" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
		_FramesCount ("Frame Count", float) = 4.0
		_MaxAlpha ("Max Alpha", float) = 0.05
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
			
			Offset -3, -3 //"Приподнимает" всё, рисуемое этим шейдером на 3 единицы только по порядку рендера.
						  //В результате все эффекты рисуются поверх других объектов, даже если немного утоплены под них (не более чем на 3 единицы)

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
			uniform float _MaxAlpha;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = _Color;
				o.color.rgb *= _ColorMul * i.color.rgb;
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				float onedivFramesCount = 1.0f / _FramesCount;
				o.uv.y *= onedivFramesCount;
				float frame = saturate(i.color.a - 0.0001f) * _FramesCount;
				o.uv.y += onedivFramesCount * floor(frame);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				color.a = (color.r + color.g + color.b) * 0.33333f;
				color.rgb = color.aaa;
				color.a = color.a < _MaxAlpha ? color.a: 1.0f;
				color *= i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
