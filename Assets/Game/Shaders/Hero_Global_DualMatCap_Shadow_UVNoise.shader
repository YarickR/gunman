// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Hero Dual MatCap NoiseUV Shadow"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Mask("MatCap 2 Mask (RGB)", 2D) = "black" {}
		_MatCapTwo("MatCap 2 (RGB)", 2D) = "black" {}
		_NoiseUV("Noise UV (RG)", 2D) = "black" {}

		_NoiseParams("Noise UV Params (Speed, Amplitude)", vector) = (1,1,0,0)
		_Depth("Depth", Float) = 0
		_ColorAdd("Color Additive", Color) = (0,0,0,0)		
	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass{
		Name "FORWARD"
		ZWrite On
		Tags{ }
			Stencil{
			Ref 13
			Pass Replace

		}
		
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
		float2 uvn  : TEXCOORD2;

	};

	//uniform float4 _MainTex_ST;
	uniform float4 _NoiseUV_ST;
	uniform float4 _NoiseParams;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uvn = TRANSFORM_TEX(v.texcoord, _NoiseUV)+(_Time.xx) * (_NoiseParams.xy);
		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;

		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _Mask;
	uniform sampler2D _MatCapTwo;
	uniform sampler2D _NoiseUV;
	uniform sampler2D _GlobalMatCapTexture;
	//uniform float4 _NoiseParams;
	uniform float4 _ColorAdd;

	fixed4 frag(v2f i) : COLOR
	{	
		//fixed4 texa = tex2D(_MainTex, i.uv);
		float2 noise = (((tex2D(_NoiseUV, i.uvn).rg)*2-1) * _NoiseParams.zw);
		fixed4 mask = tex2D(_Mask, i.uv);
		float2 noised = lerp(i.uv, (i.uv + noise), (mask.g));
		fixed4 tex = tex2D(_MainTex, noised);
		fixed4 mca = tex2D(_GlobalMatCapTexture, i.cap);
		fixed4 mcb = tex2D(_MatCapTwo, i.cap);
		fixed4 mcm = lerp(mca.rgba, mcb.rgba, mask.r);
		return (tex + (mcm*2.0) - 1.0) + _ColorAdd;
		
	}
		ENDCG
	}

///VERTEX SHADOW PASS
		Pass {
		Name "FORWARD"
		Tags {	}
		Blend DstColor Zero
		Stencil{
		Ref 128
		Comp NotEqual
		Pass Replace
		
	}
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#pragma target 2.0
	uniform float4 _GlobalShadowColor;
	uniform float4 _GlobalShadowParams;
	uniform float _Depth;
	float3 WorldSpaceToLocalSpace(float3 WorldSpace , float OffsetX , float OffsetY) {
		WorldSpace.xz += float2(OffsetX, OffsetY) * WorldSpace.y;
		WorldSpace.y = 0;
		return mul(unity_WorldToObject, float4(WorldSpace, 1)).xyz;
	}

	struct VertexInput {
		float4 vertex : POSITION;
	};
	struct VertexOutput {
		float4 pos : SV_POSITION;

	};
	VertexOutput vert(VertexInput v) {
		VertexOutput o = (VertexOutput)0;

		float3 worldSpaceP = mul(unity_ObjectToWorld, v.vertex);

		worldSpaceP.xz += float2(_GlobalShadowParams.z, _GlobalShadowParams.w) * worldSpaceP.y;
		worldSpaceP.y = _Depth;



		o.pos = mul(UNITY_MATRIX_VP, float4(worldSpaceP, 1));
		return o;
	}
	fixed4 frag(VertexOutput i) : COLOR{


		return _GlobalShadowColor + _GlobalShadowColor.a;

	}
		ENDCG
	}


	}

		Fallback "FF/_MatCap/Hero Dual MatCap Shadow"
}