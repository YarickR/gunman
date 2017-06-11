// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Tower/TowerProjectileTail01" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_NoiseUV ("NoiseUV", 2D) = "bump" {}
		_NoiseSpeed1_Speed2 ("_NoiseSpeed1_Speed2", vector) = (0.5, 0.5, -1, 1)
		_NoiseForce("NoiseForce1_NoiseForce2", vector) = (0.5, 0.5, 0.5, 0.5)
		_NoiseUVScale("NoiseUVScale1_Scale2", vector) = (0.5, 0.5, 0.5, 0.5)
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
            Blend One One
            
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
			uniform sampler2D _NoiseUV; 
			uniform half4 _NoiseSpeed1_Speed2;
			uniform half4 _NoiseForce;
			uniform half4 _NoiseUVScale;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
				float4 uv1_uv2 : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = _Color * v.color * COLOR_MULTIPLIER * v.color.a;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex).xy;
				o.uv1_uv2 = frac((o.uv.xyxy + _Time.z * _NoiseSpeed1_Speed2) * _NoiseUVScale);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{	
				half4 noise = half4( tex2D(_NoiseUV, i.uv1_uv2).rg, tex2D(_NoiseUV, i.uv1_uv2).ba ) * 2.0f - 1.0f;
				half4 color = tex2D(_MainTex, i.uv + noise * _NoiseForce * i.uv.x);
				return color * i.color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
