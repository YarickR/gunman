// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "FX/_Wizard/WizardLobby_BodyErase"
{
	Properties
	{
		_MColor ("Multiplier", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Noise ("Erasing Texture", 2D) = "white" {}
		_Mask ("Erasing Mask Texture", 2D) = "white" {}
		_EraseProgress ("Erase progress", Range (0, 1)) = 0
		_EraseColor ("Erase Color", Color) = (1,0,0,1)
		_EraseColorMul ("Erase color mul", float) = 4
		_EraseBorderWidth ("Erase border width", Range (0, 1)) = 0.2

		//Shadow Properties
		_ShadowColor("Shadow Color", Color) = (0.5,0.5,0.5,1)
		_Parameters("Parameters", Vector) = (0,2,1,1)
		_Depth("Depth", Float) = 0
		_MeshHeight ("Mesh height for masking", Range (0.1, 4)) = 2
	}

		Subshader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
	{
		Tags{
                "LightMode"="ForwardBase"
				"Queue"="Transparent"
		}
			ZWrite On
            Cull Back
		
		//Offset -2, 1
		
		CGPROGRAM
		#define MAX_FLOAT 1000000.0f

#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _GlobalMatCapTexture;
	uniform sampler2D _Mask;
	uniform float4 _MainTex_ST;
	uniform float4 _Mask_ST;
	uniform sampler2D _Noise;
	uniform float4 _Noise_ST;
	uniform float _EraseProgress;
	uniform float4 _MColor;
	uniform float4 _EraseColor;
	uniform float _EraseBorderWidth;
	uniform float _EraseColorMul;
	uniform float _MeshHeight;


	struct v2f
	{
		float4 pos	: SV_POSITION;
		float4 uv_uv2 	: TEXCOORD0;
		float4 cap_maskUV	: TEXCOORD1;
	};

	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv_uv2.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv_uv2.zw = TRANSFORM_TEX(v.texcoord, _Noise);

		float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
		worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
		o.cap_maskUV.xy = worldNorm.xy * 0.5 + 0.5;

		float globalYPos = mul(unity_ObjectToWorld, v.vertex).y;
		float2 maskUV = float2(0.0f, saturate(globalYPos / _MeshHeight));
		o.cap_maskUV.zw = TRANSFORM_TEX(maskUV, _Mask);
		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, i.uv_uv2.xy) * _MColor;
		fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap_maskUV.xy);
		fixed verticalMask = 1.0f - tex2D(_Mask, i.cap_maskUV.zw).r;
		fixed eraseMask = tex2D(_Noise, i.uv_uv2.zw).r;
		float mask = verticalMask * eraseMask;
		fixed eraseFactor = saturate( (mask - _EraseProgress) * MAX_FLOAT);//замена потомучто step(_EraseProgress, mask) не пашет на Sony Xperia Z3;
		clip((eraseFactor - 0.5));
		
		fixed eraseProgressPow = pow(_EraseProgress, 0.5f);
		fixed4 eraseColor = _EraseColor * smoothstep(eraseProgressPow + _EraseBorderWidth, eraseProgressPow, mask);
		return tex + (mc*2.0) - 1.0 + eraseColor * _EraseColorMul;
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

			Fallback "VertexLit"
}