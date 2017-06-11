// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/Gunsmith/FlameThrower" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ScrollSpeed_WaveFreq_Period_Ampl ("ScrollSpeed WaveFreq Period Ampl", vector) = (3.0, 4.0, 50, 0.005)
		_FadeoutFactor ("Fadeout factor", float) = 1
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
			uniform float4 _ScrollSpeed_WaveFreq_Period_Ampl;
			uniform float _FadeoutFactor;

            struct appdata {
                half4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };
           
            //VertIn
            struct v2f {
                half4 pos : POSITION;
                float2 texcoord : TEXCOORD0;
                half4 preMulAlphaColor_alphaBlendFactor : COLOR;
            };
 
            v2f vert (appdata v)
            {
                v2f o;
                
				float3 localPos = v.vertex.xyz;
				v.vertex.y += sin(_Time.z * _ScrollSpeed_WaveFreq_Period_Ampl.y + localPos.x * _ScrollSpeed_WaveFreq_Period_Ampl.z) * v.color.r * _ScrollSpeed_WaveFreq_Period_Ampl.w;
				v.vertex.x += 1.5*sin(_Time.z * _ScrollSpeed_WaveFreq_Period_Ampl.y + localPos.x * _ScrollSpeed_WaveFreq_Period_Ampl.z*1.293) * v.color.r * _ScrollSpeed_WaveFreq_Period_Ampl.w;
				v.vertex.z -= 2*sin(_Time.z * _ScrollSpeed_WaveFreq_Period_Ampl.y + localPos.x * _ScrollSpeed_WaveFreq_Period_Ampl.z * 1.26f) * v.color.r * _ScrollSpeed_WaveFreq_Period_Ampl.w;

				o.pos = UnityObjectToClipPos (v.vertex);

				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord.y -= frac(_Time.y * _ScrollSpeed_WaveFreq_Period_Ampl.x);
				
				float2 lerpFactor_fadeout = v.color.gb;
				v.color.a *= _Color.a;
				float3 colorGradient = lerp(float3(0.5f, 0.5f, 0.10f), float3(2.0f, 0.8f, 0.4f), lerpFactor_fadeout.x);
				v.color.rgb = _Color.rgb * colorGradient;
				v.color.rgb = lerp(v.color.rgb, float3(1.0f, 1.0f, 0.8f), saturate( (lerpFactor_fadeout.x-0.3f) * 1.5f) );
				
				v.color.a = v.color.a - saturate(lerpFactor_fadeout.y - _FadeoutFactor);

				o.preMulAlphaColor_alphaBlendFactor.a = ( 1.0f - saturate(( max( max(v.color.r, v.color.g), v.color.b) - 0.5f) * 2.0f)) * v.color.a;
				o.preMulAlphaColor_alphaBlendFactor.rgb = v.color.rgb * v.color.a * COLOR_MULTIPLIER;
 				
                return o;
            }
           
 
            fixed4 frag (v2f i) : COLOR
            {
                float4 col;
                fixed4 tex = tex2D(_MainTex, i.texcoord);
 
                col.rgb = tex.rgb * i.preMulAlphaColor_alphaBlendFactor.rgb * tex.a;
                col.a = tex.a * i.preMulAlphaColor_alphaBlendFactor.a;
                return col;
               
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
