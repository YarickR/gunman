// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_UI/CooldownRing_AlphaBlend" {
    Properties {
        _Color ("Base color ", Color) = (1,1,1,1)
		_Color2 ("Front Border color", Color) = (1,1,1,1)
        _MainTex ("Black&White Mask", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3.0
		_ColorMul2 ("Color2 Multiplier", float) = 3.0
		_Visibility ("Visibility (0 to 2pi)", Range (0, 6.283185307179586476925286766559)) = 0
		_StartAngle ("Start angle (0 to 2pi)", Range (0, 6.283185307179586476925286766559)) = 0
		_ColorBlendingPow ("Color Blending Power (0 to 10)", Range (0, 10)) = 1

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
            Blend SrcAlpha OneMinusSrcAlpha
			
            CGPROGRAM
			#define TEST
            
            #define UNITY_PASS_FORWARDBASE
			#define PI 3.1415926535897932384626433832795
			#define ONE_DIV2PI 0.15915494309189533576888376337251
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
			uniform float _ColorMul;
			uniform float _Visibility;
			uniform float _StartAngle;
			uniform float _ColorBlendingPow;
			uniform float _ColorMul2;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float4 color2 : TEXCOORD1;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = i.color * _Color * _ColorMul;
				o.color2 = i.color * _Color2 * _ColorMul2;
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				
				float fi = (atan2(i.uv.y - 0.5f, i.uv.x - 0.5f) + PI + _StartAngle) % (PI*2.0f);
				float4 color = i.color; 
				color.a *= (2.0f * PI - _Visibility > fi ? 0 : 1.0f) * (0 > fi ? 0 : 1.0f);
				
				float colorBlendFactor = saturate( (fi + _Visibility ) * ONE_DIV2PI - 1.0f);
				colorBlendFactor = pow(colorBlendFactor, _ColorBlendingPow);
				color.rgb = lerp(i.color2, i.color, colorBlendFactor).rgb;

				color.a *= tex2D(_MainTex, i.uv).r;

				return color;
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
