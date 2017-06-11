// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/Lightning_AlphaBlend" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ScrollingSpeed ("ScrollingSpeed UV, Step Time UV", vector) = (0.5, 0.5, 0.2, 0.2)
		_VertexOffsetAmpl ("Vertex offset Ampl XYZ, Noise Scale", vector) = (0.3, 0.3, 0.3, 1.2573)
		_ColorMul ("Color mul", float) = 3
		_BorderMaskWidth ("Transparent UV border's width (U and V separately)", vector) = (0.0, 0.0, 0.0, 0.0)
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
			uniform float _ColorMul;
			uniform float4 _VertexOffsetAmpl;
			uniform float2 _BorderMaskWidth;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float4 uv_uv2 : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.color.w = (1.0f - v.color.a + 0.14f) * 10.0f;
				o.color.rgb = _Color.rgb * v.color.rgb * _Color.a * v.color.a * _ColorMul;
				float2 uvOffset = float(_Time.z).xx * _ScrollingSpeed.xy;
				uvOffset = floor(uvOffset/(_ScrollingSpeed.zw + float2(0.00001f, 0.00001f) ) ) * _ScrollingSpeed.zw;
				o.uv_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex).xy + uvOffset;
				
				v.vertex.xyz += sin(sin(uvOffset.xyx + v.vertex.yzx) * _VertexOffsetAmpl.w) * _VertexOffsetAmpl.xyz;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv_uv2.zw = v.uv * (2.0f).xx - (1.0f).xx;

				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				float2 borderMask = saturate( abs(i.uv_uv2.zw));
				borderMask = borderMask * _BorderMaskWidth;
				float borderAlpha = dot(borderMask, borderMask);
				borderAlpha *= borderAlpha;
				borderAlpha = 1.0f - borderAlpha;
				

				half3 color = tex2D(_MainTex, i.uv_uv2.xy).rgb;
				float alpha = dot(color, (0.3333f).xxx);
				color = pow(alpha, i.color.w).xxx;
				
				color *= i.color.rgb * borderAlpha;

				return float4(color, 1.0f);
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
