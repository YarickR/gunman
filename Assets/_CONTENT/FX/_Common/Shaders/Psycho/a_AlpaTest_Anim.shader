// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:True,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:34116,y:32642,varname:node_3138,prsc:2|emission-5922-OUT,alpha-3900-OUT;n:type:ShaderForge.SFN_Tex2d,id:5128,x:33227,y:33076,ptovrint:False,ptlb:texture,ptin:_texture,varname:_texture,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-21-OUT;n:type:ShaderForge.SFN_Floor,id:2069,x:31462,y:32989,varname:node_2069,prsc:2|IN-6690-OUT;n:type:ShaderForge.SFN_TexCoord,id:5269,x:31435,y:33269,varname:node_5269,prsc:2,uv:0;n:type:ShaderForge.SFN_Divide,id:7868,x:32376,y:33188,varname:node_7868,prsc:2|A-5269-U,B-7349-OUT;n:type:ShaderForge.SFN_Divide,id:5664,x:32317,y:33356,varname:node_5664,prsc:2|A-5269-V,B-7317-OUT;n:type:ShaderForge.SFN_Append,id:21,x:32991,y:33157,varname:node_21,prsc:2|A-1821-OUT,B-6382-OUT;n:type:ShaderForge.SFN_Add,id:1821,x:32736,y:33131,varname:node_1821,prsc:2|A-5558-OUT,B-7868-OUT;n:type:ShaderForge.SFN_Divide,id:5558,x:32284,y:32937,varname:node_5558,prsc:2|A-2069-OUT,B-7349-OUT;n:type:ShaderForge.SFN_Divide,id:1969,x:31661,y:33109,varname:node_1969,prsc:2|A-2069-OUT,B-7349-OUT;n:type:ShaderForge.SFN_Floor,id:8056,x:31867,y:33491,varname:node_8056,prsc:2|IN-1969-OUT;n:type:ShaderForge.SFN_Add,id:5479,x:32578,y:33357,varname:node_5479,prsc:2|A-2407-OUT,B-5664-OUT,C-4520-OUT;n:type:ShaderForge.SFN_Divide,id:4011,x:32139,y:33496,varname:node_4011,prsc:2|A-8056-OUT,B-7317-OUT;n:type:ShaderForge.SFN_Vector1,id:2773,x:31893,y:32396,varname:node_2773,prsc:2,v1:1;n:type:ShaderForge.SFN_Divide,id:4045,x:31996,y:32513,varname:node_4045,prsc:2|A-2773-OUT,B-7317-OUT;n:type:ShaderForge.SFN_Frac,id:6382,x:32803,y:33357,varname:node_6382,prsc:2|IN-5479-OUT;n:type:ShaderForge.SFN_Negate,id:2407,x:32339,y:33496,varname:node_2407,prsc:2|IN-4011-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7349,x:31392,y:32435,ptovrint:False,ptlb:x,ptin:_x,varname:_x,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:4;n:type:ShaderForge.SFN_ValueProperty,id:7317,x:31392,y:32507,ptovrint:False,ptlb:y,ptin:_y,varname:_y,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_FaceSign,id:3253,x:32838,y:32781,varname:node_3253,prsc:2,fstp:0;n:type:ShaderForge.SFN_Color,id:8504,x:32881,y:32528,ptovrint:False,ptlb:back Color,ptin:_backColor,varname:_backColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:5922,x:33485,y:32858,varname:node_5922,prsc:2|A-8891-OUT,B-5128-RGB,C-3141-RGB;n:type:ShaderForge.SFN_Lerp,id:8891,x:33211,y:32806,varname:node_8891,prsc:2|A-8504-RGB,B-974-OUT,T-3253-VFACE;n:type:ShaderForge.SFN_Vector3,id:974,x:32881,y:32669,varname:node_974,prsc:2,v1:1,v2:1,v3:1;n:type:ShaderForge.SFN_ValueProperty,id:5989,x:30906,y:33065,ptovrint:False,ptlb:ofset,ptin:_ofset,varname:_ofset,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:1100,x:33507,y:33245,varname:node_1100,prsc:2|A-5128-A,B-5747-OUT;n:type:ShaderForge.SFN_Clamp01,id:129,x:33665,y:33037,varname:node_129,prsc:2|IN-1100-OUT;n:type:ShaderForge.SFN_VertexColor,id:3141,x:32024,y:32781,varname:node_3141,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:142,x:30945,y:32789,varname:node_142,prsc:2|IN-3141-A;n:type:ShaderForge.SFN_Multiply,id:2532,x:31324,y:32600,varname:node_2532,prsc:2|A-7317-OUT,B-7349-OUT;n:type:ShaderForge.SFN_Add,id:6690,x:31180,y:32973,varname:node_6690,prsc:2|A-2487-OUT,B-5989-OUT;n:type:ShaderForge.SFN_Subtract,id:4520,x:32332,y:32424,varname:node_4520,prsc:2|A-2773-OUT,B-4045-OUT;n:type:ShaderForge.SFN_Subtract,id:3232,x:31564,y:32694,varname:node_3232,prsc:2|A-2532-OUT,B-6545-OUT;n:type:ShaderForge.SFN_Vector1,id:6545,x:31324,y:32749,varname:node_6545,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:2487,x:31270,y:32813,varname:node_2487,prsc:2|A-3232-OUT,B-142-OUT;n:type:ShaderForge.SFN_Add,id:7132,x:33195,y:33564,varname:node_7132,prsc:2|A-3141-A,B-6001-OUT;n:type:ShaderForge.SFN_Slider,id:6001,x:32804,y:33737,ptovrint:False,ptlb:opasity_svich,ptin:_opasity_svich,varname:_opasity_svich,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Clamp01,id:5747,x:33368,y:33564,varname:node_5747,prsc:2|IN-7132-OUT;n:type:ShaderForge.SFN_Step,id:3900,x:33872,y:33231,varname:node_3900,prsc:2|A-4375-OUT,B-129-OUT;n:type:ShaderForge.SFN_Vector1,id:4375,x:33679,y:33400,varname:node_4375,prsc:2,v1:0.5;proporder:5128-7317-7349-8504-5989-6001;pass:END;sub:END;*/

Shader "Shader Forge/a_Seqwense on mesh" {
    Properties {
        _texture ("texture", 2D) = "white" {}
        _y ("y", Float ) = 3
        _x ("x", Float ) = 4
        _backColor ("back Color", Color) = (0.5,0.5,0.5,1)
        _ofset ("ofset", Float ) = 0
        _opasity_svich ("opasity_svich", Range(0, 1)) = 0
        
    }
    SubShader {
        Tags {
            //"IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            uniform sampler2D _texture; uniform float4 _texture_ST;
            uniform float _x;
            uniform float _y;
            uniform float4 _backColor;
            uniform float _ofset;
            uniform float _opasity_svich;
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
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float node_2069 = floor(((((_y*_x)-1.0)*(1.0 - i.vertexColor.a))+_ofset));
                float node_2773 = 1.0;
                float2 node_21 = float2(((node_2069/_x)+(i.uv0.r/_x)),frac(((-1*(floor((node_2069/_x))/_y))+(i.uv0.g/_y)+(node_2773-(node_2773/_y)))));
                float4 _texture_var = tex2D(_texture,TRANSFORM_TEX(node_21, _texture));
                float3 emissive = (lerp(_backColor.rgb,float3(1,1,1),isFrontFace)*_texture_var.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,step(0.5,saturate((_texture_var.a*saturate((i.vertexColor.a+_opasity_svich))))));
            }
            ENDCG
        }
    }
    FallBack "null"
    //CustomEditor "ShaderForgeMaterialInspector"
}
