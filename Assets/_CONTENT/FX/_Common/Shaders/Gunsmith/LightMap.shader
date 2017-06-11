// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Gunsmith/Lightmap" {
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
            Blend One SrcAlpha
            
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
				half4 color : COLOR;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color * _Color;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 color = tex2D(_MainTex, i.uv.xy);
				color.a *= 2.0f;
				color = color * i.color; // тут кажется лишнее умножение на альфу из партикловой системы.
				color.rgb = color.rgb * COLOR_MULTIPLIER + saturate(color.a - 1.0f);
				color.rgb *= i.color.a;
				color.a += 1.0f - i.color.a;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
