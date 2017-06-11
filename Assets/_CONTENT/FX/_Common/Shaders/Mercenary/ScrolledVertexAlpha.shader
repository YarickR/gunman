// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Mercenary/ScrolledVertexAlpha" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_VertexAlpha ("SinPeriod, SinOffset, SinAmpl(Along Z+)", vector) = (1, 0, 1, 0)
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
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One One
            
            CGPROGRAM
			#define TEST
            #define COLOR_MULTIPLIER 3.0f
            
            #define UNITY_PASS_FORWARDBASE
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float4 _Color;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
			uniform half3 _VertexAlpha;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				half2 uv : TEXCOORD0;
				half3 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = _Color.rgb * v.color.rgb * COLOR_MULTIPLIER * _Color.a * v.color.a;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex).xy;
				const float PI = 3.14159;
				o.color *= clamp(sin(v.vertex.z * _VertexAlpha.x + clamp(_VertexAlpha.y, -PI, PI)) * _VertexAlpha.z, 0.0f, 1.0f);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 color = tex2D(_MainTex, i.uv);
				color.rgb *= i.color;
				return color;
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
