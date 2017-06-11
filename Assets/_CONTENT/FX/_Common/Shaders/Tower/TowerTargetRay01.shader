// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Tower/TowerTargetRay" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ScrollingSpeed ("UV1, UV2", vector) = (0.5, 0, 1, 0)
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
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha
            
            CGPROGRAM
			#define TEST
            #define COLOR_MULTIPLIER 10.0f
            
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
				o.color = _Color * v.color * COLOR_MULTIPLIER;
				o.uv1_uv2 = TRANSFORM_TEX(v.uv, _MainTex).xyxy;
				o.uv1_uv2 += frac(_Time.z * _ScrollingSpeed);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 color = tex2D(_MainTex, i.uv1_uv2.xy).aaaa;
				color *= tex2D(_MainTex, i.uv1_uv2.zw).aaaa * i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
