// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FF/_MatCap/Hero Static Shadow"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_MatCap("MatCap (RGB)", 2D) = "white" {}

	_Color("Shadow Color", Color) = (0.5,0.5,0.5,1)
		_Parameters("Parameters", Vector) = (0,2,1,1)
		_Depth("Depth", Float) = 0
	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass{
		Name "FORWARD"
		ZWrite On
		Tags{ }
		
		
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
	uniform sampler2D _MatCap;

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, i.uv);
	fixed4 mc = tex2D(_MatCap, i.cap);

	return (tex + (mc*2.0) - 1.0);
	}
		ENDCG
	}

///VERTEX SHADOW PASS
		Pass {
		Name "FORWARD"
		Tags {	}
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
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#pragma multi_compile_fwdbase
#pragma target 2.0
		uniform float4 _Color;
	uniform float4 _Parameters;
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

		worldSpaceP.xz += float2(_Parameters.z, _Parameters.w) * worldSpaceP.y;
		worldSpaceP.y = _Depth;



		o.pos = mul(UNITY_MATRIX_VP, float4(worldSpaceP, 1));
		return o;
	}
	float4 frag(VertexOutput i) : COLOR{


		return _Color + _Color.a;

	}
		ENDCG
	}


	}

		Fallback "VertexLit"
}