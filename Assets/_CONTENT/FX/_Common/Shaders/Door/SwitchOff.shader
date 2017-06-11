// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Door/SwitchOff" {
    Properties {
        _timeLine ("timeLine", Range(0, 20)) = 0
        _color ("color", Color) = (0.01436601,0.653,0.09793406,1)
        _noise_Size ("noise_Size", Float ) = 9
        _texture ("texture", 2D) = "white" {}
        _color_mult ("color_mult", Float ) = 3
        _idle_noise ("idle_noise", Range(0, 1)) = 1
        _noise_vis ("noise_vis", Float ) = 0.15
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
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM

			#define NARROW_LINES_SPEED_MULTIPLIER 10.0f
			#define NARROW_LINES_DENSITY 20.0f
			#define NARROW_LINES_THINNESS 3.0f
			#define MAX_FLOAT 10000000.0f

            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform float _timeLine;
            uniform float4 _color;
            uniform float _noise_Size;
            uniform sampler2D _texture; uniform float4 _texture_ST;
            uniform float _color_mult;
            uniform float _idle_noise;
            uniform float _noise_vis;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float2 noiseUV = floor(i.uv0 * _noise_Size) + _timeLine + _idle_noise;
				float noise = frac(sin(noiseUV.x * noiseUV.y) * 43758.5453123f);


                float Narrowlines = NARROW_LINES_THINNESS * abs( sin( NARROW_LINES_DENSITY * i.uv0.y + _idle_noise * NARROW_LINES_SPEED_MULTIPLIER ));
                Narrowlines = saturate(1.0f - Narrowlines) * noise;
                
				float2 uv2 = (i.uv0 * 2.0f - 1.0f);
				float2 uv2_abs = abs(uv2);

                float2 texture_uv = float2(uv2_abs.x, i.uv0.y);
                float texture_color = tex2D(_texture,TRANSFORM_TEX(texture_uv, _texture)).r;

                float timeLineClamped = saturate(_timeLine);

                float turningOnOfMask = 1.0f - saturate((uv2_abs.y - (1.0f - timeLineClamped)) * MAX_FLOAT);


                float node_4267 = (((clamp(Narrowlines,_noise_vis,1.0)*noise)+ texture_color)*((1.0 - (saturate(ceil(_timeLine))*noise))+(timeLineClamped*timeLineClamped))*turningOnOfMask);
                float2 node_5105 = (uv2 * float2(pow(clamp((_timeLine/4.0),1,8),2.5),_timeLine));
                float3 emissive = (_color.rgb*lerp(saturate(node_4267),(((1.0 - length(node_5105))*2.0+-1.0)+pow((1.0 - length(node_5105.g)),5.0)),saturate(floor(_timeLine)))*_color_mult*i.vertexColor.a);
                return fixed4(emissive,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
