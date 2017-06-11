// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Shader Forge/A_CubeMap_Refl" {
    Properties {
        _node_5305 ("node_5305", 2D) = "white" {}
        _exp ("exp", Float ) = 1
        _opacity ("opacity", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            uniform sampler2D _node_5305; uniform float4 _node_5305_ST;
            uniform float _exp;
            uniform float _opacity;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
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
                float2 node_8262 = (viewReflectDirection*0.5+0.5).rg;
                float4 _node_5305_var = tex2D(_node_5305,TRANSFORM_TEX(node_8262, _node_5305));
                float3 emissive = _node_5305_var.rgb;
                float3 finalColor = emissive;
                float3 node_7923 = float3(1.2,0.1,1.2);
                float node_9120 = max(_exp,0.0);
                float node_6654 = pow(1.0-max(0,dot(normalDirection, viewDirection)),node_9120);
                float node_8998 = saturate((pow(1.0-max(0,dot((i.normalDir*node_7923), viewDirection)),node_9120)*_opacity*node_6654));
                return fixed4(finalColor,node_8998);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    
}
