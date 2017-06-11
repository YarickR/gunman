// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit shader. Simplest possible textured shader.
// - SUPPORTS lightmap
// - no lighting
// - no per-material color

Shader "Mobile/Unlit Transparent" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Color ("Color (RGB)", Color) = (1, 1, 1, 1)
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha 
	
	// Lightmapped, encoded as RGBM
	Pass {
		Tags { "RenderType"="Opaque" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#include "UnityCG.cginc"
		#pragma multi_compile_fog
		#define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

			// uniforms
			float4 _MainTex_ST;

			// vertex shader input data
			struct appdata
			{
				float3 pos : POSITION;
				float3 uv1 : TEXCOORD1;
				float3 uv0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			// vertex-to-fragment interpolators
			struct v2f
			{
				fixed4 color : COLOR0;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			#if USING_FOG
				fixed fog : TEXCOORD2;
			#endif
				float4 pos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			// vertex shader
			v2f vert(appdata IN)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				half4 color = half4(0, 0, 0, 1.1);
				float3 eyePos = UnityObjectToViewPos(float4(IN.pos, 1));
				half3 viewDir = 0.0;
				o.color = saturate(color);
				// compute texture coordinates
				o.uv0 = IN.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.uv1 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// fog
			#if USING_FOG
					float fogCoord = length(eyePos.xyz);  // radial fog distance
					UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
					o.fog = saturate(unityFogFactor);
			#endif
				// transform position
				o.pos = UnityObjectToClipPos(IN.pos);
				return o;
			}

			// textures
			sampler2D _MainTex;
			fixed4 _Color;

			// fragment shader
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 col, tex;

				// Fetch lightmap
				half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uv0.xy);
				col.rgb = DecodeLightmap(bakedColorTex);

				// Fetch color texture
				tex = tex2D(_MainTex, IN.uv1.xy);
				col.rgb = tex.rgb * col.rgb;
				col.a = 1;
		
				// fog
			#if USING_FOG
				col.rgb = lerp(unity_FogColor.rgb, col.rgb, IN.fog);
			#endif

				col *= _Color;
				return col;
			}

		ENDCG
	}
}
}



