// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33860,y:32784,varname:node_3138,prsc:2|emission-7505-OUT,alpha-7634-OUT,voffset-3444-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32902,y:32399,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:9210,x:32654,y:32710,ptovrint:False,ptlb:node_9210,ptin:_node_9210,varname:node_9210,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:3238139248af6f947b5ce426063089a7,ntxv:0,isnm:False;n:type:ShaderForge.SFN_VertexColor,id:9892,x:32147,y:33052,varname:node_9892,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:9728,x:32306,y:33287,ptovrint:False,ptlb:appear,ptin:_appear,varname:node_9728,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7634,x:32934,y:32835,varname:node_7634,prsc:2|A-8743-OUT,B-9210-A,C-9321-OUT,D-9892-A;n:type:ShaderForge.SFN_OneMinus,id:3345,x:32147,y:32820,varname:node_3345,prsc:2|IN-9892-R;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:5207,x:32888,y:33056,varname:node_5207,prsc:2|IN-3345-OUT,IMIN-7777-OUT,IMAX-9728-OUT,OMIN-7777-OUT,OMAX-3076-OUT;n:type:ShaderForge.SFN_Vector1,id:7777,x:32537,y:33168,varname:node_7777,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:3076,x:32682,y:33279,varname:node_3076,prsc:2,v1:1;n:type:ShaderForge.SFN_Clamp01,id:6314,x:33101,y:33124,varname:node_6314,prsc:2|IN-5207-OUT;n:type:ShaderForge.SFN_Frac,id:8743,x:33283,y:33124,varname:node_8743,prsc:2|IN-6314-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9321,x:32654,y:32565,ptovrint:False,ptlb:multiply,ptin:_multiply,varname:node_9321,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:7505,x:33129,y:32555,varname:node_7505,prsc:2|A-7241-RGB,B-9210-RGB,C-9321-OUT;n:type:ShaderForge.SFN_NormalVector,id:4470,x:33313,y:33543,prsc:2,pt:False;n:type:ShaderForge.SFN_Vector1,id:734,x:33493,y:33571,varname:node_734,prsc:2,v1:0.001;n:type:ShaderForge.SFN_ValueProperty,id:1132,x:32925,y:33357,ptovrint:False,ptlb:offset,ptin:_offset,varname:node_1132,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:7102,x:33462,y:33433,ptovrint:False,ptlb:distor,ptin:_distor,varname:node_7102,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3444,x:33703,y:33322,varname:node_3444,prsc:2|A-9561-OUT,B-4470-OUT,C-734-OUT,D-7102-OUT;n:type:ShaderForge.SFN_Sin,id:9561,x:33361,y:33304,varname:node_9561,prsc:2|IN-1318-OUT;n:type:ShaderForge.SFN_Multiply,id:6005,x:33004,y:33463,varname:node_6005,prsc:2|A-4099-OUT,B-7759-OUT;n:type:ShaderForge.SFN_Add,id:1318,x:33209,y:33399,varname:node_1318,prsc:2|A-1132-OUT,B-6005-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4099,x:32927,y:33810,ptovrint:False,ptlb:freq(20-50),ptin:_freq2050,varname:node_4099,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:40;n:type:ShaderForge.SFN_Add,id:7759,x:32696,y:33473,varname:node_7759,prsc:2|A-9892-G,B-9892-R;n:type:ShaderForge.SFN_TexCoord,id:3738,x:33607,y:32682,varname:node_3738,prsc:2,uv:0;proporder:7241-9210-9728-9321-1132-7102-4099;pass:END;sub:END;*/

Shader "Shader Forge/Ability2_Trail" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _node_9210 ("node_9210", 2D) = "white" {}
        _appear ("appear", Float ) = 0
        _multiply ("multiply", Float ) = 1
        _offset ("offset", Float ) = 0
        _distor ("distor", Float ) = 0
        _freq2050 ("freq(20-50)", Float ) = 40
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

	
			Pass{
			ZWrite Off
			ColorMask 0
			}



        Pass {

            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
				"Queue"="Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off



            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 2.0
            uniform float4 _Color;
            uniform sampler2D _node_9210; uniform float4 _node_9210_ST;
            uniform float _appear;
            uniform float _multiply;
            uniform float _offset;
            uniform float _distor;
            uniform float _freq2050;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                v.vertex.xyz += (sin((_offset+(_freq2050*(o.vertexColor.g+o.vertexColor.r))))*v.normal*0.001*_distor);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _node_9210_var = tex2D(_node_9210,TRANSFORM_TEX(i.uv0, _node_9210));
                float3 emissive = (_Color.rgb*_node_9210_var.rgb*_multiply);
                float3 finalColor = emissive;
                float node_7777 = 0.0;
				return fixed4(finalColor, (frac(saturate((node_7777 + ( ((1.0 - i.vertexColor.r) - node_7777) * (1.0 - node_7777) ) / (_appear - node_7777))))*_node_9210_var.a*_multiply*i.vertexColor.a));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    //CustomEditor "ShaderForgeMaterialInspector"
}
