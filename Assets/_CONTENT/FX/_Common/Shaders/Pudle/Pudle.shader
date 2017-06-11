// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33420,y:32846,varname:node_3138,prsc:2|emission-9549-OUT,alpha-1833-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32363,y:32357,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:8938,x:32351,y:32786,ptovrint:False,ptlb:Diffuse,ptin:_Diffuse,varname:node_8938,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:c435144f4aedb054c91579faea28758f,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ValueProperty,id:6124,x:32363,y:32530,ptovrint:False,ptlb:multiply,ptin:_multiply,varname:node_6124,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:9027,x:32686,y:32388,varname:node_9027,prsc:2|A-7241-RGB,B-6124-OUT;n:type:ShaderForge.SFN_VertexColor,id:5878,x:32423,y:33069,varname:node_5878,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:453,x:32423,y:33218,ptovrint:False,ptlb:transparency,ptin:_transparency,varname:node_453,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.7;n:type:ShaderForge.SFN_Lerp,id:9549,x:32846,y:32776,varname:node_9549,prsc:2|A-9027-OUT,B-8938-RGB,T-5878-R;n:type:ShaderForge.SFN_Multiply,id:1833,x:32862,y:33123,varname:node_1833,prsc:2|A-5878-R,B-453-OUT;proporder:7241-8938-6124-453;pass:END;sub:END;*/

Shader "Shader Forge/A_Qube_Alpha" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _Diffuse ("Diffuse", 2D) = "white" {}
        _multiply ("multiply", Float ) = 1
        _transparency ("transparency", Float ) = 0.7
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform float _multiply;
            uniform float _transparency;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(i.uv0, _Diffuse));
                float3 emissive = lerp((_Color.rgb*_multiply),_Diffuse_var.rgb,i.vertexColor.r);
                float3 finalColor = emissive;
                return fixed4(finalColor,(i.vertexColor.r*_transparency));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
