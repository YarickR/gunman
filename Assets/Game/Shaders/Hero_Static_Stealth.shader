// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FF/_MatCap/Hero Stealth Static" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _MatCap("MatCap (RGB)", 2D) = "white" {}
		_Fade("Fade", Range(0,1)) = 1
    }
    SubShader {
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass{
		ColorMask 0
	}
        Pass {
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
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _MatCap; uniform float4 _MatCap_ST;
			uniform float _Fade;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;

////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed2 remap = (mul( UNITY_MATRIX_V, float4(i.normalDir,0) ).xyz.rgb.rg*0.5+0.5);
                fixed4 _MatCap_var = tex2D(_MatCap,TRANSFORM_TEX(remap, _MatCap));
                float3 emissive = (_MainTex_var.rgb+(_MatCap_var.rgb*2.0)+(-1.0));
                float3 finalColor = emissive;
                return fixed4(finalColor, _Fade);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
