// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//

Shader "FF/_MatCap/Hero Outlined Test"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_ColorAdd("Color Additive", Color) = (0,0,0,0)

			////////////////////////////////
			//////////Outline Parms/////////
			////////////////////////////////

			_OutlineColor("Outline Color", Color) = (0.17,0.15,0.15,1)
			_OutlineW("Outline Width", float) = 0.05

			////////////////////////////////
			//////////Outline Parms/////////
			////////////////////////////////


	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 1002

		Pass
	{
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
	//uniform sampler2D _MatCap;
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
	uniform float _OutlineW;
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

		//o.col = o.col.rgba;
		//o.col = o.col.rbga;
		//o.col = o.col.grba;
		//o.col = o.col.gbra;
		//o.col = o.col.brga;
		//o.col = o.col.bgra;

		o.col.r = -o.col.r;
		//o.col.g = -o.col.g;
		//o.col.b = -o.col.b;
		
		o.nor = v.normal;
		o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + (o.col) * _OutlineW, 1));
		return o;
	}
	float4 frag(VertexOutput i) : COLOR{
		return fixed4(_OutlineColor.rgb,0);

	}
		ENDCG
	}

		////////////////////////////////
		//////////Outline Pass//////////
		////////////////////////////////



	}

		Fallback "FF/_MatCap/Hero"
}