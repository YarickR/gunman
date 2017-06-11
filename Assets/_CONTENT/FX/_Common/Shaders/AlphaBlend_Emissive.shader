// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/AlphaBlend_Emissive" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 3
		_ColorEmissive ("Emissive Color", Color) = (1,1,1,1)
		_EmissiveTex ("Emissive Texure", 2D) = "white" {}
		_ColorEmissiveMul ("Emissive Color Multiplier", float) = 3
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Tags {
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha
			
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float4 _Color;
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
			uniform float _ColorMul;
            uniform float4 _ColorEmissive;
            uniform sampler2D _EmissiveTex; 
            uniform float4 _EmissiveTex_ST;
			uniform float _ColorEmissiveMul;

			
			struct appdata {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };

            struct v2f {
                half4 pos : POSITION;
                half4 uv_uv2 : TEXCOORD0;
                half4 color : COLOR;
				half3 colorEmissive : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                v.color *= _Color;
                o.uv_uv2.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_uv2.zw = TRANSFORM_TEX(v.texcoord, _EmissiveTex);
                float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
                
                o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
                o.color.a = v.color.a * alphaBlendFactor;
				o.colorEmissive = _ColorEmissive.rgb * _ColorEmissiveMul * _ColorEmissive.a;
                return o;
            }


            fixed4 frag(v2f i) : COLOR
            {
                fixed4 color;
                fixed4 tex = tex2D(_MainTex, i.uv_uv2.xy);
				fixed3 emissiveTex = tex2D(_EmissiveTex, i.uv_uv2.zw).rgb;
                color = tex * i.color;
				color.rgb += emissiveTex * i.colorEmissive * i.color.a;
                return color;

            }
            ENDCG
        }
    }
}
