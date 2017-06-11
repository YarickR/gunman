// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Teleporter/ScrollTwoTextures_Add" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_UV2_Scale_Offset ("UV2 Scale and Offset", vector) = (1.0, 1.0, 0, 0)
		_ScrollingSpeed ("UVSpeed 1,2", vector) = (0.5, 0, -0.5, 0)
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
			uniform half4 _ScrollingSpeed;
			uniform half4 _UV2_Scale_Offset;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float4 uv1_uv2 : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = _Color * v.color;
				o.color *= o.color.a * COLOR_MULTIPLIER;
				o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex).xy;
				o.uv1_uv2.zw = v.uv * _UV2_Scale_Offset.xy + _UV2_Scale_Offset.zw;
				o.uv1_uv2 += frac(_Time.z * _ScrollingSpeed);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half3 color = tex2D(_MainTex, i.uv1_uv2.xy);
				color += tex2D(_MainTex, i.uv1_uv2.zw);
				color *= i.color;
				return half4(color,1);
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
