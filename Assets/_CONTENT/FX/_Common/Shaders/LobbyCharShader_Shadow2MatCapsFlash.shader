// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// MatCap Shader, (c) 2015 Jean Moreno

Shader "FX/_Lobby/Character_Shadow2MatCapsFlash"
{
	Properties
	{
		_MainTex ("Base (RGBA)", 2D) = "white" {}
		_MatCapM1 ("MatCap1 (RGBA)", 2D) = "white" {}
		_MatCapM2 ("MatCap2 (RGBA)", 2D) = "white" {}
		_GlossShadowShine ("Gloss, Skin, Shined (RG)", 2D) = "white" {}
		_Color ("Color Multiplier", Color) = (1, 1, 1, 1)
		_MatsSpecColorOffset ("MatCap1, MatCap2 Spec Color Offset", Vector) = (0.63, 0.38, 0, 0)
		_FlashColor ("Flash Color", Color) = (1, 1, 1, 1)
		_FlashWidthPeriodSpeed ("Flash normalized width, period, speed", Vector) = (0.1, 0.3, -2, 0)
	}
	
	Subshader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			Tags {"LightMode" = "ForwardBase" }
			Cull Back

			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"
				#pragma multi_compile_fwdbase
				
				struct v2f
				{
					float4 pos	: SV_POSITION;
					float4 uv_cap : TEXCOORD0;
					float flashV : TEXCOORD1;
					LIGHTING_COORDS(2,3)
				};
				
				uniform float4 _MainTex_ST;
				uniform sampler2D _MainTex;
				uniform sampler2D _MatCapM1;
				uniform sampler2D _MatCapM2;
				uniform sampler2D _GlossShadowShine;
				uniform float4 _Color;
				uniform float4 _MatsSpecColorOffset;
				uniform float4 _FlashColor;
				uniform float3 _FlashWidthPeriodSpeed;
				
				v2f vert (appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos (v.vertex);
					o.uv_cap.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					
					half3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, v.normal));
					o.uv_cap.zw = VSNormal.xy * 0.5 + 0.5;

					o.flashV = _Time.z * _FlashWidthPeriodSpeed.z;
					
					TRANSFER_VERTEX_TO_FRAGMENT(o);
					
					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 tex = tex2D(_MainTex, i.uv_cap.xy);
					fixed4 mc_m1 = tex2D(_MatCapM1, i.uv_cap.zw);
					fixed4 mc_m2 = tex2D(_MatCapM2, i.uv_cap.zw);
					half2 maskUV = i.uv_cap.xy * (0.5f).xx;
					fixed gloss = tex2D(_GlossShadowShine, maskUV).x;
					fixed specular = tex2D(_GlossShadowShine, maskUV + half2(0.0f, 0.5f)).x;
					fixed inversShadowMul = tex2D(_GlossShadowShine, maskUV + half2(0.5f, 0.0f)).x;
					fixed flashMask = tex2D(_GlossShadowShine, maskUV + half2(0.5f, 0.5f)).x;
					float flashHeightPercentage = 1.0f / _FlashWidthPeriodSpeed.x;
					float flashLine = clamp(sin((i.uv_cap.y + i.flashV * _FlashWidthPeriodSpeed.y)) * flashHeightPercentage - (flashHeightPercentage - 1.0f), 0.0f, 1.0f);

					fixed shadow = lerp(LIGHT_ATTENUATION(i), 1.0f, inversShadowMul);
					fixed4 light = lerp( mc_m2*(1.0f + _MatsSpecColorOffset.y) - _MatsSpecColorOffset.y, mc_m1*(1.0f + _MatsSpecColorOffset.x) - _MatsSpecColorOffset.x, gloss);
					
					return shadow * tex * _Color + light * specular + flashLine * _FlashColor * flashMask;
				}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}