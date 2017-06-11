// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33443,y:32771,varname:node_3138,prsc:2|emission-7930-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32471,y:32812,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Depth,id:7177,x:32537,y:32508,varname:node_7177,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:6660,x:32417,y:33079,ptovrint:False,ptlb:cam_distance,ptin:_cam_distance,varname:node_6660,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:3265,x:32417,y:33180,ptovrint:False,ptlb:spread,ptin:_spread,varname:node_3265,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:6457,x:32927,y:33045,varname:node_6457,prsc:2|IN-7177-OUT,IMIN-1400-OUT,IMAX-2965-OUT,OMIN-767-OUT,OMAX-2822-OUT;n:type:ShaderForge.SFN_Vector1,id:2822,x:32546,y:33343,varname:node_2822,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:767,x:32546,y:33295,varname:node_767,prsc:2,v1:0;n:type:ShaderForge.SFN_Add,id:2965,x:32700,y:33150,varname:node_2965,prsc:2|A-6660-OUT,B-3265-OUT;n:type:ShaderForge.SFN_Subtract,id:1400,x:32700,y:33006,varname:node_1400,prsc:2|A-6660-OUT,B-3265-OUT;n:type:ShaderForge.SFN_Tex2d,id:7652,x:32762,y:32649,ptovrint:False,ptlb:texture,ptin:_texture,varname:node_7652,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Lerp,id:7930,x:33162,y:32737,varname:node_7930,prsc:2|A-7652-RGB,B-7241-RGB,T-451-OUT;n:type:ShaderForge.SFN_Clamp01,id:451,x:33092,y:33045,varname:node_451,prsc:2|IN-6457-OUT;proporder:7241-6660-3265-7652;pass:END;sub:END;*/

Shader "Shader Forge/A_Fish_DepthColor" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _cam_distance ("cam_distance", Float ) = 0
        _spread ("spread", Float ) = 0
        _texture ("texture", 2D) = "white" {}
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
            uniform float _cam_distance;
            uniform float _spread;
            uniform sampler2D _texture; uniform float4 _texture_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float4 projPos : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
////// Lighting:
////// Emissive:
                float4 _texture_var = tex2D(_texture,TRANSFORM_TEX(i.uv0, _texture));
                float node_1400 = (_cam_distance-_spread);
                float node_767 = 0.0;
                float3 emissive = lerp(_texture_var.rgb,_Color.rgb,saturate((node_767 + ( (partZ - node_1400) * (1.0 - node_767) ) / ((_cam_distance+_spread) - node_1400))));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
