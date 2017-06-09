// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FF/_MatCap/Hero Shadow Foliage Shadow"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Depth("Depth", Float) = 0
		_ColorAdd("Color Additive", Color) = (0,0,0,0)

		_TopShadow("Top Shadow", 2D) = "white" {}
		_Coords("Coords", Vector) = (-1,1,-1,1)

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
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos	: SV_POSITION;
		float2 uv 	: TEXCOORD0;
		float2 cap	: TEXCOORD1;
		float4 posWorld : TEXCOORD2;
	};

	uniform float4 _MainTex_ST;
	
	v2f vert(appdata_base v)
	{
		v2f o;
		
		o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;

		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _GlobalMatCapTexture;
	
	uniform sampler2D _TopShadow;
	uniform float4 _Coords;
	
	uniform float4 _ColorAdd;

	fixed4 frag(v2f i) : COLOR
	{
		
		float2 shadow_uvs = float2((((i.posWorld.r - _Coords.r)) / (_Coords.g - _Coords.r)), (((i.posWorld.b - _Coords.b)) / (_Coords.a - _Coords.b)));
		float4 _MainTex_var = tex2D(_MainTex, TRANSFORM_TEX(shadow_uvs, _MainTex));
		
		fixed4 tex = tex2D(_MainTex, i.uv);
		fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);
		return (tex + (mc*2.0) - 1.0) + _ColorAdd;
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