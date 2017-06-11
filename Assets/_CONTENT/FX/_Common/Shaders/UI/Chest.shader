// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_UI/Chest" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_ColorMul ("Color mul", Float) = 1
        _Matcap ("Matcap", 2D) = "white" {}
        _Mask ("Reflection Mask", 2D) = "white" {}
        _Reflection ("Reflection", Cube) = "_Skybox" {}
        _Exp ("Exp", Float ) = 1
		_ScaleZ ("Scale Z", Float) = 1
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
            
            //ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 2.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _Matcap; uniform float4 _Matcap_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform samplerCUBE _Reflection;
            uniform float _Exp;
			uniform float _ScaleZ;
			uniform float3 _Color;
			uniform float _ColorMul;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv = v.uv;
                o.normalDir = UnityObjectToWorldNormal(v.normal);

				o.normalDir.z *= _ScaleZ; // компенсируем скейл геометрии по оси Z. Скейлить геометрию приходиться для того чтобы геометрия не пересекала ближнюю область отсечения камеры
				o.normalDir = normalize(o.normalDir);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                
				i.normalDir = normalize(i.normalDir);
				
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 viewReflectDirection = reflect( -viewDirection, i.normalDir );

                fixed2 remap = mul( UNITY_MATRIX_V, float4(i.normalDir, 0)).rg * 0.5f + 0.5f;
				
				float3 baseColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex)).rgb;
				fixed3 matcap = tex2D(_Matcap, TRANSFORM_TEX(remap, _Matcap)).rgb;
                float3 reflectionMask = tex2D(_Mask, TRANSFORM_TEX(i.uv, _Mask)).rgb;
				float3 reflection = texCUBE(_Reflection, viewReflectDirection).rgb;

				matcap = matcap * 2.0f - 1.0f;
				reflection *= reflectionMask * pow( 1.0f - max(0.0f, dot(i.normalDir, viewDirection)), _Exp);

                float3 finalColor = ( baseColor + matcap + reflection) * _Color * _ColorMul;
				return fixed4(finalColor, 1.0f);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
