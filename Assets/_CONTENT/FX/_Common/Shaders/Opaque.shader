// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Common/Opaque" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite On
            Cull Off
			
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
				o.color = _Color * v.color * _ColorMul;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color;
				fixed4 tex = tex2D(_MainTex, i.texcoord);
				color = tex * i.color;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
