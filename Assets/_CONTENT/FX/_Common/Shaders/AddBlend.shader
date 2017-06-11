// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/AddBlend" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
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

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
				half3 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = _Color.rgb * i.color.rgb * i.color.a * _Color.rgb * _Color.a * _ColorMul;
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.uv);

				color.rgb *= i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
