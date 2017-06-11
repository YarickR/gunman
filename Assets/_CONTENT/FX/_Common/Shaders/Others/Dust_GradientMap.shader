// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Others/Dust_GradientMap" {
    Properties {
        _texture ("texture", 2D) = "white" {}
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

            uniform sampler2D _texture; 
			uniform float4 _texture_ST;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos(v.vertex );
				o.uv = TRANSFORM_TEX(v.uv, _texture);

                o.vertexColor.rgb = v.vertexColor.rgb;
				o.vertexColor.a = 1.0f - v.vertexColor.a;
				o.vertexColor.a = saturate(o.vertexColor.a - 0.05f);

                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float texAlpha = tex2D(_texture, i.uv).a;
				float alpha = (texAlpha - i.vertexColor.a) / 0.05f;
                return fixed4(i.vertexColor.rgb, alpha);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
