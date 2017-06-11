// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

﻿Shader "FX/_Common/Opaque_NoiseUV" {
	Properties{
		_Color("Color for white", Color) = (1,1,1,1)
		_MainTex("Black&White Mask", 2D) = "white" {}
	_ColorMul("Color Multiplier", float) = 3.0
		_MidColor("Middle Color", Color) = (1,0,0,0)
		_LastColor("Color for black", Color) = (0,0,0,0)
		_MiddleColorPos("Middle color position ", Range(0, 1)) = 0.8
		_ScrollingSpeed("B&W Mask Scrolling", vector) = (0.5, 0.5, 0, 0)
		_NoiseUV("NoiseUV RG", 2D) = "bump" {}
	_NoiseSpeed_Force("Noise speed (U,V), Noise force (U, V)", vector) = (0.5, 0.5, 0.1, 0.1)
	}
		SubShader{
		Tags{
		"IgnoreProjector" = "True"
		"RenderType" = "Opaque"
	}
		Pass{
		Name "FORWARD"
		Tags{
		"LightMode" = "ForwardBase"
	}
		ZWrite On

		CGPROGRAM

#define UNITY_PASS_FORWARDBASE
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest

#pragma multi_compile_fwdbase
#pragma target 2.0

#include "UnityCG.cginc"


		uniform float4 _Color;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform float _ColorMul;
	uniform float4 _MidColor;
	uniform float4 _LastColor;
	uniform float _MiddleColorPos;
	uniform float2 _ScrollingSpeed;
	uniform sampler2D _NoiseUV;
	uniform float4 _NoiseUV_ST;
	uniform half4 _NoiseSpeed_Force;


	struct appdata {
		half4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		half4 color : COLOR;
	};

	struct v2f {
		half4 pos : POSITION;
		float4 uv_uv2 : TEXCOORD0;
		float4 color : COLOR;
	};

	v2f vert(appdata i)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.color = i.color * _ColorMul;
		o.color.a *= _Color.a;
		o.uv_uv2.xy = TRANSFORM_TEX(i.uv, _MainTex).xy + frac(_Time.z * _ScrollingSpeed);
		o.uv_uv2.zw = TRANSFORM_TEX(i.uv, _NoiseUV).xy + frac(_Time.z * _NoiseSpeed_Force.xy);

		return o;
	}


	fixed4 frag(v2f i) : COLOR
	{
		half2 noise = tex2D(_NoiseUV, i.uv_uv2.zw).rg * 2.0f - 1.0f;

		float mask = tex2D(_MainTex, i.uv_uv2.xy + noise * _NoiseSpeed_Force.zw).r;
		float3 upperGradientColor = lerp(_MidColor.rgb, _Color.rgb, (mask - _MiddleColorPos) / (1.0f - _MiddleColorPos));
		float3 lowerGradientColor = lerp(_LastColor.rgb, _MidColor.rgb, mask * (1.0f / _MiddleColorPos));
		float upperMul = saturate((mask - _MiddleColorPos) * 10000000.0f);
		float4 color = float4(lerp(lowerGradientColor, upperGradientColor, upperMul), mask);
		color *= i.color;

		return color;

	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}