// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Lobby/Character_Flash"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MatCapM ("MatCap1 (RGB)", 2D) = "white" {}
		_FlashM ("Flash Mask (BW)", 2D) = "white" {}
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
				#pragma multi_compile_fwdbase
				
				struct v2f
				{
					float4 pos	: SV_POSITION;
					float4 uv_cap : TEXCOORD0;
					float flashV : TEXCOORD1;
				};
				
				uniform float4 _MainTex_ST;
				uniform sampler2D _MainTex;
				uniform sampler2D _MatCapM;
				uniform sampler2D _FlashM;
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

					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 tex = tex2D(_MainTex, i.uv_cap.xy);
					fixed4 mc_m = tex2D(_MatCapM, i.uv_cap.zw);
					half2 maskUV = i.uv_cap.xy * (0.5f).xx;

					fixed flashMask = tex2D(_FlashM, i.uv_cap.xy).x;
					float flashHeightPercentage = 1.0f / _FlashWidthPeriodSpeed.x;
					float flashLine = clamp(sin((i.uv_cap.y + i.flashV * _FlashWidthPeriodSpeed.y)) * flashHeightPercentage - (flashHeightPercentage - 1.0f), 0.0f, 1.0f);

					fixed4 light = mc_m * 2.0f - 1.0f;
					
					return tex + light + flashLine * _FlashColor * flashMask.x;
				}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}