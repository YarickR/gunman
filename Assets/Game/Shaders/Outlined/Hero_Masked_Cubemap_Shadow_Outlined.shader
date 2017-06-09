// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Masked Cubemap Shadow Outlined" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Reflection ("Reflection", Cube) = "_Skybox" {}
		_ColorAdd("Color Additive", Color) = (0,0,0,0)
		_Stencil("Stencil", int) = 13
    }
    SubShader {
		Tags {
			"RenderType" = "Opaque"}

			LOD 1002

        
        Pass {
            Name "FORWARD"
            ZWrite On
			Tags{}
			Stencil{
			Ref [_Stencil]
			//Comp NotEqual
			Pass Replace}

            
            //ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 2.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform sampler2D _GlobalMatCapTexture; uniform float4 _GlobalMatCapTexture_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform samplerCUBE _Reflection;
			uniform float4 _ColorAdd;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed2 remap = (mul( UNITY_MATRIX_V, float4(i.normalDir,0) ).xyz.rgb.rg*0.5+0.5);
                fixed4 _Matcap_var = tex2D(_GlobalMatCapTexture,TRANSFORM_TEX(remap, _GlobalMatCapTexture));
				float _Mask_var = saturate(tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask)));
                float4 _Reflection_var = texCUBE(_Reflection,viewReflectDirection);
                float3 emissive = (_MainTex_var.rgb+(_Matcap_var.rgb*2.0)-1.0+(_Mask_var*_Reflection_var.rgb));
                float3 finalColor = emissive;
                return fixed4(finalColor,1) + _ColorAdd;
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
				Ref [_Stencil]
				Comp NotEqual
				
			}
				Cull Front
				Offset -1, -1

				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#pragma fragmentoption ARB_precision_hint_fastest
#pragma target 2.0

			uniform float _GlobalOutlineWidth;
			uniform float4 _GlobalOutlineColor;
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
				o.col.r = -o.col.r;
				o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + (o.col) * _GlobalOutlineWidth, 1));
				return o;
			}
			float4 frag(VertexOutput i) : COLOR{
				return fixed4(_GlobalOutlineColor.rgb,0);

			}
				ENDCG
			}



				////////////////////////////////
				//////////Outline Pass//////////
				////////////////////////////////


				
				
				
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
#define UNITY_PASS_FORWARDBASE
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
			fixed4 frag(VertexOutput i) : COLOR
			{
				return _GlobalShadowColor + _GlobalShadowColor.a;
			}
				ENDCG
			}



    }
    FallBack "FF/_MatCap/Masked Cubemap Shadow"
}
