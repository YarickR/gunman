// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Psycho/Puddle_geom" {
    Properties {
        _Color ("Water", Color) = (0.2, 0.7, 1, 1)
		_Color2 ("Foam", Color) = (0.5, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
		_PuddleRadius ("Puddle radius", float ) = 3.0
		_TexMask ("Masking texture in center", float ) = 0.5
		_ScrollSpeed ("Scroll speed (UV)", vector) = ( 1.0, 0.0, 0,0)
		_Amplitude ("Puddle amplitude", float ) = 0.2
		_Friq ("Wave Friquence", float ) = 6.0
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
			uniform float4 _Color2;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
			uniform float _ColorMul;
			uniform float _PuddleRadius;
			uniform float2 _ScrollSpeed;
			uniform float _Amplitude;
			uniform float _TexMask;
			uniform float _Friq;

			struct appdata {
				half4 vertex : POSITION;
				float3 uv : TEXCOORD0;
				float3 uv2 : TEXCOORD1;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float3 uv_textureMask : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				float distance = dot(i.uv2.xyz, i.uv2.xyz);
				i.vertex.y += (sin((i.color.a + 0.5f) * _Friq + distance) + 1.0f) * _Amplitude * saturate( 1.0f * _PuddleRadius - distance);
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = i.color;

				o.color.rgb *= _ColorMul;
				o.uv_textureMask.xy = TRANSFORM_TEX(i.uv, _MainTex) - frac(_Time.y * _ScrollSpeed);
				o.uv_textureMask.z = saturate(distance * _TexMask);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.uv_textureMask.xy);
				color.r = dot(color.rgb, fixed3(0.333f, 0.333f, 0.333f)).r;

				color.r *= i.uv_textureMask.z;

				color = lerp(_Color, _Color2, color.rrrr);
				color *= i.color;

				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
