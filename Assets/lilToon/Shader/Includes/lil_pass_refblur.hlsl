
#ifndef LIL_PASS_REFLACTION_BLUR_INCLUDED
#define LIL_PASS_REFLACTION_BLUR_INCLUDED

#include "Includes/lil_pipeline.hlsl"

//------------------------------------------------------------------------------------------------------------------------------
// Struct
struct appdata
{
    float4 positionOS       : POSITION;
    float2 uv               : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 positionCS       : SV_POSITION;
    float2 uv               : TEXCOORD0;
    float4 positionSS       : TEXCOORD1;
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

    output.uv           = input.uv;
    output.positionCS   = vertexInput.positionCS;
    output.positionSS   = vertexInput.positionSS;
    return output;
}

float4 frag(v2f input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(LIL_FEATURE_REFLECTION)
        #if defined(LIL_FEATURE_ANIMATE_MAIN_UV)
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST, _MainTex_ScrollRotate);
        #else
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST);
        #endif
        float2 scnUV = input.positionSS.xy/input.positionSS.w;
        float3 refractCol = 0;
        float sum = 0;
        float smoothness = _Smoothness;
        if(Exists_SmoothnessTex) smoothness *= LIL_SAMPLE_2D(_SmoothnessTex, sampler_linear_repeat, uvMain).r;
        float perceptualRoughness = 1.0 - smoothness;
        float roughness = perceptualRoughness * perceptualRoughness;
        float blurOffset = perceptualRoughness / input.positionSS.z * _BackgroundTexture_TexelSize.x / _BackgroundTexture_TexelSize.y * (0.0005 / LIL_REFRACTION_SAMPNUM);
        for(int j = -LIL_REFRACTION_SAMPNUM; j <= LIL_REFRACTION_SAMPNUM; j++)
        {
            refractCol += LIL_SAMPLE_2D(_BackgroundTexture, sampler_BackgroundTexture, scnUV + float2(j*blurOffset,0)).rgb * LIL_REFRACTION_GAUSDIST(j);
            sum += LIL_REFRACTION_GAUSDIST(j);
        }
        refractCol /= sum;
        return float4(refractCol,1.0);
    #else
        float2 scnUV = input.positionSS.xy/input.positionSS.w;
        float3 refractCol = LIL_SAMPLE_2D(_BackgroundTexture, sampler_BackgroundTexture, scnUV).rgb;
        return float4(refractCol,1.0);
    #endif
}

#endif