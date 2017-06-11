// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33409,y:32727,varname:node_3138,prsc:2|emission-8478-OUT,alpha-6497-OUT;n:type:ShaderForge.SFN_Tex2d,id:1849,x:32435,y:32694,ptovrint:False,ptlb:node_1849,ptin:_node_1849,varname:node_1849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0935ccda1228edc4a8620176682c67b9,ntxv:0,isnm:False;n:type:ShaderForge.SFN_VertexColor,id:9938,x:32341,y:33243,varname:node_9938,prsc:2;n:type:ShaderForge.SFN_Multiply,id:8478,x:32823,y:32870,varname:node_8478,prsc:2|A-1849-RGB,B-9938-RGB,C-2101-OUT;n:type:ShaderForge.SFN_Multiply,id:4410,x:32998,y:33099,varname:node_4410,prsc:2|A-7625-OUT,B-9938-A,C-9612-OUT,D-2101-OUT;n:type:ShaderForge.SFN_Max,id:5711,x:32647,y:32664,varname:node_5711,prsc:2|A-1849-R,B-1849-G;n:type:ShaderForge.SFN_Max,id:4191,x:32813,y:32676,varname:node_4191,prsc:2|A-5711-OUT,B-1849-B;n:type:ShaderForge.SFN_SwitchProperty,id:150,x:32327,y:32996,ptovrint:False,ptlb:normal_direct,ptin:_normal_direct,varname:node_150,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7309-OUT,B-3365-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2101,x:32488,y:32899,ptovrint:False,ptlb:Color Multiplier,ptin:_ColorMultiplier,varname:node_2101,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:6497,x:33165,y:33099,varname:node_6497,prsc:2|IN-4410-OUT;n:type:ShaderForge.SFN_Dot,id:7309,x:31992,y:32870,varname:node_7309,prsc:2,dt:0|A-9713-OUT,B-5653-OUT;n:type:ShaderForge.SFN_NormalVector,id:8525,x:31349,y:32515,prsc:2,pt:False;n:type:ShaderForge.SFN_ViewVector,id:5653,x:31332,y:32820,varname:node_5653,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2249,x:31596,y:32670,varname:node_2249,prsc:2|A-5653-OUT,B-8126-OUT;n:type:ShaderForge.SFN_Subtract,id:9713,x:31596,y:32515,varname:node_9713,prsc:2|A-8525-OUT,B-2249-OUT;n:type:ShaderForge.SFN_Negate,id:3365,x:32004,y:33022,varname:node_3365,prsc:2|IN-7309-OUT;n:type:ShaderForge.SFN_Clamp01,id:9612,x:32498,y:32996,varname:node_9612,prsc:2|IN-150-OUT;n:type:ShaderForge.SFN_Slider,id:8126,x:31253,y:32704,ptovrint:False,ptlb:exp,ptin:_exp,varname:node_8126,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3681614,max:1;n:type:ShaderForge.SFN_Multiply,id:5378,x:32994,y:32715,varname:node_5378,prsc:2|A-4191-OUT,B-5957-OUT;n:type:ShaderForge.SFN_Vector1,id:5957,x:32823,y:32797,varname:node_5957,prsc:2,v1:3;n:type:ShaderForge.SFN_Clamp01,id:7625,x:33144,y:32715,varname:node_7625,prsc:2|IN-5378-OUT;proporder:1849-150-2101-8126;pass:END;sub:END;*/

Shader "Shader Forge/A_Faloff_Alpha" {
    Properties {
        _node_1849 ("node_1849", 2D) = "white" {}
        [MaterialToggle] _normal_direct ("normal_direct", Float ) = 0
        _ColorMultiplier ("Color Multiplier", Float ) = 1
        _exp ("exp", Range(0, 1)) = 0.3681614
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
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform sampler2D _node_1849; uniform float4 _node_1849_ST;
            uniform fixed _normal_direct;
            uniform float _ColorMultiplier;
            uniform float _exp;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _node_1849_var = tex2D(_node_1849,TRANSFORM_TEX(i.uv0, _node_1849));
                float3 emissive = (_node_1849_var.rgb*i.vertexColor.rgb*_ColorMultiplier);
                float3 finalColor = emissive;
                float node_7309 = dot((i.normalDir-(viewDirection*_exp)),viewDirection);
                return fixed4(finalColor,saturate((saturate((max(max(_node_1849_var.r,_node_1849_var.g),_node_1849_var.b)*3.0))*i.vertexColor.a*saturate(lerp( node_7309, (-1*node_7309), _normal_direct ))*_ColorMultiplier)));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
