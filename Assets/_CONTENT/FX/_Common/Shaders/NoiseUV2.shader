// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/NoiseUV2" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_NoiseUV ("NoiseUV RG", 2D) = "bump" {}
		_NoiseSpeed_Force ("Noise speed (U,V), Noise force (U, V)", vector) = (0.5, 0.5, 0.1, 0.1)
		_ColorMul_TexScrol("Color Multiplier (float), Tex scrolling (UV)", vector) = (10.0, 1.0, 1.0, 0.0)
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
            Blend One One
            
            CGPROGRAM
			#define TEST
            
            #define UNITY_PASS_FORWARDBASE
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float3 _Color;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
			uniform sampler2D _NoiseUV; 
			uniform float4 _NoiseUV_ST;
			uniform half4 _NoiseSpeed_Force;
			uniform half3 _ColorMul_TexScrol;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float4 uv_uv2 : TEXCOORD0;
				half3 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex);
				o.color = _Color * _ColorMul_TexScrol.x * v.color.rgb * v.color.a;

				o.uv_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex).xy + frac(_Time.z * _ColorMul_TexScrol.yz);

				o.uv_uv2.zw = TRANSFORM_TEX(v.uv, _NoiseUV).xy + frac(_Time.z * _NoiseSpeed_Force.xy);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{	
				half2 noise = tex2D(_NoiseUV, i.uv_uv2.zw).rg * 2.0f - 1.0f;
				half4 color = tex2D(_MainTex, i.uv_uv2.xy + noise * _NoiseSpeed_Force.zw);
				color.rgb *= i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
