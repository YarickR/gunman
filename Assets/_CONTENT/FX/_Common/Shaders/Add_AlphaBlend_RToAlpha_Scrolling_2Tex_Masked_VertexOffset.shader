// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Add_AlphaBlend_RToAlpha_Scrolling_2Tex_Masked_VertexOffset" {
    Properties {
        _Color ("Color1", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_Color2 ("Color2", Color) = (1,1,1,1)
		_SecondTex ("Second Tex", 2D) = "white" {}
		_ColorMul2 ("Color2 Multiplier", float) = 1
		_ScrollingSpeed ("Scrolling Speed (UV1, UV2)", vector) = (0.5, 0.5, 0.1, 0.1)
		_VertexOffset ("Vertex offset following to normals", float) = 0
		_VertexOffsetMul ("Vertex offset flw to normals multiplier", vector) = (1,0,1,0)

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
			uniform float4 _Color2;
            uniform sampler2D _SecondTex; 
            uniform float4 _SecondTex_ST;
			uniform float _ColorMul2;
			uniform float4 _ScrollingSpeed;
			uniform float _VertexOffset;
			uniform float3 _VertexOffsetMul;

			struct appdata {
				half4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				half4 color : COLOR;
				float3 normals : NORMAL;
			};

			struct v2f {
				half4 pos : POSITION;
				half4 texcoord : TEXCOORD0;
				half4 color : COLOR;
				half4 color2 : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex += float4(v.normals * _VertexOffsetMul, 0.0f) * _VertexOffset;
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 color = v.color * _Color;
				float4 color2 = v.color * _Color2;

				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(_Time.z * _ScrollingSpeed.xy);
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord, _SecondTex) + frac(_Time.z * _ScrollingSpeed.zw);
				float alphaBlendFactor = 1.0f - saturate(max(max(color.r, color.g), color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				float alphaBlendFactor2 = 1.0f - saturate(max(max(color2.r, color2.g), color2.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = color.rgb * color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = color.a * alphaBlendFactor;
				o.color2.rgb = color2.rgb * color2.a * lerp(_ColorMul2, 2.0f, alphaBlendFactor2);
				o.color2.a = color2.a * alphaBlendFactor2;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color;
				fixed4 tex = tex2D(_MainTex, i.texcoord.xy).rgbr;
				fixed4 tex2 = tex2D(_SecondTex, i.texcoord.zw).rgbr;
				color = tex * i.color + tex2 * i.color2 * tex.a;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
