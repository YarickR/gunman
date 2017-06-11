// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Fountain/FountainShell" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_SecondTex ("SecondTex", 2D) = "white" {}
		_Color2 ("Multiplier", Color) = (1,1,1,1)
		_ScrollingSpeed ("UV1, UV2", vector) = (0.5, 0.5, 0, 0)
		_ColorMul ("Color Mul1, Mul2", vector) = (1,1,1,1)
		_NoiseTex ("Noise", 2D) = "white" {}
		_GradientOpacity ("Gradient Opacity", float) = 0
		_SecondTexVertexAlphaMasked ("Second Texure Vertex Alpha Masked", float) = 0
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
			uniform float4 _Color2;
            uniform sampler2D _MainTex; 
			uniform float4 _MainTex_ST;
			uniform sampler2D _SecondTex; 
            uniform float4 _SecondTex_ST;
			uniform sampler2D _NoiseTex; 
			uniform float4 _NoiseTex_ST;
			uniform half4 _ScrollingSpeed;
			uniform float2 _ColorMul;
			uniform float _GradientOpacity;
			uniform float _SecondTexVertexAlphaMasked;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float4 uv_uv2 : TEXCOORD0;
				float2 uv3 : TEXCOORD1;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color.rgb = _Color.rgb * v.color.rgb * _ColorMul.x * _Color.a * v.color.a;
				o.color.a = v.color.a;
				o.uv_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex).xy + frac(_Time.z * _ScrollingSpeed.xy);
				o.uv_uv2.zw = TRANSFORM_TEX(v.uv, _SecondTex).xy;
				o.uv3 = TRANSFORM_TEX(v.uv, _NoiseTex).xy + frac(_Time.z * _ScrollingSpeed.zw);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 color = tex2D(_MainTex, i.uv_uv2.xy);
				color = max(color, (_GradientOpacity * i.color.a).rrrr);
				half3 color2 = tex2D(_SecondTex, i.uv_uv2.zw).rgb;
				half3 color3 = tex2D(_NoiseTex, i.uv3).rgb;
				color.rgb *= i.color.rgb;
				color2 = color2 * _Color2.rgb * _Color2.a * _ColorMul.y * color3 * lerp(1, i.color.a, _SecondTexVertexAlphaMasked);
				color.rgb += color2 * color2;
				return color;
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
