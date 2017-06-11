// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Environment/LightShafts" {
    Properties {
		_Color ("Color (RGB)", Color) = (0.5, 0.5, 0.5, 1)
		_ColorMultiplier ("Color Multiplier", Float) = 2
		_MainTex ("MainTex", 2D) = "white" {}
        _Distance ("Fade Distance",  Range (0, 50) ) = 10
        _Falloff ("Falloff", Float ) = 1
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
            ZWrite Off
			Cull Off
			            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE

            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase
            #pragma target 2.0

            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
            uniform float3 _Color;
			uniform float _ColorMultiplier;
            uniform float _Distance;
            uniform float _Falloff;
            
			struct VertexInput {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 color : COLOR;
            };

            v2f vert (VertexInput i) {
                v2f o = (v2f)0;
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);

                float toCameraDistanceFactor = max(0.0f, distance( mul( unity_ObjectToWorld, i.vertex).xyz, _WorldSpaceCameraPos) - _Distance) / (_Distance + 0.00001f);
				toCameraDistanceFactor = pow(saturate(toCameraDistanceFactor), _Falloff );
				
				o.color = i.color.rgb * _Color * _ColorMultiplier * toCameraDistanceFactor;

				o.pos = UnityObjectToClipPos(i.vertex);
				o.pos.z *= (toCameraDistanceFactor - 0.0001f) / 0.9999f;
                return o;
            }
            fixed4 frag(v2f i) : COLOR {
				fixed3 color = tex2D(_MainTex, i.uv).aaa * i.color;
                return fixed4(color, 1.0f);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
