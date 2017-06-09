// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Hero"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_ColorAdd("Color Additive", Color) = (0,0,0,0)
		


	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }

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


		



	}

		Fallback "VertexLit"
}