// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// MatCap Shader, (c) 2015 Jean Moreno

Shader "FX/_Butter/MatCapMaskedColor"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MatCap ("MatCap (RGB)", 2D) = "white" {}
		_KeyColor ("Key color for masking (RGB)", color) = (0, 0, 0, 0)
		_MulMaskedColor ("Multiplier of masked color", Range(0, 10)) = 1
		_MaskTolerance ("Mask tolerance", Range(0, 1)) = 0.5
		_MatCapCoef ("Matcap coef", Range(0, 1)) = 0.5
	}
	
	Subshader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			Tags { "LightMode" = "Always" }
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				
				struct v2f
				{
					float4 pos	: SV_POSITION;
					float2 uv 	: TEXCOORD0;
					float2 cap	: TEXCOORD1;
				};
				
				uniform float4 _MainTex_ST;
				
				v2f vert (appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos (v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					
					float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
					worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
					o.cap.xy = worldNorm.xy * 0.5 + 0.5;
					
					return o;
				}
				
				uniform sampler2D _MainTex;
				uniform sampler2D _MatCap;
				uniform float3 _KeyColor;
				uniform float _MulMaskedColor;
				uniform float _MaskTolerance;
				uniform float _MatCapCoef;
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 tex = tex2D(_MainTex, i.uv);
					half3 mask = _KeyColor - tex.rgb;
					mask.r = 1.0f - dot(mask, mask);
					mask.r = saturate((mask.r * mask.r) - _MaskTolerance);

					tex = lerp(tex, tex * _MulMaskedColor * mask.r, mask.r);


					fixed4 mc = tex2D(_MatCap, i.cap);
					return tex + ((mc*2.0)-1.0) * _MulMaskedColor * _MatCapCoef;
				}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}