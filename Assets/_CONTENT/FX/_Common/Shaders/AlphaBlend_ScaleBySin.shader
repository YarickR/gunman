// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/AlphaBlend_ScaleBySin" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMultiplier ("Color mul", float) = 3
		_SinAmpl ("Sin amplitude", vector) = (0,1,0,0)
		_SinPeriod ("Sin period", float) = 8
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
			uniform float _ColorMultiplier;
			uniform float4 _SinAmpl;
			uniform float _SinPeriod;

			struct appdata {
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				half2 texcoord2 : TEXCOORD1;
				half4 color : COLOR;
				half4 noise : NORMAL;
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
				
				v.vertex += _SinAmpl * sin(_Time.z * _SinPeriod * v.texcoord2.y ) * v.texcoord2.x;
				
				o.pos = UnityObjectToClipPos(v.vertex);

				v.color *= _Color;
				o.texcoord_alphaBlendFactor.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.preMulAlphaColor_vertexAlpha.rgb = v.color.rgb * v.color.a * _ColorMultiplier;
				o.texcoord_alphaBlendFactor.z = saturate(max(max(v.color.r, v.color.g), v.color.b) * _ColorMultiplier - 1.0f); // 0 = alphablend, 1 = additive blend
				o.preMulAlphaColor_vertexAlpha.a = v.color.a * (1.0f - o.texcoord_alphaBlendFactor.z);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 col;
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
