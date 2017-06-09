// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/ReflectRefractGlass Outlined" {
    Properties {
        _Color ("Front Color", Color) = (1,1,1,1)
		_ColorMul ("Color Multiplier", float) = 1.0
        _FresnelPower ("Fresnel Power", Float ) = 1
		_FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
		_ReflectionColor ("Reflection Color", Color) = (1,1,1,1)
		_ReflectionTex ("ReflectionTex", Cube) = "_Skybox" {}
		_SpecularColorFront ("Front face specular Color", Color) = (1,1,1,1)
		_SpecularColorBack ("Back face specular Color", Color) = (1,1,1,1)
        _SpecularTex ("SpecularTex", Cube) = "_Skybox" {}
		_Stencil("Stencil", int) = 13

		////////////////////////////////
		//////////Outline Parms/////////
		////////////////////////////////

		_OutlineColor("Outline Color", Color) = (0.17,0.15,0.15,1)

			////////////////////////////////
			//////////Outline Parms/////////
			////////////////////////////////

    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

			LOD 1002
        Pass {
            Name "FORWARD"
            Tags 
			{
                "Queue"="Transparent"
            }
		Stencil{
		Ref [_Stencil]
		//Comp NotEqual
		Pass Replace

	}

            ZWrite Off
			Cull Off
            Blend One OneMinusSrcColor
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 2.0

			#include "UnityCG.cginc"

            uniform float3 _Color;
			uniform float _ColorMul;
			uniform samplerCUBE _ReflectionTex;
			uniform float3 _ReflectionColor;
            uniform float _FresnelPower;
			uniform float3 _FresnelColor;
            uniform samplerCUBE _SpecularTex;
			uniform float3 _SpecularColorFront;
			uniform float3 _SpecularColorBack;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

            struct v2f 
			{
                float4 pos : SV_POSITION;
                float3 specularColor : TEXCOORD0;
                float3 reflectionColor : TEXCOORD1;
				float3 reflectUV : TEXCOORD2;
                float3 fresnelColor : COLOR;
            };

            v2f vert (VertexInput i) 
			{
                v2f o = (v2f)0;
                o.fresnelColor = i.color;
                
                o.pos = UnityObjectToClipPos(i.vertex );

				float3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, i.normal));
				float fresnelFactor = abs(VSNormal.z);
				o.fresnelColor = lerp( _FresnelColor, _Color, pow(fresnelFactor, _FresnelPower)) * _ColorMul * i.color;
				float3 posW = mul(unity_ObjectToWorld, i.vertex).xyz;
				o.reflectUV = reflect( posW - _WorldSpaceCameraPos.xyz, i.normal );
				o.specularColor = 2.0f * (1.0f - fresnelFactor) * lerp(_SpecularColorBack, _SpecularColorFront, VSNormal.z * 0.5f + 0.5f) * i.color;
				o.reflectionColor = _ReflectionColor * (1.0f - pow(saturate(VSNormal.z), 5.0f)) * saturate(VSNormal.z * 5000.0f) * i.color;

                return o;
            }

            float4 frag(v2f i) : COLOR 
			{
				float3 specular = texCUBE(_SpecularTex, i.reflectUV).rgb * i.specularColor;
				float3 reflection = texCUBE(_ReflectionTex, i.reflectUV).rgb * i.reflectionColor;


                float3 finalColor = reflection + specular + i.fresnelColor;
                return fixed4(finalColor, 1.0f);
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
				//Pass Replace
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
				o.nor = v.normal;
				o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + (o.nor) * _GlobalOutlineWidth, 1));
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
			Stencil
			{
				Ref 128
				Comp NotEqual
				Pass Replace
			}
			
			CGPROGRAM

			#define UNITY_PASS_FORWARDBASE
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			
			uniform float4 _GlobalShadowColor;
			uniform float4 _GlobalShadowParams;
			uniform float _Depth;
			
			struct VertexInput 
			{
				float4 vertex : POSITION;
			};

			struct VertexOutput 
			{
				float4 pos : SV_POSITION;

			};

			VertexOutput vert(VertexInput v) 
			{
				VertexOutput o = (VertexOutput)0;
				
				float3 worldSpaceP = mul(unity_ObjectToWorld, v.vertex);

				worldSpaceP.xz += float2(_GlobalShadowParams.z, _GlobalShadowParams.w) * worldSpaceP.y;
				worldSpaceP.y = _Depth;

				o.pos = mul(UNITY_MATRIX_VP, float4(worldSpaceP, 1));
				return o;
			}

			float4 frag(VertexOutput i) : COLOR
			{
				return _GlobalShadowColor*1.2;
			}
			ENDCG
		}
    }
    FallBack "FX/_Common/ReflectRefractGlass"
}
