// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_UI/Chest3" {
    Properties {
        [NoScaleOffset] _MainTex ("MainTex", 2D) = "white" {}
        [NoScaleOffset] _Matcap ("4x Matcaps", 2D) = "white" {}
		_MatcapMul ("Matcap mul", Vector) = (1,1,1,1)
		_MatcapOffset ("Matcap offset", Vector) = (0.5,0.5,0.5,0.5)
		[NoScaleOffset] _Mask ("Light probe mask (RG), Emissive (B)", 2D) = "white" {}
		_EmissiveMul ("Emissive mul", Range(0,10)) = 0
		_ShadowMul("Shadow mul", Range (0,1)) = 0.5

    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 2.0

			#include "Lighting.cginc"
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"

			#define MAX_FLOAT 1000000.0f


            uniform sampler2D _MainTex;
            uniform sampler2D _Matcap;
            uniform sampler2D _Mask;
			uniform float4 _MatcapMul;
			uniform float4 _MatcapOffset;
			uniform float _EmissiveMul;
			uniform float _ShadowMul;
			uniform float _LightProbeTextureEnable;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 viewNormal : TEXCOORD1;
				SHADOW_COORDS(2)
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv = v.uv;

				o.viewNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, v.normal)).rg * 0.5f + 0.5f;
                
				o.pos = UnityObjectToClipPos(v.vertex );
				TRANSFER_SHADOW(o)

                return o;
            }

            float4 frag(VertexOutput i) : COLOR {	
				float3 baseColor = tex2D(_MainTex, i.uv.xy).rgb;
				float3 mask = tex2D(_Mask, i.uv.xy).rgb;
				
				float2 matcapChooser = mask.rg;

				float2 matcapChooserInv = (1.0f).xx - matcapChooser; 
				float4 matcapChooser2a = float4(matcapChooser.x, matcapChooserInv.x, matcapChooser.x, matcapChooserInv.x);
				float4 matcapChooser2b = float4(matcapChooser.y, matcapChooser.y, matcapChooserInv.y, matcapChooserInv.y);
				float4 matcapChooser2 = matcapChooser2a * matcapChooser2b;

				float mapcaMul = dot(_MatcapMul, matcapChooser2);
				float mapcaOffset = dot(_MatcapOffset, matcapChooser2);

				fixed2 matcapUV = i.viewNormal;
				fixed3 matcap = tex2D(_Matcap, (matcapUV + matcapChooser) * 0.5f).rgb;

				matcap = (matcap - mapcaOffset) * mapcaMul;

				float3 finalColor = baseColor + matcap;

				float emissiveMask = mask.b;
				float3 emissive = finalColor * _EmissiveMul * emissiveMask;

				fixed shadow = SHADOW_ATTENUATION(i);

				finalColor = lerp(finalColor, finalColor*shadow, _ShadowMul ) + emissive;

				return fixed4(finalColor, 1.0f);
            }

            ENDCG
        }
    }

	FallBack "Diffuse"
}
