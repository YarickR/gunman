// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

///
///	Vertex nornalY is an apmlitude mask for the noise
/// _Ampl.xyz are an aplitude for the noise. 
/// _Ampl.w is a stepped tme factor. Greater value produses smaller time step.

Shader "FX/Gunsmith/LightningGeom" {
	Properties {
		_Color ("Multiplier", Color) = (1,1,1,1)
		_MainTex ("MainTex", 2D) = "white" {}
		_Ampl ("Amplitude", vector) = (0.5, 0.5, 0.5, 5.0)
	}
	SubShader {
		Tags {
			"IgnoreProjector"="True"
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}
		Pass {
			Name "FORWARD"
			Tags {
				"LightMode"="ForwardBase"
			}
			ZWrite Off
			Cull Off
			Blend One OneMinusSrcAlpha
			
			CGPROGRAM
			#define TEST
			#define COLOR_MULTIPLIER 3.0f
			
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
			uniform float4 _Ampl;

			struct appdata {
				half4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				half3 normals : NORMAL;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float3 texcoord_alphaBlendFactor : TEXCOORD0;
				half4 preMulAlphaColor_vertexAlpha : COLOR;
			};
			
			float rand(float2 seed) {
				float dot_product = dot(seed, float2(12.9898, 78.233));
				return frac(sin(dot_product) * 43758.5453);
			}

			v2f vert(appdata v)
			{
				v2f o;
				_Ampl *= v.normals.y;
				half SteppedTime = floor(( _Time.z + v.normals.y) * _Ampl.w);
				v.vertex.x += (rand( float2(SteppedTime, v.texcoord.x))) * _Ampl.x;
				v.vertex.y += (rand( float2(SteppedTime, v.texcoord.y))) * _Ampl.y;
				v.vertex.z += (rand( float2(SteppedTime, SteppedTime - v.texcoord.x))) * _Ampl.z;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.texcoord_alphaBlendFactor.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.preMulAlphaColor_vertexAlpha.rgb = v.color.rgb * v.color.a * COLOR_MULTIPLIER;
				o.texcoord_alphaBlendFactor.z = saturate(max(max(_Color.r, _Color.g), _Color.b) * COLOR_MULTIPLIER - 1.0f); // 0 = alphablend, 1 = additive blend
				o.preMulAlphaColor_vertexAlpha.a = v.color.a * (1.0f - o.texcoord_alphaBlendFactor.z);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				float4 col;
				fixed4 tex = tex2D(_MainTex, i.texcoord_alphaBlendFactor.xy);

				col.a = tex.a * i.preMulAlphaColor_vertexAlpha.a;
				col.rgb = tex.rgb * saturate(tex.a + i.texcoord_alphaBlendFactor.z) * i.preMulAlphaColor_vertexAlpha.rgb;
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
