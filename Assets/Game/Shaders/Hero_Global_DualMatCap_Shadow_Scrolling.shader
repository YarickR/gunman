// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FF/_MatCap/Hero Dual MatCap Shadow Scrolling"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Mask("MatCap 2 Mask (RGB)", 2D) = "black" {}
		_MatCapTwo("MatCap 2 (RGB)", 2D) = "black" {}
		_ScrollTex("Scrolling Texture (RGB)", 2D) = "white" {}
		_ScrollColor("Scroll Texture Color Mul (RGB)", Color) = (0,0,0,0)
		_ScrollColorMul_Speed_PixelSize("Scroll Texture Color Mul, Speed, Pixelizing Size (X,YZ,W)", Vector) = (1,0.1,0,50)
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
		float4 uv 	: TEXCOORD0;
		float2 cap	: TEXCOORD1;
	};

	uniform float4 _MainTex_ST;
	uniform sampler2D _ScrollTex;
	uniform float4 _ScrollTex_ST;
	uniform float4 _ScrollColorMul_Speed_PixelSize;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv.zw = TRANSFORM_TEX(v.texcoord, _ScrollTex);
		o.uv.zw += float(_Time.z).xx * _ScrollColorMul_Speed_PixelSize.yz;
		o.uv.zw = floor(o.uv.zw * _ScrollColorMul_Speed_PixelSize.w) / _ScrollColorMul_Speed_PixelSize.w;

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;

		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _Mask;
	uniform sampler2D _MatCapTwo;
	uniform sampler2D _GlobalMatCapTexture;
	uniform float4 _ColorAdd;
	uniform float3 _ScrollColor;

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, i.uv.xy);
		fixed4 mask = tex2D(_Mask, i.uv.xy);
		fixed3 tex2 = tex2D(_ScrollTex, floor(i.uv.zw * _ScrollColorMul_Speed_PixelSize.w) / _ScrollColorMul_Speed_PixelSize.w).rgb;
		fixed4 mca = tex2D(_GlobalMatCapTexture, i.cap);
		fixed4 mcb = tex2D(_MatCapTwo, i.cap);
		fixed4 mcm = lerp(mca.rgba, mcb.rgba, mask.r);
		return (tex + (mcm*2.0) - 1.0) + _ColorAdd + fixed4(tex2 * _ScrollColor * _ScrollColorMul_Speed_PixelSize.x * mask.g, 1.0f);
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