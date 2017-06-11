// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hero/Lobby_PostAttenuation"
{
	Properties
	{
		_ColorAdd("Color Additive", Color) = (0,0,0,0)
		_ColorMul("Color Multiplier", Color) = (1,1,1,1)
		_FresnelPower ("Fresnel Power", float) = 1.0
		_FresnelColorInner ("Fresnel Color Inner", Color) = (0, 0, 0, 0)
		_FresnelColorOuter ("Fresnel Color Outer", Color) = (0, 0, 0, 0)
		_FresnelColorMul ("Fresnel Color Mul", float) = 0
		_MatCapColorMul ("Matcap Color Multiplier", Float) = 1
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
				"Queue"="Transparent"
            }
            ZWrite Off
            Cull Off
            Blend One OneMinusSrcAlpha

			Offset -1, -1
			
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma target 2.0
            
            #include "UnityCG.cginc"

			struct v2f
			{
				float4 pos	: SV_POSITION;
				float2 cap	: TEXCOORD0;
				float3 color: COLOR;
			};

			uniform sampler2D _GlobalMatCapTexture;
			uniform float4 _ColorAdd;
			uniform float4 _ColorMul;
			uniform float _FresnelPower;
			uniform float3 _FresnelColorInner;
			uniform float3 _FresnelColorOuter;
			uniform float _FresnelColorMul;
			uniform float _MatCapColorMul;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
				worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
				o.cap.xy = worldNorm.xy * 0.5 + 0.5;
		
				float3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, v.normal));
				float fresnelFactor = abs( dot(VSNormal, half3(0.0f, 0.0f, 1.0f) ) );
				o.color = lerp( _FresnelColorInner, _FresnelColorOuter, pow(fresnelFactor, _FresnelPower));

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 mc = tex2D(_GlobalMatCapTexture, i.cap);

				fixed4 mul = lerp(fixed4(0,0,0,0), fixed4(_ColorMul.rgb, 1.0f), ((1.0f - dot(_ColorMul.rgb, (0.333f).rrr) ) * _ColorMul.a));
				fixed4 add = fixed4(_ColorAdd.rgb, 0);
				fixed4 matcap = (mc*2.0f - 1.0f) * _MatCapColorMul;
				fixed4 fresnel = fixed4(i.color * _FresnelColorMul, 0.0f);
				
				fixed4 color = mul + matcap + add + fresnel;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}