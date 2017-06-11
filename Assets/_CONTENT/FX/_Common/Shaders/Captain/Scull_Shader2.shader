// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33239,y:32716,varname:node_3138,prsc:2|emission-7478-OUT;n:type:ShaderForge.SFN_Color,id:4548,x:32348,y:32779,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:5517,x:32230,y:32970,ptovrint:False,ptlb:node_5180,ptin:_node_5180,varname:node_5180,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:cad425970d8cb9f4a9992b845dd1e11f,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Frac,id:2906,x:32700,y:33340,varname:node_2906,prsc:2|IN-7177-OUT;n:type:ShaderForge.SFN_Multiply,id:7177,x:32522,y:33303,varname:node_7177,prsc:2|A-1132-OUT,B-2495-OUT;n:type:ShaderForge.SFN_Lerp,id:7478,x:32709,y:32785,varname:node_7478,prsc:2|A-4548-RGB,B-7059-OUT,T-7762-OUT;n:type:ShaderForge.SFN_Vector3,id:7059,x:32364,y:32643,varname:node_7059,prsc:2,v1:1,v2:1,v3:1;n:type:ShaderForge.SFN_Add,id:1424,x:33138,y:33336,varname:node_1424,prsc:2|A-949-OUT,B-2954-OUT;n:type:ShaderForge.SFN_Clamp01,id:6805,x:33304,y:33297,varname:node_6805,prsc:2|IN-1424-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2495,x:32259,y:33556,ptovrint:False,ptlb:tile,ptin:_tile,varname:node_2055,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:12;n:type:ShaderForge.SFN_RemapRange,id:7502,x:32892,y:33371,varname:node_7502,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-2906-OUT;n:type:ShaderForge.SFN_Abs,id:949,x:33010,y:33191,varname:node_949,prsc:2|IN-7502-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2954,x:32714,y:33556,ptovrint:False,ptlb:weith,ptin:_weith,varname:node_8358,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_Multiply,id:7762,x:32585,y:32993,varname:node_7762,prsc:2|A-5517-RGB,B-6805-OUT;n:type:ShaderForge.SFN_Time,id:920,x:31967,y:33102,varname:node_920,prsc:2;n:type:ShaderForge.SFN_Add,id:6715,x:32307,y:33314,varname:node_6715,prsc:2|A-4303-OUT,B-5110-OUT;n:type:ShaderForge.SFN_Multiply,id:4303,x:32174,y:33149,varname:node_4303,prsc:2|A-920-TSL,B-8559-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8559,x:32007,y:33539,ptovrint:False,ptlb:speed,ptin:_speed,varname:node_4548,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:-4;n:type:ShaderForge.SFN_Fmod,id:1132,x:32482,y:33522,varname:node_1132,prsc:2|A-6715-OUT,B-4517-OUT;n:type:ShaderForge.SFN_Vector1,id:4517,x:32271,y:33671,varname:node_4517,prsc:2,v1:1;n:type:ShaderForge.SFN_ObjectPosition,id:9444,x:31482,y:33398,varname:node_9444,prsc:2;n:type:ShaderForge.SFN_FragmentPosition,id:993,x:31482,y:33267,varname:node_993,prsc:2;n:type:ShaderForge.SFN_Subtract,id:362,x:31668,y:33296,varname:node_362,prsc:2|A-993-XYZ,B-9444-XYZ;n:type:ShaderForge.SFN_ComponentMask,id:9001,x:31807,y:33539,varname:node_9001,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-6091-XYZ;n:type:ShaderForge.SFN_RemapRange,id:5110,x:31905,y:33335,varname:node_5110,prsc:2,frmn:-0.1,frmx:0.3,tomn:0,tomx:1|IN-9001-OUT;n:type:ShaderForge.SFN_Transform,id:6091,x:31624,y:33607,varname:node_6091,prsc:2,tffrom:0,tfto:3|IN-362-OUT;n:type:ShaderForge.SFN_Fmod,id:1090,x:32729,y:33221,varname:node_1090,prsc:2|A-7177-OUT,B-4517-OUT;proporder:4548-5517-2495-2954-8559;pass:END;sub:END;*/

Shader "Shader Forge/Scull_Shader2" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _node_5180 ("node_5180", 2D) = "white" {}
        _tile ("tile", Float ) = 12
        _weith ("weith", Float ) = 0.2
        _speed ("speed", Float ) = -4
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
            uniform float4 _TimeEditor;
            uniform float4 _Color;
            uniform sampler2D _node_5180; uniform float4 _node_5180_ST;
            uniform float _tile;
            uniform float _weith;
            uniform float _speed;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
////// Lighting:
////// Emissive:
                float4 _node_5180_var = tex2D(_node_5180,TRANSFORM_TEX(i.uv0, _node_5180));
                float4 node_920 = _Time + _TimeEditor;
                float node_4517 = 1.0;
                float node_7177 = (fmod(((node_920.r*_speed)+(mul( UNITY_MATRIX_V, float4((i.posWorld.rgb-objPos.rgb),0) ).xyz.rgb.g*2.5+0.25)),node_4517)*_tile);
                float3 emissive = lerp(_Color.rgb,float3(1,1,1),(_node_5180_var.rgb*saturate((abs((frac(node_7177)*2.0+-1.0))+_weith))));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
