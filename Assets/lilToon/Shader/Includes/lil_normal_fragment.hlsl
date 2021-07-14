#ifndef LIL_FRAGMENT_INCLUDED
#define LIL_FRAGMENT_INCLUDED

//------------------------------------------------------------------------------------------------------------------------------
// Fragment shader
float4 frag(v2f input, float facing : VFACE) : SV_Target
{
    LIL_SETUP_INSTANCE_ID(input);
    LIL_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    LIL_GET_MAINLIGHT(input, lightColor, lightDirection, attenuation);
    LIL_GET_VERTEXLIGHT(input, vertexLightColor);
    LIL_GET_ADDITIONALLIGHT(input.positionWS, additionalLightColor);
    #if !defined(LIL_PASS_FORWARDADD)
        lightColor = lerp(lightColor, 1.0, _AsUnlit);
        vertexLightColor = lerp(vertexLightColor, 0.0, _AsUnlit);
        additionalLightColor = lerp(additionalLightColor, 0.0, _AsUnlit);
    #else
        lightColor = lerp(lightColor, 0.0, _AsUnlit);
    #endif

    //--------------------------------------------------------------------------------------------------------------------------
    // Apply Matelial & Lighting
    #if defined(LIL_OUTLINE)
        //--------------------------------------------------------------------------------------------------------------------------
        // UV
        #if defined(LIL_FEATURE_ANIMATE_OUTLINE_UV)
            float2 uvMain = lilCalcUV(input.uv, _OutlineTex_ST, _OutlineTex_ScrollRotate);
        #else
            float2 uvMain = lilCalcUV(input.uv, _OutlineTex_ST);
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // Main Color
        float4 col = 1.0;
        if(Exists_OutlineTex)
        {
            col = LIL_SAMPLE_2D(_OutlineTex, sampler_OutlineTex, uvMain);
            #if defined(LIL_FEATURE_OUTLINE_TONE_CORRECTION)
                col.rgb = lilToneCorrection(col.rgb, _OutlineTexHSVG);
            #endif
        }
        col *= _OutlineColor;

        // Dissolve
        #if defined(LIL_FEATURE_DISSOLVE) && LIL_RENDER != 0
            float dissolveAlpha = 0.0;
            #if defined(LIL_FEATURE_TEX_DISSOLVE_NOISE)
                lilCalcDissolveWithNoise(
                    col.a,
                    dissolveAlpha,
                    input.uv,
                    input.positionOS,
                    _DissolveParams,
                    _DissolvePos,
                    _DissolveMask,
                    _DissolveMask_ST,
                    _DissolveNoiseMask,
                    _DissolveNoiseMask_ST,
                    _DissolveNoiseMask_ScrollRotate,
                    _DissolveNoiseStrength
                );
            #else
                lilCalcDissolve(
                    col.a,
                    dissolveAlpha,
                    input.uv,
                    input.positionOS,
                    _DissolveParams,
                    _DissolvePos,
                    _DissolveMask,
                    _DissolveMask_ST
                );
            #endif
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Alpha
        #if LIL_RENDER == 0
            // Opaque
        #elif LIL_RENDER == 1
            // Cutout
            col.a = saturate((col.a - _Cutoff) / max(fwidth(col.a), 0.0001) + 0.5);
        #elif LIL_RENDER == 2 && !defined(LIL_REFRACTION)
            // Transparent
            clip(col.a - _Cutoff);
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Lighting
        col.rgb = lerp(col.rgb, col.rgb * saturate(lightColor + vertexLightColor + additionalLightColor), _OutlineEnableLighting);
    #elif defined(LIL_FUR)
        //--------------------------------------------------------------------------------------------------------------------------
        // UV
        #if defined(LIL_FEATURE_ANIMATE_MAIN_UV)
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST, _MainTex_ScrollRotate);
        #else
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST);
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // Main Color
        float4 col = 1.0;
        if(Exists_MainTex) col = LIL_SAMPLE_2D(_MainTex, sampler_MainTex, uvMain);
        col *= _Color;

        //----------------------------------------------------------------------------------------------------------------------
        // Alpha
        #if LIL_RENDER == 0
            // Opaque
        #elif LIL_RENDER == 1
            // Cutout
            col.a = saturate((col.a - _Cutoff) / max(fwidth(col.a), 0.0001) + 0.5);
        #elif LIL_RENDER == 2 && !defined(LIL_REFRACTION)
            // Transparent
            clip(col.a - _Cutoff);
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Fur AO
        #if LIL_RENDER == 1
            col.rgb *= 1.0-_FurAO;
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Copy
        float3 albedo = col.rgb;

        #ifndef LIL_PASS_FORWARDADD
            //----------------------------------------------------------------------------------------------------------------------
            // Lighting
            #if defined(LIL_FEATURE_SHADOW)
                float3 normalDirection = normalize(input.normalWS);
                normalDirection = facing < (_FlipNormal-1.0) ? -normalDirection : normalDirection;
                float shadowmix = 1.0;
                lilGetShading(col, shadowmix, albedo, lightColor, uvMain, facing, normalDirection, 1, lightDirection);
            #endif
            col.rgb += albedo * vertexLightColor + albedo * additionalLightColor;
            col.rgb = min(col.rgb, albedo);
        #else
            col.rgb *= lightColor;
            // Premultiply for ForwardAdd
            #if LIL_RENDER == 2 && LIL_PREMULTIPLY_FA
                col.rgb *= col.a;
            #endif
        #endif
    #else
        //--------------------------------------------------------------------------------------------------------------------------
        // UV
        #if defined(LIL_FEATURE_ANIMATE_MAIN_UV)
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST, _MainTex_ScrollRotate);
        #else
            float2 uvMain = lilCalcUV(input.uv, _MainTex_ST);
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // View Direction
        #if defined(LIL_SHOULD_POSITION_WS)
            float3 viewDirection = normalize(LIL_GET_VIEWDIR_WS(input.positionWS.xyz));
        #endif
        #if defined(LIL_SHOULD_TBN)
            float3x3 tbnWS = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
            #if defined(LIL_SHOULD_POSITION_WS)
                float3 parallaxViewDirection = mul(tbnWS, viewDirection);
                float2 parallaxOffset = (parallaxViewDirection.xy / (parallaxViewDirection.z+0.5));
            #endif
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // Parallax
        #if defined(LIL_FEATURE_PARALLAX)
            float2 ddxMain = ddx(uvMain);
            float2 ddyMain = ddy(uvMain);
            LIL_BRANCH
            if(Exists_ParallaxMap && _UseParallax)
            {
                #if defined(LIL_FEATURE_POM)
                    // POM
                    #define LIL_POM_DETAIL 200
                    float height;
                    float height2;
                    float3 rayStep = -parallaxViewDirection;
                    float3 rayPos = float3(uvMain, 1.0) + (1.0-_ParallaxOffset) * _Parallax * parallaxViewDirection;
                    rayStep.xy *= _MainTex_ST.xy;
                    rayStep = rayStep / LIL_POM_DETAIL;
                    rayStep.z /= _Parallax;

                    for(int i = 0; i < LIL_POM_DETAIL * 2 * _Parallax; ++i)
                    {
                        height2 = height;
                        rayPos += rayStep;
                        height = LIL_SAMPLE_2D_LOD(_ParallaxMap,sampler_linear_repeat,rayPos.xy,0).r;
                        if(height >= rayPos.z) break;
                    }

                    float2 prevObjPoint = rayPos.xy - rayStep.xy;
                    float nextHeight = height - rayPos.z;
                    float prevHeight = height2 - rayPos.z + rayStep.z;

                    float weight = nextHeight / (nextHeight - prevHeight);
                    rayPos.xy = lerp(rayPos.xy, prevObjPoint, weight);

                    input.uv += rayPos.xy - uvMain;
                    uvMain = rayPos.xy;
                #else
                    // Parallax
                    float height = (LIL_SAMPLE_2D_LOD(_ParallaxMap,sampler_linear_repeat,uvMain,0).r - _ParallaxOffset) * _Parallax;
                    uvMain += height * parallaxOffset;
                    input.uv += height * parallaxOffset;
                #endif
            }
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // Main Color
        float4 col = 1.0;
        if(Exists_MainTex)
        {
            col = LIL_SAMPLE_2D_POM(_MainTex, sampler_MainTex, uvMain, ddxMain, ddyMain);
            #if defined(LIL_FEATURE_MAIN_TONE_CORRECTION)
                col.rgb = lilToneCorrection(col.rgb, _MainTexHSVG);
            #endif
            #if defined(LIL_FEATURE_MAIN_GRADATION_MAP)
                col.rgb = lilGradationMap(col.rgb, _MainGradationTex, sampler_linear_clamp, _MainGradationStrength);
            #endif
        }
        col *= _Color;

        // Dissolve
        #if defined(LIL_FEATURE_DISSOLVE) && LIL_RENDER != 0
            float dissolveAlpha = 0.0;
            #if defined(LIL_FEATURE_TEX_DISSOLVE_NOISE)
                lilCalcDissolveWithNoise(
                    col.a,
                    dissolveAlpha,
                    input.uv,
                    input.positionOS,
                    _DissolveParams,
                    _DissolvePos,
                    _DissolveMask,
                    _DissolveMask_ST,
                    _DissolveNoiseMask,
                    _DissolveNoiseMask_ST,
                    _DissolveNoiseMask_ScrollRotate,
                    _DissolveNoiseStrength
                );
            #else
                lilCalcDissolve(
                    col.a,
                    dissolveAlpha,
                    input.uv,
                    input.positionOS,
                    _DissolveParams,
                    _DissolvePos,
                    _DissolveMask,
                    _DissolveMask_ST
                );
            #endif
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Alpha Mask
        #if defined(LIL_FEATURE_ALPHAMASK) && LIL_RENDER != 0
            if(_AlphaMaskMode)
            {
                float alphaMask = LIL_SAMPLE_2D(_AlphaMask, sampler_MainTex, uvMain).r;
                alphaMask = saturate(alphaMask + _AlphaMaskValue);
                col.a = _AlphaMaskMode == 1 ? alphaMask : col.a * alphaMask;
            }
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Alpha
        float alpha = col.a;
        #if LIL_RENDER == 0
            // Opaque
        #elif LIL_RENDER == 1
            // Cutout
            col.a = saturate((col.a - _Cutoff) / max(fwidth(col.a), 0.0001) + 0.5);
        #elif LIL_RENDER == 2 && !defined(LIL_REFRACTION)
            // Transparent
            clip(col.a - _Cutoff);
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Normal
        #if defined(LIL_SHOULD_NORMAL)
            #if defined(LIL_FEATURE_NORMAL_1ST) || defined(LIL_FEATURE_NORMAL_2ND)
                float3 normalmap = float3(0.0,0.0,1.0);

                // 1st
                #if defined(LIL_FEATURE_NORMAL_1ST)
                    LIL_BRANCH
                    if(Exists_BumpMap && _UseBumpMap)
                    {
                        float4 normalTex = LIL_SAMPLE_2D_ST(_BumpMap, sampler_MainTex, uvMain);
                        normalmap = UnpackNormalScale(normalTex, _BumpScale);
                    }
                #endif

                // 2nd
                #if defined(LIL_FEATURE_NORMAL_2ND)
                    LIL_BRANCH
                    if(Exists_Bump2ndMap && _UseBump2ndMap)
                    {
                        float4 normal2ndTex = LIL_SAMPLE_2D_ST(_Bump2ndMap, sampler_MainTex, uvMain);
                        float bump2ndScale = _Bump2ndScale;
                        if(Exists_Bump2ndScaleMask) bump2ndScale *= LIL_SAMPLE_2D(_Bump2ndScaleMask, sampler_MainTex, uvMain).r;
                        normalmap = lilBlendNormal(normalmap, UnpackNormalScale(normal2ndTex, bump2ndScale));
                    }
                #endif

                float3 normalDirection = normalize(mul(normalmap, tbnWS));
                normalDirection = facing < (_FlipNormal-1.0) ? -normalDirection : normalDirection;
            #else
                float3 normalDirection = normalize(input.normalWS);
                normalDirection = facing < (_FlipNormal-1.0) ? -normalDirection : normalDirection;
            #endif
            #if defined(LIL_SHOULD_POSITION_WS)
                float nv = saturate(dot(normalDirection, viewDirection));
                float nvabs = abs(dot(normalDirection, viewDirection));
            #else
                float nv = 1.0;
                float nvabs = 1.0;
            #endif
        #else
            float nv = 1.0;
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // AudioLink (https://github.com/llealloo/vrc-udon-audio-link)
        #if defined(LIL_FEATURE_AUDIOLINK)
            float audioLinkValue = 1.0;
            if(_UseAudioLink)
            {
                audioLinkValue = 0.0;
                float4 audioLinkMask = 1.0;
                float2 audioLinkUV;
                if(_AudioLinkUVMode == 0) audioLinkUV.x = _AudioLinkUVParams.g;
                if(_AudioLinkUVMode == 1) audioLinkUV.x = _AudioLinkUVParams.r - nv * _AudioLinkUVParams.r + _AudioLinkUVParams.g;
                if(_AudioLinkUVMode == 2) audioLinkUV.x = lilRotateUV(input.uv, _AudioLinkUVParams.b).x * _AudioLinkUVParams.r + _AudioLinkUVParams.g;
                audioLinkUV.y = _AudioLinkUVParams.a;
                // Mask (R:Delay G:Band B:Strength)
                if(_AudioLinkUVMode == 3 && Exists_AudioLinkMask)
                {
                    audioLinkMask = LIL_SAMPLE_2D(_AudioLinkMask, sampler_MainTex, uvMain);
                    audioLinkUV = audioLinkMask.rg;
                }
                // Scaling for _AudioTexture (4/64)
                #if defined(LIL_FEATURE_AUDIOLINK_LOCAL)
                    if(!_AudioLinkAsLocal) audioLinkUV.y *= 0.0625;
                #else
                    audioLinkUV.y *= 0.0625;
                #endif
                // Global
                if(_AudioTexture_TexelSize.z > 16)
                {
                    audioLinkValue = LIL_SAMPLE_2D(_AudioTexture, sampler_linear_clamp, audioLinkUV).r;
                    audioLinkValue = saturate(audioLinkValue);
                }
                // Local
                #if defined(LIL_FEATURE_AUDIOLINK_LOCAL)
                    if(_AudioLinkAsLocal)
                    {
                        audioLinkUV.x += frac(-LIL_TIME * _AudioLinkLocalMapParams.r / 60 * _AudioLinkLocalMapParams.g) + _AudioLinkLocalMapParams.b;
                        audioLinkValue = LIL_SAMPLE_2D(_AudioLinkLocalMap, sampler_linear_repeat, audioLinkUV).r;
                    }
                #endif
                audioLinkValue *= audioLinkMask.b;
            }
        #endif

        //--------------------------------------------------------------------------------------------------------------------------
        // Layer Color
        #if defined(LIL_SHOULD_TANGENT_W)
            bool isRightHand = input.tangentW > 0.0;
        #else
            bool isRightHand = true;
        #endif
        // 2nd
        #if defined(LIL_FEATURE_MAIN2ND)
            #if !(defined(LIL_FEATURE_DECAL) && defined(LIL_FEATURE_ANIMATE_DECAL))
                float4 _Main2ndTexDecalAnimation = 0.0;
                float4 _Main2ndTexDecalSubParam = 0.0;
            #endif
            #if !defined(LIL_FEATURE_DECAL)
                bool _Main2ndTexIsDecal = false;
                bool _Main2ndTexIsLeftOnly = false;
                bool _Main2ndTexIsRightOnly = false;
                bool _Main2ndTexShouldCopy = false;
                bool _Main2ndTexShouldFlipMirror = false;
                bool _Main2ndTexShouldFlipCopy = false;
            #endif
            #if defined(LIL_FEATURE_LAYER_DISSOLVE)
                float main2ndDissolveAlpha = 0.0;
            #endif
            float4 color2nd = _Color2nd;
            LIL_BRANCH
            if(_UseMain2ndTex)
            {
                if(Exists_Main2ndTex) color2nd *= LIL_GET_SUBTEX(_Main2ndTex, input.uv);
                if(Exists_Main2ndBlendMask) color2nd.a *= LIL_SAMPLE_2D(_Main2ndBlendMask, sampler_MainTex, uvMain).r;
                #if defined(LIL_FEATURE_LAYER_DISSOLVE)
                    #if defined(LIL_FEATURE_TEX_LAYER_DISSOLVE_NOISE)
                        lilCalcDissolveWithNoise(
                            color2nd.a,
                            main2ndDissolveAlpha,
                            input.uv,
                            input.positionOS,
                            _Main2ndDissolveParams,
                            _Main2ndDissolvePos,
                            _Main2ndDissolveMask,
                            _Main2ndDissolveMask_ST,
                            _Main2ndDissolveNoiseMask,
                            _Main2ndDissolveNoiseMask_ST,
                            _Main2ndDissolveNoiseMask_ScrollRotate,
                            _Main2ndDissolveNoiseStrength
                        );
                    #else
                        lilCalcDissolve(
                            color2nd.a,
                            main2ndDissolveAlpha,
                            input.uv,
                            input.positionOS,
                            _Main2ndDissolveParams,
                            _Main2ndDissolvePos,
                            _Main2ndDissolveMask,
                            _Main2ndDissolveMask_ST
                        );
                    #endif
                #endif
                #if defined(LIL_FEATURE_AUDIOLINK)
                    if(_AudioLink2Main2nd) color2nd.a *= audioLinkValue;
                #endif
                col.rgb = lilBlendColor(col.rgb, color2nd.rgb, color2nd.a * _Main2ndEnableLighting, _Main2ndTexBlendMode);
            }
        #endif

        // 3rd
        #if defined(LIL_FEATURE_MAIN3RD)
            #if !(defined(LIL_FEATURE_DECAL) && defined(LIL_FEATURE_ANIMATE_DECAL))
                float4 _Main3rdTexDecalAnimation = 0.0;
                float4 _Main3rdTexDecalSubParam = 0.0;
            #endif
            #if !defined(LIL_FEATURE_DECAL)
                bool _Main3rdTexIsDecal = false;
                bool _Main3rdTexIsLeftOnly = false;
                bool _Main3rdTexIsRightOnly = false;
                bool _Main3rdTexShouldCopy = false;
                bool _Main3rdTexShouldFlipMirror = false;
                bool _Main3rdTexShouldFlipCopy = false;
            #endif
            #if defined(LIL_FEATURE_LAYER_DISSOLVE)
                float main3rdDissolveAlpha = 0.0;
            #endif
            float4 color3rd = _Color3rd;
            LIL_BRANCH
            if(_UseMain3rdTex)
            {
                if(Exists_Main3rdTex) color3rd *= LIL_GET_SUBTEX(_Main3rdTex, input.uv);
                if(Exists_Main3rdBlendMask) color3rd.a *= LIL_SAMPLE_2D(_Main3rdBlendMask, sampler_MainTex, uvMain).r;
                #if defined(LIL_FEATURE_LAYER_DISSOLVE)
                    #if defined(LIL_FEATURE_TEX_LAYER_DISSOLVE_NOISE)
                        lilCalcDissolveWithNoise(
                            color3rd.a,
                            main3rdDissolveAlpha,
                            input.uv,
                            input.positionOS,
                            _Main3rdDissolveParams,
                            _Main3rdDissolvePos,
                            _Main3rdDissolveMask,
                            _Main3rdDissolveMask_ST,
                            _Main3rdDissolveNoiseMask,
                            _Main3rdDissolveNoiseMask_ST,
                            _Main3rdDissolveNoiseMask_ScrollRotate,
                            _Main3rdDissolveNoiseStrength
                        );
                    #else
                        lilCalcDissolve(
                            color3rd.a,
                            main3rdDissolveAlpha,
                            input.uv,
                            input.positionOS,
                            _Main3rdDissolveParams,
                            _Main3rdDissolvePos,
                            _Main3rdDissolveMask,
                            _Main3rdDissolveMask_ST
                        );
                    #endif
                #endif
                #if defined(LIL_FEATURE_AUDIOLINK)
                    if(_AudioLink2Main3rd) color3rd.a *= audioLinkValue;
                #endif
                col.rgb = lilBlendColor(col.rgb, color3rd.rgb, color3rd.a * _Main3rdEnableLighting, _Main3rdTexBlendMode);
            }
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Copy
        float3 albedo = col.rgb;

        //----------------------------------------------------------------------------------------------------------------------
        // Lighting
        #ifndef LIL_PASS_FORWARDADD
            float shadowmix = 1.0;
            #if defined(LIL_FEATURE_SHADOW)
                lilGetShading(col, shadowmix, albedo, lightColor, uvMain, facing, normalDirection, attenuation, lightDirection);
            #else
                col.rgb *= lightColor;
            #endif

            lightColor += vertexLightColor;
            shadowmix += lilLuminance(vertexLightColor);
            col.rgb += albedo * vertexLightColor;

            lightColor += additionalLightColor;
            shadowmix += lilLuminance(additionalLightColor);
            col.rgb += albedo * additionalLightColor;

            lightColor = saturate(lightColor);
            shadowmix = saturate(shadowmix);
            col.rgb = min(col.rgb, albedo);

            #if defined(LIL_FEATURE_MAIN2ND)
                if(_UseMain2ndTex) col.rgb = lilBlendColor(col.rgb, color2nd.rgb, color2nd.a - color2nd.a * _Main2ndEnableLighting, _Main2ndTexBlendMode);
            #endif
            #if defined(LIL_FEATURE_MAIN3RD)
                if(_UseMain3rdTex) col.rgb = lilBlendColor(col.rgb, color3rd.rgb, color3rd.a - color3rd.a * _Main3rdEnableLighting, _Main3rdTexBlendMode);
            #endif
        #else
            col.rgb *= lightColor;
            #if defined(LIL_FEATURE_MAIN2ND)
                if(_UseMain2ndTex) col.rgb = lerp(col.rgb, 0, color2nd.a - color2nd.a * _Main2ndEnableLighting);
            #endif
            #if defined(LIL_FEATURE_MAIN3RD)
                if(_UseMain3rdTex) col.rgb = lerp(col.rgb, 0, color3rd.a - color3rd.a * _Main3rdEnableLighting);
            #endif
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Premultiply
        #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
            col.rgb *= col.a;
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Refraction
        #if defined(LIL_REFRACTION) && !defined(LIL_PASS_FORWARDADD)
            float2 scnUV = input.positionSS.xy/input.positionSS.w;
            float2 refractUV = scnUV + (pow(1.0 - nv, _RefractionFresnelPower) * _RefractionStrength) * mul(LIL_MATRIX_V, float4(normalDirection,0)).xy;
            // Hide objects in front
            //float refrFix = UNITY_SAMPLE_DEPTH(LIL_SAMPLE_2D(_CameraDepthTexture, sampler_CameraDepthTexture, refractUV));
            //if(LinearEyeDepth(refrFix) < input.positionSS.w) refractUV = scnUV;
            #if defined(LIL_REFRACTION_BLUR2) && defined(LIL_FEATURE_REFLECTION)
                float smoothness = _Smoothness;
                if(Exists_SmoothnessTex) smoothness *= LIL_SAMPLE_2D(_SmoothnessTex, sampler_MainTex, uvMain).r;
                float perceptualRoughness = 1.0 - smoothness;
                float roughness = perceptualRoughness * perceptualRoughness;
                float3 refractCol = 0;
                float sum = 0;
                float blurOffset = perceptualRoughness / input.positionSS.z * (0.0005 / LIL_REFRACTION_SAMPNUM);
                for(int j = -16; j <= 16; j++)
                {
                    refractCol += LIL_SAMPLE_2D(_BackgroundTexture2, sampler_BackgroundTexture2, refractUV + float2(0,j*blurOffset)).rgb * LIL_REFRACTION_GAUSDIST(j);
                    sum += LIL_REFRACTION_GAUSDIST(j);
                }
                refractCol /= sum;
                refractCol *= _RefractionColor.rgb;
            #elif defined(LIL_REFRACTION_BLUR2)
                float3 refractCol = LIL_SAMPLE_2D(_BackgroundTexture2, sampler_BackgroundTexture2, refractUV).rgb * _RefractionColor.rgb;
            #else
                float3 refractCol = LIL_SAMPLE_2D(_BackgroundTexture, sampler_BackgroundTexture, refractUV).rgb * _RefractionColor.rgb;
            #endif
            if(_RefractionColorFromMain) refractCol *= albedo;
            col.rgb = lerp(refractCol, col.rgb, col.a);
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Reflection
        #if defined(LIL_FEATURE_REFLECTION)
            #ifndef LIL_PASS_FORWARDADD
                LIL_BRANCH
                if(_UseReflection)
            #else
                LIL_BRANCH
                if(_UseReflection && _ApplySpecular)
            #endif
            {
                float3 reflectCol = 0;
                // Smoothness
                #if !defined(LIL_REFRACTION_BLUR2) || defined(LIL_PASS_FORWARDADD)
                    float smoothness = _Smoothness;
                    if(Exists_SmoothnessTex) smoothness *= LIL_SAMPLE_2D(_SmoothnessTex, sampler_MainTex, uvMain).r;
                    float perceptualRoughness = 1.0 - smoothness;
                    float roughness = perceptualRoughness * perceptualRoughness;
                #endif
                // Metallic
                float metallic = _Metallic;
                if(Exists_MetallicGlossMap) metallic *= LIL_SAMPLE_2D(_MetallicGlossMap, sampler_MainTex, uvMain).r;
                col.rgb = col.rgb - metallic * col.rgb;
                float3 specular = lerp(_Reflectance,albedo,metallic);
                // Specular
                #ifndef LIL_PASS_FORWARDADD
                    LIL_BRANCH
                    if(_ApplySpecular)
                #endif
                {
                    float3 lightDirectionSpc = lilGetLightDirection(input.positionWS);
                    float3 halfDirection = normalize(viewDirection + lightDirectionSpc);
                    float nl = saturate(dot(normalDirection, lightDirectionSpc));
                    float nh = saturate(dot(normalDirection, halfDirection));
                    float lh = saturate(dot(lightDirectionSpc, halfDirection));
                    #if defined(SHADOWS_SCREEN) || defined(LIL_PASS_FORWARDADD)
                        reflectCol = lilCalcSpecular(nv, nl, nh, lh, roughness, specular, _SpecularToon, attenuation) * _MainLightColor.rgb;
                    #else
                        reflectCol = lilCalcSpecular(nv, nl, nh, lh, roughness, specular, _SpecularToon) * _MainLightColor.rgb;
                    #endif
                }
                // Reflection
                #ifndef LIL_PASS_FORWARDADD
                    LIL_BRANCH
                    if(_ApplyReflection)
                    {
                        LIL_GET_ENVIRONMENT_REFLECTION(viewDirection, normalDirection, perceptualRoughness, input.positionWS, envReflectionColor);

                        float oneMinusReflectivity = LIL_DIELECTRIC_SPECULAR.a - metallic * LIL_DIELECTRIC_SPECULAR.a;
                        float grazingTerm = saturate(smoothness + (1.0-oneMinusReflectivity));
                        #ifdef LIL_COLORSPACE_GAMMA
                            float surfaceReduction = 1.0 - 0.28 * roughness * perceptualRoughness;
                        #else
                            float surfaceReduction = 1.0 / (roughness * roughness + 1.0);
                        #endif

                        #ifdef LIL_REFRACTION
                            col.rgb = lerp(envReflectionColor, col.rgb, col.a+(1.0-col.a)*pow(nvabs,_RefractionStrength*0.5+0.25));
                            reflectCol += col.a * surfaceReduction * envReflectionColor * lilFresnelLerp(specular, grazingTerm, nv);
                            col.a = 1.0;
                        #else
                            reflectCol += surfaceReduction * envReflectionColor * lilFresnelLerp(specular, grazingTerm, nv);
                        #endif
                    }
                #endif
                // Mix
                float4 reflectionColor = _ReflectionColor;
                if(Exists_ReflectionColorTex) reflectionColor *= LIL_SAMPLE_2D(_ReflectionColorTex, sampler_MainTex, uvMain);
                #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
                    if(_ReflectionApplyTransparency) reflectionColor.a *= col.a;
                #endif
                col.rgb += reflectionColor.rgb * reflectionColor.a * reflectCol;
            }
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // MatCap
        #if defined(LIL_FEATURE_MATCAP)
            LIL_BRANCH
            if(_UseMatCap)
            {
                float2 matUV = lilCalcMatCapUV(normalDirection);
                float4 matCapColor = _MatCapColor;
                if(Exists_MatCapTex) matCapColor *= LIL_SAMPLE_2D(_MatCapTex, sampler_MainTex, matUV);
                #ifndef LIL_PASS_FORWARDADD
                    matCapColor.rgb = lerp(matCapColor.rgb, matCapColor.rgb * lightColor, _MatCapEnableLighting);
                #else
                    if(_MatCapBlendMode < 3) matCapColor.rgb *= lightColor * _MatCapEnableLighting;
                #endif
                #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
                    if(_MatCapApplyTransparency) matCapColor.a *= col.a;
                #endif
                if(Exists_MatCapBlendMask) matCapColor.a *= LIL_SAMPLE_2D(_MatCapBlendMask, sampler_MainTex, uvMain).r;
                col.rgb = lilBlendColor(col.rgb, matCapColor.rgb, _MatCapBlend * matCapColor.a, _MatCapBlendMode);
            }
        #endif

        //----------------------------------------------------------------------------------------------------------------------
        // Rim light
        #if defined(LIL_FEATURE_RIMLIGHT)
            #ifndef LIL_PASS_FORWARDADD
                LIL_BRANCH
                if(_UseRim)
            #else
                LIL_BRANCH
                if(_UseRim)
            #endif
            {
                float4 rimColor = _RimColor;
                if(Exists_RimColorTex) rimColor *= LIL_SAMPLE_2D(_RimColorTex, sampler_MainTex, uvMain);
                float rim = pow(saturate(1.0 - nvabs), _RimFresnelPower);
                rim = lilTooning(rim, _RimBorder, _RimBlur);
                #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
                    if(_RimApplyTransparency) rim *= col.a;
                #endif
                #ifndef LIL_PASS_FORWARDADD
                    if(_RimShadowMask) rim *= shadowmix;
                    rimColor.rgb = lerp(rimColor.rgb, rimColor.rgb * lightColor, _RimEnableLighting);
                    col.rgb += rim * rimColor.a * rimColor.rgb;
                #else
                    col.rgb += rim * _RimEnableLighting * rimColor.a * rimColor.rgb * lightColor;
                #endif
            }
        #endif

        #ifndef LIL_PASS_FORWARDADD
            float3 invLighting = saturate((1.0 - lightColor) * sqrt(lightColor));
            //----------------------------------------------------------------------------------------------------------------------
            // Emission
            #if defined(LIL_FEATURE_EMISSION_1ST)
                LIL_BRANCH
                if(_UseEmission)
                {
                    float2 _EmissionMapParaTex = input.uv + _EmissionParallaxDepth * parallaxOffset;
                    float4 emissionColor = _EmissionColor;
                    // Texture
                    #if defined(LIL_FEATURE_EMISSION_UV) && defined(LIL_FEATURE_ANIMATE_EMISSION_UV)
                        if(Exists_EmissionMap) emissionColor *= LIL_GET_EMITEX(_EmissionMap, _EmissionMapParaTex);
                    #elif defined(LIL_FEATURE_EMISSION_UV)
                        if(Exists_EmissionMap) emissionColor *= LIL_SAMPLE_2D(_EmissionMap, sampler_EmissionMap, lilCalcUV(_EmissionMapParaTex, _EmissionMap_ST));
                    #else
                        if(Exists_EmissionMap) emissionColor *= LIL_SAMPLE_2D(_EmissionMap, sampler_EmissionMap, uvMain + _EmissionParallaxDepth * parallaxOffset);
                    #endif
                    // Mask
                    #if defined(LIL_FEATURE_EMISSION_MASK_UV) && defined(LIL_FEATURE_ANIMATE_EMISSION_MASK_UV)
                        if(Exists_EmissionBlendMask) emissionColor *= LIL_GET_EMIMASK(_EmissionBlendMask, input.uv);
                    #elif defined(LIL_FEATURE_EMISSION_MASK_UV)
                        if(Exists_EmissionBlendMask) emissionColor *= LIL_SAMPLE_2D(_EmissionBlendMask, sampler_MainTex, lilCalcUV(input.uv, _EmissionBlendMask_ST));
                    #else
                        if(Exists_EmissionBlendMask) emissionColor *= LIL_SAMPLE_2D(_EmissionBlendMask, sampler_MainTex, uvMain);
                    #endif
                    // Gradation
                    #if defined(LIL_FEATURE_EMISSION_GRADATION)
                        if(Exists_EmissionGradTex && _EmissionUseGrad) emissionColor *= LIL_SAMPLE_1D(_EmissionGradTex, sampler_linear_repeat, _EmissionGradSpeed*LIL_TIME);
                    #endif
                    #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
                        emissionColor.a *= col.a;
                    #endif
                    #if defined(LIL_FEATURE_AUDIOLINK)
                        if(_AudioLink2Emission) emissionColor.a *= audioLinkValue;
                    #endif
                    emissionColor.rgb = lerp(emissionColor.rgb, emissionColor.rgb * invLighting, _EmissionFluorescence);
                    col.rgb += _EmissionBlend * lilCalcBlink(_EmissionBlink) * emissionColor.a * emissionColor.rgb;
                }
            #endif

            // Emission2nd
            #if defined(LIL_FEATURE_EMISSION_2ND)
                LIL_BRANCH
                if(_UseEmission2nd)
                {
                    float2 _Emission2ndMapParaTex = input.uv + _Emission2ndParallaxDepth * parallaxOffset;
                    float4 emission2ndColor = _Emission2ndColor;
                    // Texture
                    #if defined(LIL_FEATURE_EMISSION_UV) && defined(LIL_FEATURE_ANIMATE_EMISSION_UV)
                        if(Exists_Emission2ndMap) emission2ndColor *= LIL_GET_EMITEX(_Emission2ndMap, _Emission2ndMapParaTex);
                    #elif defined(LIL_FEATURE_EMISSION_UV)
                        if(Exists_Emission2ndMap) emission2ndColor *= LIL_SAMPLE_2D(_Emission2ndMap, sampler_Emission2ndMap, lilCalcUV(_Emission2ndMapParaTex, _Emission2ndMap_ST));
                    #else
                        if(Exists_Emission2ndMap) emission2ndColor *= LIL_SAMPLE_2D(_Emission2ndMap, sampler_Emission2ndMap, uvMain + _Emission2ndParallaxDepth * parallaxOffset);
                    #endif
                    // Mask
                    #if defined(LIL_FEATURE_EMISSION_MASK_UV) && defined(LIL_FEATURE_ANIMATE_EMISSION_MASK_UV)
                        if(Exists_Emission2ndBlendMask) emission2ndColor *= LIL_GET_EMIMASK(_Emission2ndBlendMask, input.uv);
                    #elif defined(LIL_FEATURE_EMISSION_MASK_UV)
                        if(Exists_Emission2ndBlendMask) emission2ndColor *= LIL_SAMPLE_2D(_Emission2ndBlendMask, sampler_MainTex, lilCalcUV(input.uv, _Emission2ndBlendMask_ST));
                    #else
                        if(Exists_Emission2ndBlendMask) emission2ndColor *= LIL_SAMPLE_2D(_Emission2ndBlendMask, sampler_MainTex, uvMain);
                    #endif
                    // Gradation
                    #if defined(LIL_FEATURE_EMISSION_GRADATION)
                        if(Exists_Emission2ndGradTex && _Emission2ndUseGrad) emission2ndColor *= LIL_SAMPLE_1D(_Emission2ndGradTex, sampler_linear_repeat, _Emission2ndGradSpeed*LIL_TIME);
                    #endif
                    #if LIL_RENDER == 2 && !defined(LIL_REFRACTION)
                        emission2ndColor.a *= col.a;
                    #endif
                    #if defined(LIL_FEATURE_AUDIOLINK)
                        if(_AudioLink2Emission2nd) emission2ndColor.a *= audioLinkValue;
                    #endif
                    emission2ndColor.rgb = lerp(emission2ndColor.rgb, emission2ndColor.rgb * invLighting, _Emission2ndFluorescence);
                    col.rgb += _Emission2ndBlend * lilCalcBlink(_Emission2ndBlink) * emission2ndColor.a * emission2ndColor.rgb;
                }
            #endif

            // Dissolve
            #if defined(LIL_FEATURE_DISSOLVE) && LIL_RENDER != 0
                col.rgb += _DissolveColor.rgb * dissolveAlpha;
            #endif

            #if defined(LIL_FEATURE_LAYER_DISSOLVE)
                #if defined(LIL_FEATURE_MAIN2ND)
                    col.rgb += _Main2ndDissolveColor.rgb * main2ndDissolveAlpha;
                #endif
                #if defined(LIL_FEATURE_MAIN3RD)
                    col.rgb += _Main3rdDissolveColor.rgb * main3rdDissolveAlpha;
                #endif
            #endif
        #endif
    #endif

    //--------------------------------------------------------------------------------------------------------------------------
    // Distance Fade
    #if defined(LIL_FEATURE_DISTANCE_FADE)
        float depth = length(LIL_GET_VIEWDIR_WS(input.positionWS.xyz));
        float distFade = saturate((depth - _DistanceFade.x) / (_DistanceFade.y - _DistanceFade.x)) * _DistanceFade.z;
        #if defined(LIL_PASS_FORWARDADD)
            col.rgb = lerp(col.rgb, 0.0, distFade);
        #elif LIL_RENDER == 2
            col.rgb = lerp(col.rgb, _DistanceFadeColor.rgb, distFade);
            col.a = lerp(col.a, col.a * _DistanceFadeColor.a, distFade);
        #else
            col.rgb = lerp(col.rgb, _DistanceFadeColor.rgb, distFade);
        #endif
    #endif

    //--------------------------------------------------------------------------------------------------------------------------
    // Fog
    LIL_APPLY_FOG(col, input.fogCoord);

    return col;
}

#endif