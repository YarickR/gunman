// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Add_AlphaBlend_RToAlpha" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
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
            Blend One OneMinusSrcAlpha
			
            CGPROGRAM
            
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
			uniform float _ColorMul;

			struct appdata {
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f {
				half4 pos : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = v.color.a * alphaBlendFactor;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.texcoord).rgbr;
				color *= i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
