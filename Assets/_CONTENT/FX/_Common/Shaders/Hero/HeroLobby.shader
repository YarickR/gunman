// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hero/Lobby"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Depth("Depth", Float) = 0
		_ColorAdd("Color Additive", Color) = (0,0,0,0)
		_ColorMul("Color Multiplier", Color) = (1,1,1,1)
		_FresnelPower ("Fresnel Power", float) = 1.0
		_FresnelColorInner ("Fresnel Color Inner", Color) = (0, 0, 0, 0)
		_FresnelColorOuter ("Fresnel Color Outer", Color) = (0, 0, 0, 0)
		_FresnelColorMul ("Fresnel Color Mul", float) = 0
		_MatCapColorMul ("Matcap Color Multiplier", Float) = 1
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
		float3 color: COLOR;
	};

	uniform float4 _MainTex_ST;
	uniform sampler2D _MainTex;
	uniform sampler2D _GlobalMatCapTexture;
	uniform float4 _ColorAdd;
	uniform float4 _ColorMul;
	uniform float _FresnelPower;
	uniform float3 _FresnelColorInner;
	uniform float3 _FresnelColorOuter;
	uniform float _FresnelColorMul;
	uniform float _MatCapColorMul;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;
		
		float3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, v.normal));
		float fresnelFactor = abs( dot(VSNormal, half3(0.0f, 0.0f, 1.0f) ) );
		o.color = lerp( _FresnelColorInner, _FresnelColorOuter, pow(fresnelFactor, _FresnelPower));

		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, i.uv);
		fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);

		return ((mc*2.0f) - 1.0f) * _MatCapColorMul + tex * _ColorMul + _ColorAdd + fixed4(i.color * _FresnelColorMul, 1.0f);
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