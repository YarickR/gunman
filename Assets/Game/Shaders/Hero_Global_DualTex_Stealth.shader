// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Hero DualTex Stealth"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_SecondTex("SecondTex", 2D) = "white" {}
		_Fade("Fade", Range(0,1)) = 1
		
	}

		Subshader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass{
			ColorMask 0
		}

		Pass{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			Stencil{
			Ref 127
			Comp NotEqual
			Pass Replace
		}
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
//#pragma fragmentoption ARB_precision_hint_fastest
		#define UNITY_PASS_FORWARDBASE
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
	uniform float _Fade;

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 _texA = tex2D(_MainTex, i.uv);
		fixed4 _texB = tex2D(_SecondTex, i.uv);
		float3 tex = lerp(_texA.rgb, _texB.rgb, i.vertexColor.a);
		float3 mc = tex2D(_GlobalMatCapTexture, i.cap);
		return fixed4(((tex + (mc*2.0) - 1.0)), _Fade);
	}
		ENDCG
	}


	}

		Fallback "VertexLit"
}