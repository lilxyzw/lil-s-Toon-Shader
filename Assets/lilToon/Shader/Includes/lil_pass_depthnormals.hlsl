#ifndef LIL_PASS_DEPTHNORMAL_INCLUDED
#define LIL_PASS_DEPTHNORMAL_INCLUDED

#include "Includes/lil_pipeline.hlsl"

//------------------------------------------------------------------------------------------------------------------------------
// Struct
struct appdata
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    #if LIL_RENDER > 0 || defined(LIL_OUTLINE)
        float2 uv           : TEXCOORD0;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS   : SV_POSITION;
    float3 normalWS     : TEXCOORD0;
    #if LIL_RENDER > 0
        float2 uv           : TEXCOORD1;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//------------------------------------------------------------------------------------------------------------------------------
// Shader
v2f vert(appdata input)
{
    v2f output;
    LIL_INITIALIZE_STRUCT(v2f, output);

    LIL_BRANCH
    if(_Invisible) return output;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    LIL_VERTEX_POSITION_INPUTS(input.positionOS, vertexInput);
    LIL_VERTEX_NORMAL_INPUTS(input.normalOS, vertexNormalInput);

    #if defined(LIL_OUTLINE)
        LIL_VERTEX_NORMAL_INPUTS(input.normalOS, vertexNormalInput);
        float2 uvMain = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
        float outlineWidth = _OutlineWidth * 0.01;
        if(Exists_OutlineWidthMask) outlineWidth *= LIL_SAMPLE_2D_LOD(_OutlineWidthMask, sampler_MainTex, uvMain, 0).r;
        if(_OutlineVertexR2Width) outlineWidth *= input.color.r;
        if(_OutlineFixWidth) outlineWidth *= saturate(length(LIL_GET_VIEWDIR_WS(vertexInput.positionWS)));
        vertexInput.positionWS += vertexNormalInput.normalWS * outlineWidth;
        output.positionCS = LIL_TRANSFORM_POS_WS_TO_CS(vertexInput.positionWS);
    #else
        output.positionCS = vertexInput.positionCS;
    #endif
    output.normalWS = vertexNormalInput.normalWS;
    output.normalWS = NormalizeNormalPerVertex(output.normalWS);
    #if LIL_RENDER > 0
        output.uv = input.uv;
    #endif

    return output;
}

float4 frag(v2f input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if LIL_RENDER > 0
        #if defined(LIL_FEATURE_ANIMATE_MAIN_UV)
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST, _MainTex_ScrollRotate);
        #else
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST);
        #endif
        float alpha = _Color.a;
        if(Exists_MainTex) alpha *= LIL_SAMPLE_2D(_MainTex, sampler_MainTex, uvMain).a;
        #if LIL_RENDER == 1
            clip(alpha - _Cutoff);
        #else
            clip(alpha - 0.5);
        #endif
    #endif

    return float4(PackNormalOctRectEncode(TransformWorldToViewDir(input.normalWS, true)), 0.0, 0.0);
}

#endif