// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33268,y:32530,varname:node_3138,prsc:2|emission-9906-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32575,y:32787,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:4723,x:32731,y:32611,ptovrint:False,ptlb:deffuse,ptin:_deffuse,varname:node_4723,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5552,x:32575,y:32947,ptovrint:False,ptlb:emisive,ptin:_emisive,varname:node_5552,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:8883,x:32837,y:32895,varname:node_8883,prsc:2|A-7241-RGB,B-5552-RGB,C-100-OUT;n:type:ShaderForge.SFN_Add,id:9906,x:32997,y:32712,varname:node_9906,prsc:2|A-4723-RGB,B-8883-OUT;n:type:ShaderForge.SFN_ValueProperty,id:100,x:32575,y:33149,ptovrint:False,ptlb:multiply,ptin:_multiply,varname:node_100,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:7241-4723-5552-100;pass:END;sub:END;*/

Shader "Shader Forge/A_Unlit_Emissive" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _deffuse ("deffuse", 2D) = "white" {}
        _emisive ("emisive", 2D) = "white" {}
        _multiply ("multiply", Float ) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _deffuse; uniform float4 _deffuse_ST;
            uniform sampler2D _emisive; uniform float4 _emisive_ST;
            uniform float _multiply;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 _deffuse_var = tex2D(_deffuse,TRANSFORM_TEX(i.uv0, _deffuse));
                float4 _emisive_var = tex2D(_emisive,TRANSFORM_TEX(i.uv0, _emisive));
                float3 emissive = (_deffuse_var.rgb+(_Color.rgb*_emisive_var.rgb*_multiply));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
