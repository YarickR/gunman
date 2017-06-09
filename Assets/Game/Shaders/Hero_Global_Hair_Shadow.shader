// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
Shader "FF/_MatCap/Hero Hair Shadow"
{
	Properties
	{
			_MainTex("Base (RGB)", 2D) = "white" {}
			_HairMask("Hair Mask (A)", 2D) = "black" {}
			_HairTex("Hair Tex (A)", 2D) = "black" {}
			_Depth("Depth", Float) = 0
			_Cubemap("Cubemap", Cube) = "_Skybox" {}
			_HairColor("Hair Spec Color", Color) = (1,1,1,1)

			_ColorAdd("Color Additive", Color) = (0,0,0,0)
		

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
		Pass Replace
	}

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#define UNITY_PASS_FORWARDBASE
		#include "UnityCG.cginc"
		
		uniform samplerCUBE _Cubemap;

	struct VertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 texcoord0 : TEXCOORD0;
	};


	struct VertexOutput
	{
		float4 pos	: SV_POSITION;
		float2 uv 	: TEXCOORD0;
		float2 cap	: TEXCOORD1;
		float4 posWorld : TEXCOORD2;
		float3 normalDir : TEXCOORD3;
	};

	uniform float4 _MainTex_ST;


	VertexOutput vert(VertexInput v)
	{
		VertexOutput o;
		
		//VertexOutput o = (VertexOutput)0;
		o.uv = (v.texcoord0);
		o.normalDir = UnityObjectToWorldNormal(v.normal);
		o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.pos = UnityObjectToClipPos(v.vertex);
				

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;
		
		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _HairMask; 
	uniform sampler2D _HairTex; uniform float4 _HairTex_ST;
	uniform sampler2D _GlobalMatCapTexture;
	uniform float4 _ColorAdd;
	uniform float4 _HairColor;

	fixed4 frag(VertexOutput i) : COLOR	{

	i.normalDir = normalize(i.normalDir);
	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
	float3 normalDirection = i.normalDir;
	float3 viewReflectDirection = reflect(-viewDirection, normalDirection);

	
	fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);
	
	fixed4 tex = tex2D(_MainTex, i.uv);
	float4 hmask = tex2D(_HairMask, i.uv);
	
	float4 htex = tex2D(_HairTex, TRANSFORM_TEX(i.uv, _HairTex));

	float3 cb = (texCUBE(_Cubemap, viewReflectDirection).rgb);
	//float3 hairspec = cb.r;
	float hair = (((cb.r * htex.a) + cb.g) * _HairColor.a) + (cb.b * _HairColor);
	
	float3 finalColor = (tex + (mc*2.0) - 1.0) + _ColorAdd + (hair*hmask.a);
	return fixed4(finalColor, 1);
	}
		ENDCG
	}

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

		Fallback "FF/_MatCap/Hero Shadow"
}