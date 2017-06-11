// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Fresnel_Gradient_to_Noise_UV" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_FresnelPower("Fresnel Power", float) = 1.0
		_FresnelColor("Fresnel Color", Color) = (1, 1, 1, 1)
		_NoiseTex("NoiseUV (RG)", 2D) = "bump" {}
		_NoiseForce_Speed ("Noise Force(float2) Speed (float2)", vector) = (0.5, 0.5, 1, 1)
		_MidColor ("Middle Color", Color) = (1,0,0,0)
		_LastColor ("Color for black", Color) = (0,0,0,0)
		_MiddleColorPos ("Middle color position ", Range (0, 1)) = 0.8

    }
    SubShader {
			Tags{
			"IgnoreProjector" = "True"
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
			Pass{
			Name "FORWARD"
			Tags{
			"LightMode" = "ForwardBase"
			"Queue" = "Transparent"
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
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTex_ST;
			uniform float4 _NoiseForce_Speed;
			uniform half _FresnelPower;
			uniform half4 _FresnelColor;
			uniform float4 _MidColor;
			uniform float4 _LastColor;
			uniform float _MiddleColorPos;

		struct appdata {
				half4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
				half3 normal : NORMAL;
			};

			//VertIn
			struct v2f {
				half4 pos : POSITION;
				float4 uv1_uv2 : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv1_uv2.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv1_uv2.zw = TRANSFORM_TEX(i.uv, _NoiseTex) + frac(_Time.z * _NoiseForce_Speed.zw);

				half3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, i.normal));
				half fresnelFactor = abs(dot(VSNormal, half3(0.0f, 0.0f, 1.0f)));
				o.color *= lerp(_FresnelColor, _Color, pow(fresnelFactor, _FresnelPower)) * _ColorMul * i.color);

				float alphaBlendFactor = 1.0f - saturate(max(max(i.color.r, i.color.g), i.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend

				o.color.rgb = i.color.rgb * i.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = i.color.a * alphaBlendFactor;

				o.uv1_uv2.zw = TRANSFORM_TEX(i.uv, _NoiseTex) + frac(_Time.z * _NoiseForce_Speed.zw);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half2 noise = tex2D(_NoiseTex, i.uv1_uv2.zw).rg * 2.0f - 1.0f;

				float mask = tex2D(_MainTex, i.uv1_uv2.xy + noise * _NoiseForce_Speed.xy).r;
				float3 upperGradientColor = lerp(_MidColor.rgb, _Color.rgb, (mask - _MiddleColorPos) / (1.0f - _MiddleColorPos) );
				float3 lowerGradientColor = lerp(_LastColor.rgb, _MidColor.rgb, mask * (1.0f / _MiddleColorPos));
				float upperMul = saturate((mask - _MiddleColorPos) * 10000000.0f);
				float4 color = float4(lerp(lowerGradientColor, upperGradientColor, upperMul), mask);
				color *= i.color;

				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
