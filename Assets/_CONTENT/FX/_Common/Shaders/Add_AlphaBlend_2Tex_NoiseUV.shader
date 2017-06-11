// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Add_AlphaBlend_2Tex_NoiseUV" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_Emissive ("Emissive color", Color) = (1,1,1,1)
        _EmissiveTex ("Emissive texture", 2D) = "white" {}
		_NoiseUV ("NoiseUV RG", 2D) = "bump" {}
		_NoiseSpeed_Force ("Noise speed (U,V), Noise force (U, V)", vector) = (0.5, 0.5, 0.1, 0.1)
		_EmissiveMul_TexScrol("Emissive Multiplier (float), Emissive scrolling (UV)", vector) = (10.0, 1.0, 1.0, 0.0)
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
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha
			
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float4 _Color;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
			uniform float _ColorMul;

			uniform float3 _Emissive;
			uniform sampler2D _EmissiveTex;
			uniform float4 _EmissiveTex_ST;
			uniform sampler2D _NoiseUV; 
			uniform float4 _NoiseUV_ST;
			uniform half4 _NoiseSpeed_Force;
			uniform half3 _EmissiveMul_TexScrol;

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float4 uv_uv2 : TEXCOORD0;
				half4 color : COLOR;
				float2 noiseUV: TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.uv_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_uv2.zw = TRANSFORM_TEX(v.uv, _EmissiveTex) + frac(_Time.z * _EmissiveMul_TexScrol.yz);
				o.noiseUV = TRANSFORM_TEX(v.uv, _NoiseUV) + frac(_Time.z * _NoiseSpeed_Force.xy);

				float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = v.color.a * alphaBlendFactor;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color;
				fixed4 tex = tex2D(_MainTex, i.uv_uv2.xy);
				color = tex * i.color;

				half2 noise = tex2D(_NoiseUV, i.noiseUV).rg * 2.0f - 1.0f;
				half3 emissive = tex2D(_EmissiveTex, i.uv_uv2.zw + noise * _NoiseSpeed_Force.zw).rgb;
				color.rgb += emissive * _EmissiveMul_TexScrol.x * _Emissive;

				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
