// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/_Cards/ChestCard" {
    Properties {
        _Color ("Multiplier", Color) = (1,1,1,1)
        _MainTex ("Back Tex", 2D) = "white" {}
		_ColorMul ("Color Multiplier", float) = 1
		_MiddleTex ("Chest Tex", 2D) = "white" {}
		_RaysTex ("Light Rays Tex", 2D) = "white" {}
		_RaysColor ("Light Rays color", Color) = (1,1,1,1)
		_RaysScroll ("Rays ScrollSpeed (XY) Raymask offset (ZW)", vector) = (0,0,0,0)
		_RaysRotation ("Light Rays Rotation", float) = 0
		_ComplexTex ("Complex Tex (R-sparks,G-NoiseUV) ", 2D) = "white" {}
		_SparksColorW ("Sparks White Point color", Color) = (1,1,1,1)
		_SparksColorB ("Sparks Black Point color", Color) = (0,0,0,0)
		_SparksColorMul ("Sparks color mul", float) = 1
		_SparksScroll ("Sparks Scroll Speed (UV)", vector) = (0,0,0,0)
		_SparksNoiseUVScale ("Sparks NoiseUV Scale", float) = 1
		_SparksNoiseUVSpeed ("Sparks Noise UV Speed (UV)", vector) = (0,0,0,0)
		_SparksNoiseUVForce ("Sparks NoiseUV Force", float) = 0.01
		_SparksNoiseUV_GChannelOffset ("Sparks Noise UV G Channel Offset (UV)", vector) = (0.2356, 0.53,0,0)
		_MidTexColor ("Mid Tex Blinking Color", Color) = (1,1,1,1)
		_MidTexBlinkSpeed ("Mid Tex Blink Speed", float) = 1
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
            Blend SrcAlpha OneMinusSrcAlpha
			
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
			uniform sampler2D _MiddleTex;
			uniform float4 _MiddleTex_ST;
			uniform sampler2D _ComplexTex;
			uniform float4 _ComplexTex_ST;
			uniform float4 _SparksColorW;
			uniform float4 _SparksColorB;
			uniform float _SparksColorMul;
			uniform float2 _SparksScroll;
			uniform float _SparksNoiseUVScale;
			uniform float2 _SparksNoiseUVSpeed;
			uniform float2 _SparksNoiseUV_GChannelOffset;
			uniform float _SparksNoiseUVForce;
			uniform float3 _MidTexColor;
			uniform float _MidTexBlinkSpeed;
			uniform sampler2D _RaysTex;
			uniform float4 _RaysTex_ST;
			uniform float3 _RaysColor;
			uniform float4 _RaysScroll;
			uniform float _RaysRotation;

			struct appdata {
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};

			struct v2f {
				half4 pos : POSITION;
				float4 uv1_uv2 : TEXCOORD0;
				float2 uv3 : TEXCOORD1;
				half4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.color = _Color;
				o.color.rgb *= _ColorMul;
				o.uv1_uv2.xy = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv1_uv2.zw = TRANSFORM_TEX(i.uv, _MiddleTex);
				o.uv3.xy = i.uv;
				return o;
			}


			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color;


				float2 sparksNoiseUVTex = float2(tex2D(_ComplexTex, i.uv1_uv2.xy * _SparksNoiseUVScale + frac(_Time.g * _SparksNoiseUVSpeed)).g,
												tex2D(_ComplexTex, (i.uv1_uv2.xy + _SparksNoiseUV_GChannelOffset) * _SparksNoiseUVScale + frac(_Time.g * _SparksNoiseUVSpeed)).g);

				sparksNoiseUVTex = sparksNoiseUVTex * 2.0f +(-0.5f); 
				fixed4 sparksTex = tex2D(_ComplexTex, i.uv1_uv2.xy + frac(_Time.g * _SparksScroll.xy) + sparksNoiseUVTex * _SparksNoiseUVForce).rrrr;
				sparksTex.rgb = lerp(_SparksColorB, _SparksColorW, sparksTex.r) * _SparksColorMul * sparksTex.a;
				sparksTex.rgb *= 1.0f - i.uv1_uv2.y; //masking sparks at top by multiplying to inversed tex coord V

				float3 middleTexUv = fixed3( i.uv1_uv2.zw, 1.0f) ;
				middleTexUv -= fixed3(0.5f, 0.5f, 0.0f); //move chest to local center for proper scale and rotation

								
				#define MIDGROUND_SHAKING_EVENT_PERIOD 1.4f
				#define MIDGROUND_SHAKING_EVENT_SPEED (1.0f/MIDGROUND_SHAKING_EVENT_PERIOD)
				
				// it means MIDGROUND_SHAKING_EVENT_ON_TIME_RATIO * MIDGROUND_SHAKING_EVENT_PERIOD a midground will shaking and the rest of time will stand
				#define MIDGROUND_SHAKING_EVENT_ON_TIME_RATIO 0.03f
				
				#define MIDGROUND_SHAKING_EVENT_OFF_TIME (1.0f - MIDGROUND_SHAKING_EVENT_ON_TIME_RATIO)

				float midTexShakingEventPeriod = saturate(abs(sin(_Time.y * MIDGROUND_SHAKING_EVENT_SPEED)) - MIDGROUND_SHAKING_EVENT_OFF_TIME);
				midTexShakingEventPeriod *= 1.0f / MIDGROUND_SHAKING_EVENT_ON_TIME_RATIO; // normalize the period of shaking/nonshaking event

				#define MIDGROUND_MIN_SCALE 1.0f // scale during non shaking phase
				#define MIDGROUND_MAX_SCALE 1.01f // max scale uses in the middle of shaking phase.
				
				#define MIDGROUND_ONE_DIV_MIN_SCALE (1.0f/MIDGROUND_MIN_SCALE)
				#define MIDGROUND_ONE_DIV_MAX_SCALE (1.0f/MIDGROUND_MAX_SCALE)
				
				float midTexScale = lerp(MIDGROUND_ONE_DIV_MIN_SCALE, MIDGROUND_ONE_DIV_MAX_SCALE, midTexShakingEventPeriod);

				#define MIDGROUND_SHAKING_AMPL 0.06f //amplitude of shaking
				#define MIDGROUND_SHAKING_SPEED 12.0f //shaking speed during shaking phase

				float middleTexAngle = sin(_Time.a * MIDGROUND_SHAKING_SPEED) * midTexShakingEventPeriod * MIDGROUND_SHAKING_AMPL;
				float cosMidTex = cos(middleTexAngle) * midTexScale;
				float sinMidTex = sin(middleTexAngle) * midTexScale;

				float3x3 middleTexUvTr = float3x3(cosMidTex, -sinMidTex, 0, 
												sinMidTex, cosMidTex, 0, 
												0.0, 0.0, 0);

				middleTexUv = mul(middleTexUv, middleTexUvTr);
				middleTexUv += fixed3(0.5f, 0.5f, 0.0f); // move chest to quad center after rotation

				fixed4 BackTex = tex2D(_MainTex, i.uv1_uv2.xy);
				fixed4 middleTex = tex2D(_MiddleTex, middleTexUv);

				middleTex.rgb += (sin(_Time.a * _MidTexBlinkSpeed) * 0.5f + 1.0f) * _MidTexColor * middleTex.b;

				float3 raysTexUv = float3(i.uv3.xy, 1.0f);
				raysTexUv -= fixed3(0.5f, 0.5f, 0.0f); //move rays to local center for proper scale and rotation

				float raysTexAngle = middleTexAngle + _RaysRotation;
				float cosRaysTex = cos(raysTexAngle);
				float sinRaysTex = sin(raysTexAngle);

				float3x3 raysTexUvTr = float3x3(cosRaysTex, -sinRaysTex, 0, 
												sinRaysTex, cosRaysTex, 0, 
												0.0, 0.0, 0);

				raysTexUv = mul(raysTexUv, raysTexUvTr);
				
				raysTexUv.y *= 1.0f + raysTexUv.x * 1.2f;// piramid scale. Rays going out of the chest are spreading.

				raysTexUv += fixed3(0.5f, 0.5f, 0.0f); //move rays to local center for proper scale and rotation

				raysTexUv.xy = TRANSFORM_TEX(raysTexUv.xy, _RaysTex);
				raysTexUv.xy += frac(_Time.g * _RaysScroll.xy);

				fixed3 lightRaysTex = tex2D(_RaysTex, raysTexUv.xy).rrr;
				fixed raysMask = tex2D(_ComplexTex, saturate(middleTexUv + _RaysScroll.zw)).b;
				lightRaysTex *= _RaysColor * raysMask;


				color = BackTex * i.color;
				color.rgb = lerp(color.rgb, middleTex.rgb, middleTex.a);
				color.rgb += sparksTex.rgb + lightRaysTex;
				return color;

			}
			ENDCG
        }
    }
    FallBack "Diffuse"
}
