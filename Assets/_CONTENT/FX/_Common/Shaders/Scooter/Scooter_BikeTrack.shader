// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Scooter/Scooter_BikeTrack" {
    Properties {
        _Color ("Color for white", Color) = (1,1,1,1)
        _MainTex ("Black&White Mask", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
		_MidColor ("Middle Color", Color) = (1,0,0,0)
		_LastColor ("Color for black", Color) = (0,0,0,0)
		_MiddleColorPos ("Middle color position ", Range (0, 1)) = 0.8
		_ScrollSpeed ("Scrool speed", float ) = 2.5

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
            Blend One One
			
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
			uniform float4 _MidColor;
			uniform float4 _LastColor;
			uniform float _MiddleColorPos;
			uniform float _ScrollSpeed;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = i.color.rgb * i.color.a * _Color.a * _ColorMul;
				o.uv = TRANSFORM_TEX(i.uv, _MainTex).xy;
				o.u -= frac(_Time.z * _ScrollSpeed);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				float mask = tex2D(_MainTex, i.uv).r;
				float3 upperGradientColor = lerp(_MidColor.rgb, _Color.rgb, (mask - _MiddleColorPos) / (1.0f - _MiddleColorPos) );
				float3 lowerGradientColor = lerp(_LastColor.rgb, _MidColor.rgb, mask * (1.0f / _MiddleColorPos));
				float upperMul = saturate((mask - _MiddleColorPos) * 10000000.0f);
				float3 color = lerp(lowerGradientColor, upperGradientColor, upperMul);

				color *= i.color * mask;
				return float4(color, 1.0f);

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
