// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "FX/_Environment/Spike_Fresnel_Opaque__GroundColorAddBlend" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
		_ColorMul ("Color mul", float) = 1
        _MainTex ("MainTex", 2D) = "white" {}
		_FresnelPower ("Fresnel Power", float) = 1
		_FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
		_FresnelColorMul ("Fresnel Color Mul", Float) = 1
		_GroundColor ("Ground Color", Color) = (1, 1, 1, 1)
		_GroundColorMul ("Ground Color Mul", Float) = 1
		_GroundColorHeight ("Ground Color Height", Float) = 0
		_GroundColorThickness ("Ground Color Thickness", Float) = 0.5

    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
        }
        Pass {
            Name "FORWARD"
            Tags {

            }
            ZWrite On
            Cull Back
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            
            uniform float4 _Color;
            uniform sampler2D _MainTex;
			uniform float _ColorMul;
            uniform float4 _MainTex_ST;
			uniform half _FresnelPower;
			uniform half4 _FresnelColor;
			uniform float _FresnelColorMul;
			uniform float3 _GroundColor;
			uniform float _GroundColorMul;
			uniform float _GroundColorHeight;
			uniform float _GroundColorThickness;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half4 color : COLOR;
				half3 normal : NORMAL;
			};

			struct v2f {
				half4 pos : POSITION;
				half3 uv_GlabalY : TEXCOORD0;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv_GlabalY.xy = TRANSFORM_TEX(i.uv, _MainTex).xy;
				
				half3 VSNormal = normalize(mul((half3x3)UNITY_MATRIX_IT_MV, i.normal));
				half fresnelFactor = abs(VSNormal.z);
				o.color = i.color * lerp( _FresnelColor * _FresnelColorMul, _Color * _ColorMul, pow(fresnelFactor, _FresnelPower));
				o.uv_GlabalY.z = mul(unity_ObjectToWorld, i.vertex).y;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				half3 color = tex2D(_MainTex, i.uv_GlabalY.xy);
				color *= i.color;		
				float groundColorCoef = saturate(1.0f - abs(i.uv_GlabalY.z - _GroundColorHeight) / _GroundColorThickness);
				float3 groundColor = _GroundColor * _GroundColorMul * groundColorCoef;

				color += groundColor;
				return half4(color, 1.0f);
			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
