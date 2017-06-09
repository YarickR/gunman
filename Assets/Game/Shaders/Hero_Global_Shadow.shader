// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FF/_MatCap/Hero Shadow"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Depth("Depth", Float) = 0
		_ColorAdd("Color Additive", Color) = (0,0,0,0)
		_OutlineColor("Outline Color", Color) = (0.5,0.5,0.5,1)

	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }



		Pass{
		Name "FORWARD"
		ZWrite On
		Tags{}
		Stencil{
		Ref 13
		//Comp NotEqual
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
		fixed4 vertexColor : COLOR;
	};

	uniform float4 _MainTex_ST;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;


		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _GlobalMatCapTexture;
	uniform float4 _ColorAdd;

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, i.uv);
	fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);
	return (tex + (mc*2.0) - 1.0) + _ColorAdd;
	}
		ENDCG
	}


/*
		////////////////////////////////
		//////////Outline Pass//////////
		////////////////////////////////


		Pass{
		Name "Outline"
		Tags{}
		Stencil{
		Ref 13
		Comp NotEqual
		//Pass Replace
	}
		Cull Front

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#pragma fragmentoption ARB_precision_hint_fastest
#pragma target 2.0

		uniform float4 _GlobalShadowParams;
	uniform float4 _OutlineColor;
	uniform fixed  _colnorm;

	struct VertexInput {
		float4 vertex : POSITION;
		fixed4 color : COLOR;
		fixed4 normal : NORMAL;

	};
	struct VertexOutput {
		float4 pos : SV_POSITION;
		float4 col : COLOR;
		float4 nor : NORMAL;
	};
	VertexOutput vert(VertexInput v) {
		VertexOutput o = (VertexOutput)0;
		o.col = (v.color - .5) * 2;
		o.col.g = -o.col.g;
		o.col = o.col.gbra;
		o.nor = v.normal;
		o.pos = mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz + (o.col) * _GlobalShadowParams.x, 1));
		return o;
	}
	float4 frag(VertexOutput i) : COLOR{
		//float4 colnorm_var = (i.col.rrrr);
		//float4 colnorm_var = lerp((i.col), (i.nor),  _colnorm);
		//float4 colnorm_var = lerp((i.col.gbra), (i.nor.rgba),  _colnorm);
		//return fixed4(colnorm_var);
		//return fixed4(i.nor.r, 0,0,0);
		return fixed4(_OutlineColor.rgb,0);

	}
		ENDCG
	}


		////////////////////////////////
		//////////Outline Pass//////////
		////////////////////////////////


		*/


		///VERTEX SHADOW PASS
		Pass{
		Name "FORWARD"
		Tags{}
		Blend DstColor Zero
		//ZWrite Off
		//Offset - 5, -5
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
	//uniform float _Fade;
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

		Fallback "FF/_MatCap/Hero"
}