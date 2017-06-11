// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/Fresnel_Add" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_FresnelPower ("Fresnel Power", float) = 1.0
		_FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
		_ColorMul ("Color Multiplier", float) = 1.0
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
			uniform half _FresnelPower;
			uniform half4 _FresnelColor;
			uniform float _ColorMul;

			struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
				half3 normal : NORMAL;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex).xy;

				//o.color = i.color * _ColorMul;
				
				half3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, i.normal));
				half fresnelFactor = abs( dot(VSNormal, half3(0.0f, 0.0f, 1.0f) ) );
				o.color = lerp( _FresnelColor, _Color, pow(fresnelFactor, _FresnelPower)) * _ColorMul * i.color;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half4 color = tex2D(_MainTex, i.uv);
				color *= i.color;
				color.rgb *= color.aaa;
				return color;
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
