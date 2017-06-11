// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/Postprocess" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
		_DistortionTex ("DistortionTex", 2D) = "white" {}
		_DistortionMul ("DistortionMul", float) = 0.1
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
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One One
			
            CGPROGRAM
            
            #define UNITY_PASS_FORWARDBASE
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
			uniform sampler2D _DistortionTex;
			uniform float _DistortionMul;

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = i.uv;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed2 distortion = tex2D(_DistortionTex, i.uv).xy * 2.0f - 1.0f;
				distortion *= _DistortionMul;
				fixed4 baseColor = tex2D(_MainTex, i.uv + distortion);

				return baseColor;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
