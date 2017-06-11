﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Add_AlphaBlend_VertexOffset_NoiseUV_EraseAlpha" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_NoiseTex ("NoiseUV (RG)", 2D) = "bump" {}
		_NoiseForce_Speed ("Noise Force(float2) Speed (float2)", vector) = (0.5, 0.5, 1, 1)
		_VertexOffset ("Vertex offset following to normals", float) = 0
		_VertexOffsetMul ("Vertex offset multiplier", vector) = (1,0,1,0)
		_EraseAlphaTex ("EraseAlphaTex", 2D) = "white" {}
		_AlphaErase ("Alpha Erase factor", float) = 0.1


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
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTex_ST;
			uniform float4 _NoiseForce_Speed;
			uniform float _VertexOffset;
			uniform float3 _VertexOffsetMul;
			uniform sampler2D _EraseAlphaTex;
			uniform float4 _EraseAlphaTex_ST;
			uniform float _AlphaErase;


			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
				float3 normals : NORMAL;
			};

			struct v2f {
				half4 pos : POSITION;
				half4 uv1_uv2 : TEXCOORD0;
				half2 uv3 : TEXCOORD1;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex += float4(v.normals * _VertexOffsetMul, 0.0f) * _VertexOffset;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);

				o.uv3 = TRANSFORM_TEX(v.uv, _EraseAlphaTex);

				float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = v.color.a * alphaBlendFactor;

				o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _NoiseTex) + frac(_Time.z * _NoiseForce_Speed.zw);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half2 noise = tex2D(_NoiseTex, i.uv1_uv2.zw).rg * 2.0f - 1.0f;
				
				half eraseAlpha = tex2D(_EraseAlphaTex, i.uv3 + noise * _NoiseForce_Speed.xy).r;

				fixed4 color = tex2D(_MainTex, i.uv1_uv2.xy + noise * _NoiseForce_Speed.xy);
				color *= i.color;
				
				//color.a = saturate(color.a - saturate(eraseAlpha * _AlphaErase));
				//color.rgb = lerp(color.rgb, (0.0f).rrr, eraseAlpha * _AlphaErase);
				color = lerp(color, (0.0f).rrrr, eraseAlpha * _AlphaErase) * (1.0f + _AlphaErase);
				return color;
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
