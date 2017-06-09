// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FF/_MatCap/Hero Shadow Sunspots"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Depth("Depth", Float) = 0
		_ColorAdd("Color Additive", Color) = (0,0,0,0)

////SUNSPOTS PARAMETERS
			
		_Coords("Coords", Vector) = (-1,1,-1,1)
		_Foliage("Foliage", 2D) = "white" {}
		_LightColor("LightColor", Color) = (1,1,1,1)
		_Amplitude("Amplitude", Float) = 1

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
			//Comp NotEqual
			Pass Replace

		}
		
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
//#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

		uniform float4 _TimeEditor;
		uniform float4 _Coords;
		uniform sampler2D _Foliage; uniform float4 _Foliage_ST;
		uniform float4 _LightColor;
		uniform float _Amplitude;

//		struct appdata {
			//float4 vertex : POSITION;
			//float2 texcoord : TEXCOORD0;
			//float3 normal : NORMAL;
		//};

	struct v2f
	{
		float4 pos	: SV_POSITION;
		float2 uv 	: TEXCOORD0;
		float2 cap	: TEXCOORD1;
		float3 normalDir : TEXCOORD2;
		float4 posWorld : TEXCOORD3;
	};

	uniform float4 _MainTex_ST;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.uv = v.texcoord;
		o.normalDir = UnityObjectToWorldNormal(v.normal);
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

		i.normalDir = normalize(i.normalDir);
		float3 normalDirection = i.normalDir;


		float2 FoliageAUV = float2((i.posWorld.r + (_SinTime.a *_Amplitude)),i.posWorld.b);
		float4 _FoliageA = tex2D(_Foliage,TRANSFORM_TEX(FoliageAUV, _Foliage));
		float2 FoliageBUV = float2(i.posWorld.r, ((_CosTime.a * _Amplitude) + i.posWorld.b));
		float4 _FoliageB = tex2D(_Foliage,TRANSFORM_TEX(FoliageBUV, _Foliage));
		float sunspotsmask = (_FoliageA.g + _FoliageB.b);
		float2 MainMaskUV = (float2(_Coords.r, _Coords.g) + (float2(_Coords.b, _Coords.a)*float2(i.posWorld.r, i.posWorld.b)));
		float4 _FoliageMask = tex2D(_Foliage,MainMaskUV);
		float3 emissive = (sunspotsmask*(i.normalDir.g*3.333333 - 1.666667)*_LightColor.rgb*_FoliageMask.r);



		fixed4 tex = tex2D(_MainTex, i.uv);
		fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);
		
		return fixed4(((tex + (mc*2.0) - 1.0) + saturate(emissive) + _ColorAdd),1);
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

		Fallback "VertexLit"
}