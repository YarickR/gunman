// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Hero DualTex"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_SecondTex("SecondTex", 2D) = "white" {}
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

		struct appdata {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
			float3 normal : NORMAL;
			fixed4 vertexColor : COLOR;
		};

	struct v2f
	{
		float4 pos	: SV_POSITION;
		float2 uv 	: TEXCOORD0;
		float2 cap	: TEXCOORD1;
		float4 vertexColor : COLOR;
	};

	uniform float4 _MainTex_ST;

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap.xy = worldNorm.xy * 0.5 + 0.5;

		o.vertexColor = v.vertexColor;

		return o;
	}

	uniform sampler2D _MainTex;
	uniform sampler2D _SecondTex;
	uniform sampler2D _GlobalMatCapTexture;
	uniform float4 _ColorAdd;

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 _texA = tex2D(_MainTex, i.uv);
		fixed4 _texB = tex2D(_SecondTex, i.uv);
		float3 tex = lerp(_texA.rgb, _texB.rgb, i.vertexColor.r);
		float3 mc = tex2D(_GlobalMatCapTexture, i.cap);
		return fixed4(((tex + (mc*2.0) - 1.0) + _ColorAdd),1);
	}
		ENDCG
	}


	}

		Fallback "VertexLit"
}