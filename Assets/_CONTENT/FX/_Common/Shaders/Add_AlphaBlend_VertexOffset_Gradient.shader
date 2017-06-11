// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/* Alpha and Additive blending in one shader.
*  If all color components are under 128, it will be like alpha blending. 
*  if the brightest color component goes from 128 to 255, it will decrease alphablend contribution and will look more like additive blending. 
*  if the brightest color component is 255, it will use 100% additive blending.
*  You must use premultiplied RGB channel.
*  Created by Alex Fedotovskikh
*/

Shader "FX/_Common/Add_AlphaBlend_VertexOffset_Gradient" {
    Properties {
        _Color ("Color for White", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_MidColor ("Middle Color", Color) = (1,0,0,0)
		_LastColor ("Color for black", Color) = (0,0,0,0)
		_MiddleColorPos ("Middle color position ", Range (0, 1)) = 0.8
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
			uniform float _VertexOffset;
			uniform float3 _VertexOffsetMul;
			uniform float4 _MidColor;
			uniform float4 _LastColor;
			uniform float _MiddleColorPos;
			uniform float _AlphaBlendFactor;


			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 normals : NORMAL;

			};

			struct v2f {
				half4 pos : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex += float4(v.normals * _VertexOffsetMul, 0.0f) * _VertexOffset;
				o.pos = UnityObjectToClipPos(v.vertex);
				v.color *= _Color;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float alphaBlendFactor = 1.0f - saturate(max(max(v.color.r, v.color.g), v.color.b) * 2.0f - 1.0f); // 1 = alphablend, 0 = additive blend
				
				o.color.rgb = v.color.rgb * v.color.a * lerp(_ColorMul, 2.0f, alphaBlendFactor);
				o.color.a = v.color.a * alphaBlendFactor;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				float2 mask = tex2D(_MainTex, i.uv).ra;
				float3 upperGradientColor = lerp(_MidColor.rgb, _Color.rgb, (mask.r - _MiddleColorPos) / (1.0f - _MiddleColorPos) );
				float3 lowerGradientColor = lerp(_LastColor.rgb, _MidColor.rgb, mask.r * (1.0f / _MiddleColorPos));
				float upperMul = saturate((mask.r - _MiddleColorPos) * 10000000.0f);
				float4 color = float4(lerp(lowerGradientColor, upperGradientColor, upperMul), 1.0f);
				
				color *= mask.y;
				color *= i.color;

				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
