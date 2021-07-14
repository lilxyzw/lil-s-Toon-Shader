Shader "Hidden/lilToonRefractionBlur"
{
    Properties
    {
        //----------------------------------------------------------------------------------------------------------------------
        // Base
        [lilToggle]     _Invisible                  ("Invisible", Int) = 0
                        _AsUnlit                    ("As Unlit", Range(0, 1)) = 0
                        _Cutoff                     ("Alpha Cutoff", Range(0,1)) = 0.5
        [lilToggle]     _FlipNormal                 ("Flip Backface Normal", Int) = 0
                        _BackfaceForceShadow        ("Backface Force Shadow", Range(0,1)) = 0
                        _VertexLightStrength        ("Vertex Light Strength", Range(0,1)) = 1

        //----------------------------------------------------------------------------------------------------------------------
        // Main
                        _Color                      ("Color", Color) = (1,1,1,1)
                        _MainTex                    ("Texture", 2D) = "white" {}
        [lilUVAnim]     _MainTex_ScrollRotate       ("Angle|UV Animation|Scroll|Rotate", Vector) = (0,0,0,0)
        [lilHSVG]       _MainTexHSVG                ("Hue|Saturation|Value|Gamma", Vector) = (0,1,1,1)
                        _MainGradationStrength      ("Gradation Strength", Range(0, 1)) = 0
        [NoScaleOffset] _MainGradationTex           ("Gradation Map", 2D) = "white" {}

        //----------------------------------------------------------------------------------------------------------------------
        // Main2nd
        [lilToggleLeft] _UseMain2ndTex              ("Use Main 2nd", Int) = 0
        [lilHDR]        _Color2nd                   ("Color", Color) = (1,1,1,1)
                        _Main2ndTex                 ("Texture", 2D) = "white" {}
        [lilAngle]      _Main2ndTexAngle            ("Angle", Float) = 0
        [lilDecalAnim]  _Main2ndTexDecalAnimation   ("Animation|X Size|Y Size|Frames|FPS", Vector) = (1,1,1,30)
        [lilDecalSub]   _Main2ndTexDecalSubParam    ("Ratio X|Ratio Y|Fix Border", Vector) = (1,1,0,1)
        [lilToggle]     _Main2ndTexIsDecal          ("As Decal", Int) = 0
        [lilToggle]     _Main2ndTexIsLeftOnly       ("Left Only", Int) = 0
        [lilToggle]     _Main2ndTexIsRightOnly      ("Right Only", Int) = 0
        [lilToggle]     _Main2ndTexShouldCopy       ("Copy", Int) = 0
        [lilToggle]     _Main2ndTexShouldFlipMirror ("Flip Mirror", Int) = 0
        [lilToggle]     _Main2ndTexShouldFlipCopy   ("Flip Copy", Int) = 0
        [lilToggle]     _Main2ndTexIsMSDF           ("As MSDF", Int) = 0
        [NoScaleOffset] _Main2ndBlendMask           ("Mask", 2D) = "white" {}
        [lilEnum]       _Main2ndTexBlendMode        ("Blend Mode|Normal|Add|Screen|Multiply", Int) = 0
                        _Main2ndEnableLighting      ("Enable Lighting", Range(0, 1)) = 1
                        _Main2ndDissolveMask        ("Dissolve Mask", 2D) = "white" {}
                        _Main2ndDissolveNoiseMask   ("Dissolve Noise Mask", 2D) = "gray" {}
        [lilUVAnim]     _Main2ndDissolveNoiseMask_ScrollRotate ("Scroll", Vector) = (0,0,0,0)
                        _Main2ndDissolveNoiseStrength ("Dissolve Noise Strength", float) = 0.1
        [lilHDR]        _Main2ndDissolveColor       ("Dissolve Color", Color) = (1,1,1,1)
        [lilDissolve]   _Main2ndDissolveParams      ("Dissolve Mode|None|Alpha|UV|Position|Dissolve Shape|Point|Line|Border|Blur", Vector) = (0,0,0.5,0.1)
        [lilDissolveP]  _Main2ndDissolvePos         ("Dissolve Position", Vector) = (0,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Main3rd
        [lilToggleLeft] _UseMain3rdTex              ("Use Main 3rd", Int) = 0
        [lilHDR]        _Color3rd                   ("Color", Color) = (1,1,1,1)
                        _Main3rdTex                 ("Texture", 2D) = "white" {}
        [lilAngle]      _Main3rdTexAngle            ("Angle", Float) = 0
        [lilDecalAnim]  _Main3rdTexDecalAnimation   ("Animation|X Size|Y Size|Frames|FPS", Vector) = (1,1,1,30)
        [lilDecalSub]   _Main3rdTexDecalSubParam    ("Ratio X|Ratio Y|Fix Border", Vector) = (1,1,0,1)
        [lilToggle]     _Main3rdTexIsDecal          ("As Decal", Int) = 0
        [lilToggle]     _Main3rdTexIsLeftOnly       ("Left Only", Int) = 0
        [lilToggle]     _Main3rdTexIsRightOnly      ("Right Only", Int) = 0
        [lilToggle]     _Main3rdTexShouldCopy       ("Copy", Int) = 0
        [lilToggle]     _Main3rdTexShouldFlipMirror ("Flip Mirror", Int) = 0
        [lilToggle]     _Main3rdTexShouldFlipCopy   ("Flip Copy", Int) = 0
        [lilToggle]     _Main3rdTexIsMSDF           ("As MSDF", Int) = 0
        [NoScaleOffset] _Main3rdBlendMask           ("Mask", 2D) = "white" {}
        [lilEnum]       _Main3rdTexBlendMode        ("Blend Mode|Normal|Add|Screen|Multiply", Int) = 0
                        _Main3rdEnableLighting      ("Enable Lighting", Range(0, 1)) = 1
                        _Main3rdDissolveMask        ("Dissolve Mask", 2D) = "white" {}
                        _Main3rdDissolveNoiseMask   ("Dissolve Noise Mask", 2D) = "gray" {}
        [lilUVAnim]     _Main3rdDissolveNoiseMask_ScrollRotate ("Scroll", Vector) = (0,0,0,0)
                        _Main3rdDissolveNoiseStrength ("Dissolve Noise Strength", float) = 0.1
        [lilHDR]        _Main3rdDissolveColor       ("Dissolve Color", Color) = (1,1,1,1)
        [lilDissolve]   _Main3rdDissolveParams      ("Dissolve Mode|None|Alpha|UV|Position|Dissolve Shape|Point|Line|Border|Blur", Vector) = (0,0,0.5,0.1)
        [lilDissolveP]  _Main3rdDissolvePos         ("Dissolve Position", Vector) = (0,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Alpha Mask
        [lilEnumLabel]  _AlphaMaskMode              ("AlphaMask|", Int) = 0
        [NoScaleOffset] _AlphaMask                  ("AlphaMask", 2D) = "white" {}
                        _AlphaMaskValue             ("AlphaMaskValue", Range(-1,1)) = 0

        //----------------------------------------------------------------------------------------------------------------------
        // NormalMap
        [lilToggleLeft] _UseBumpMap                 ("Use Normal Map", Int) = 0
        [Normal]        _BumpMap                    ("Normal Map", 2D) = "bump" {}
                        _BumpScale                  ("Scale", Range(-10,10)) = 1

        //----------------------------------------------------------------------------------------------------------------------
        // NormalMap 2nd
        [lilToggleLeft] _UseBump2ndMap              ("Use Normal Map 2nd", Int) = 0
        [Normal]        _Bump2ndMap                 ("Normal Map", 2D) = "bump" {}
                        _Bump2ndScale               ("Scale", Range(-10,10)) = 1
        [NoScaleOffset] _Bump2ndScaleMask           ("Mask", 2D) = "white" {}

        //----------------------------------------------------------------------------------------------------------------------
        // Shadow
        [lilToggleLeft] _UseShadow                  ("Use Shadow", Int) = 0
        [lilToggle]     _ShadowReceive              ("Receive Shadow", Int) = 0
                        _ShadowBorder               ("Border", Range(0, 1)) = 0.5
        [NoScaleOffset] _ShadowBorderMask           ("Border", 2D) = "white" {}
                        _ShadowBlur                 ("Blur", Range(0, 1)) = 0.1
        [NoScaleOffset] _ShadowBlurMask             ("Blur", 2D) = "white" {}
                        _ShadowStrength             ("Strength", Range(0, 1)) = 1
        [NoScaleOffset] _ShadowStrengthMask         ("Strength", 2D) = "white" {}
                        _ShadowColor                ("Shadow Color", Color) = (0.7,0.75,0.85,1.0)
        [NoScaleOffset] _ShadowColorTex             ("Shadow Color", 2D) = "black" {}
                        _Shadow2ndBorder            ("2nd Border", Range(0, 1)) = 0.5
                        _Shadow2ndBlur              ("2nd Blur", Range(0, 1)) = 0.3
                        _Shadow2ndColor             ("Shadow 2nd Color", Color) = (0,0,0,0)
        [NoScaleOffset] _Shadow2ndColorTex          ("Shadow 2nd Color", 2D) = "black" {}
                        _ShadowMainStrength         ("Main Color Strength", Range(0, 1)) = 1
                        _ShadowEnvStrength          ("Environment Strength", Range(0, 1)) = 1
                        _ShadowBorderColor          ("Border Color", Color) = (1,0,0,1)
                        _ShadowBorderRange          ("Border Range", Range(0, 1)) = 0

        //----------------------------------------------------------------------------------------------------------------------
        // Reflection
        [lilToggleLeft] _UseReflection              ("Use Reflection", Int) = 0
        // Smoothness
                        _Smoothness                 ("Smoothness", Range(0, 1)) = 1
        [NoScaleOffset] _SmoothnessTex              ("Smoothness", 2D) = "white" {}
        // Metallic
        [Gamma]         _Metallic                   ("Metallic", Range(0, 1)) = 0
        [NoScaleOffset] _MetallicGlossMap           ("Metallic", 2D) = "white" {}
        // Reflectance
        [Gamma]         _Reflectance                ("Reflectance", Range(0, 1)) = 0.04
        // Reflection
        [lilToggle]     _ApplySpecular              ("Apply Specular", Int) = 1
        [lilToggle]     _SpecularToon               ("Specular Toon", Int) = 1
        [lilToggle]     _ApplyReflection            ("Apply Reflection", Int) = 0
                        _ReflectionColor            ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _ReflectionColorTex         ("Color", 2D) = "white" {}
        [lilToggle]     _ReflectionApplyTransparency ("Apply Transparency", Int) = 1

        //----------------------------------------------------------------------------------------------------------------------
        // MatCap
        [lilToggleLeft] _UseMatCap                  ("Use MatCap", Int) = 0
        [lilHDR]        _MatCapColor                ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _MatCapTex                  ("Texture", 2D) = "white" {}
                        _MatCapBlend                ("Blend", Range(0, 1)) = 1
        [NoScaleOffset] _MatCapBlendMask            ("Mask", 2D) = "white" {}
                        _MatCapEnableLighting       ("Enable Lighting", Range(0, 1)) = 1
        [lilEnum]       _MatCapBlendMode            ("Blend Mode|Normal|Add|Screen|Multiply", Int) = 1
        [lilToggle]     _MatCapApplyTransparency    ("Apply Transparency", Int) = 1

        //----------------------------------------------------------------------------------------------------------------------
        // Rim
        [lilToggleLeft] _UseRim                     ("Use Rim", Int) = 0
        [lilHDR]        _RimColor                   ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _RimColorTex                ("Texture", 2D) = "white" {}
                        _RimBorder                  ("Border", Range(0, 1)) = 0.5
                        _RimBlur                    ("Blur", Range(0, 1)) = 0.1
        [PowerSlider(3.0)]_RimFresnelPower          ("Fresnel Power", Range(0.01, 50)) = 3.0
                        _RimEnableLighting          ("Enable Lighting", Range(0, 1)) = 1
        [lilToggle]     _RimShadowMask              ("Shadow Mask", Int) = 0
        [lilToggle]     _RimApplyTransparency       ("Apply Transparency", Int) = 1

        //----------------------------------------------------------------------------------------------------------------------
        // Emmision
        [lilToggleLeft] _UseEmission                ("Use Emission", Int) = 0
        [HDR]           _EmissionColor              ("Color", Color) = (1,1,1)
                        _EmissionMap                ("Texture", 2D) = "white" {}
        [lilUVAnim]     _EmissionMap_ScrollRotate   ("Angle|UV Animation|Scroll|Rotate", Vector) = (0,0,0,0)
                        _EmissionBlend              ("Blend", Range(0,1)) = 1
                        _EmissionBlendMask          ("Mask", 2D) = "white" {}
        [lilUVAnim]     _EmissionBlendMask_ScrollRotate ("Angle|UV Animation|Scroll|Rotate", Vector) = (0,0,0,0)
        [lilBlink]      _EmissionBlink              ("Blink Strength|Blink Type|Blink Speed|Blink Offset", Vector) = (0,0,3.141593,0)
        [lilToggle]     _EmissionUseGrad            ("Use Gradation", Int) = 0
        [NoScaleOffset] _EmissionGradTex            ("Gradation Texture", 2D) = "white" {}
                        _EmissionGradSpeed          ("Gradation Speed", Float) = 1
                        _EmissionParallaxDepth      ("Parallax Depth", float) = 0
                        _EmissionFluorescence       ("Fluorescence", Range(0,1)) = 0
        // Gradation
        [HideInInspector] _egci ("", Int) = 2
        [HideInInspector] _egai ("", Int) = 2
        [HideInInspector] _egc0 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc1 ("", Color) = (1,1,1,1)
        [HideInInspector] _egc2 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc3 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc4 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc5 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc6 ("", Color) = (1,1,1,0)
        [HideInInspector] _egc7 ("", Color) = (1,1,1,0)
        [HideInInspector] _ega0 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega1 ("", Color) = (1,0,0,1)
        [HideInInspector] _ega2 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega3 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega4 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega5 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega6 ("", Color) = (1,0,0,0)
        [HideInInspector] _ega7 ("", Color) = (1,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Emmision2nd
        [lilToggleLeft] _UseEmission2nd             ("Use Emission 2nd", Int) = 0
        [HDR]           _Emission2ndColor           ("Color", Color) = (1,1,1)
                        _Emission2ndMap             ("Texture", 2D) = "white" {}
        [lilUVAnim]     _Emission2ndMap_ScrollRotate ("Angle|UV Animation|Scroll|Rotate", Vector) = (0,0,0,0)
                        _Emission2ndBlend           ("Blend", Range(0,1)) = 1
                        _Emission2ndBlendMask       ("Mask", 2D) = "white" {}
        [lilUVAnim]     _Emission2ndBlendMask_ScrollRotate ("Angle|UV Animation|Scroll|Rotate", Vector) = (0,0,0,0)
        [lilBlink]      _Emission2ndBlink           ("Blink Strength|Blink Type|Blink Speed|Blink Offset", Vector) = (0,0,3.141593,0)
        [lilToggle]     _Emission2ndUseGrad         ("Use Gradation", Int) = 0
        [NoScaleOffset] _Emission2ndGradTex         ("Gradation Texture", 2D) = "white" {}
                        _Emission2ndGradSpeed       ("Gradation Speed", Float) = 1
                        _Emission2ndParallaxDepth   ("Parallax Depth", float) = 0
                        _Emission2ndFluorescence    ("Fluorescence", Range(0,1)) = 0
        // Gradation
        [HideInInspector] _e2gci ("", Int) = 2
        [HideInInspector] _e2gai ("", Int) = 2
        [HideInInspector] _e2gc0 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc1 ("", Color) = (1,1,1,1)
        [HideInInspector] _e2gc2 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc3 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc4 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc5 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc6 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2gc7 ("", Color) = (1,1,1,0)
        [HideInInspector] _e2ga0 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga1 ("", Color) = (1,0,0,1)
        [HideInInspector] _e2ga2 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga3 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga4 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga5 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga6 ("", Color) = (1,0,0,0)
        [HideInInspector] _e2ga7 ("", Color) = (1,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Parallax
        [lilToggleLeft] _UseParallax                ("Use Parallax", Int) = 0
        [NoScaleOffset] _ParallaxMap                ("Parallax Map", 2D) = "gray" {}
                        _Parallax                   ("Parallax Scale", float) = 0.02
                        _ParallaxOffset             ("Parallax Offset", float) = 0.5

        //----------------------------------------------------------------------------------------------------------------------
        // Distance Fade
        [lilHDR]        _DistanceFadeColor          ("Color", Color) = (0,0,0,1)
        [lil3Param]     _DistanceFade               ("Start|End|Strength", Vector) = (0.1,0.01,1,0)

        //----------------------------------------------------------------------------------------------------------------------
        // AudioLink
        [lilToggleLeft] _UseAudioLink               ("Use AudioLink", Int) = 0
        [lilALUVMode]   _AudioLinkUVMode            ("UV Mode|None|Rim|UV|Mask", Int) = 1
        [lilALUVParams] _AudioLinkUVParams          ("Scale|Offset|Angle|Band|Bass|Low Mid|High Mid|Treble", Vector) = (0.25,0,0,0.125)
        [NoScaleOffset] _AudioLinkMask              ("Mask", 2D) = "blue" {}
        [lilToggle]     _AudioLink2Main2nd          ("Main 2nd", Int) = 0
        [lilToggle]     _AudioLink2Main3rd          ("Main 3rd", Int) = 0
        [lilToggle]     _AudioLink2Emission         ("Emission", Int) = 0
        [lilToggle]     _AudioLink2Emission2nd      ("Emission 2nd", Int) = 0
        [lilToggle]     _AudioLink2Vertex           ("Vertex", Int) = 0
        [lilALUVMode]   _AudioLinkVertexUVMode      ("UV Mode|None|Position|UV|Mask", Int) = 1
        [lilALUVParams] _AudioLinkVertexUVParams    ("Scale|Offset|Angle|Band|Bass|Low Mid|High Mid|Treble", Vector) = (0.25,0,0,0.125)
        [lilVec3]       _AudioLinkVertexStart       ("Start Position", Vector) = (0.0,0.0,0.0,0.0)
        [lilVec3Float]  _AudioLinkVertexStrength    ("Moving Vector|Normal Strength", Vector) = (0.0,0.0,0.0,1.0)
        [lilToggle]     _AudioLinkAsLocal           ("As Local", Int) = 0
        [NoScaleOffset] _AudioLinkLocalMap          ("Local Map", 2D) = "black" {}
        [lilALLocal]    _AudioLinkLocalMapParams    ("BPM|Notes|Offset", Vector) = (120,1,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Dissolve
                        _DissolveMask               ("Dissolve Mask", 2D) = "white" {}
                        _DissolveNoiseMask          ("Dissolve Noise Mask", 2D) = "gray" {}
        [lilUVAnim]     _DissolveNoiseMask_ScrollRotate ("Scroll", Vector) = (0,0,0,0)
                        _DissolveNoiseStrength      ("Dissolve Noise Strength", float) = 0.1
        [lilHDR]        _DissolveColor              ("Dissolve Color", Color) = (1,1,1,1)
        [lilDissolve]   _DissolveParams             ("Dissolve Mode|None|Alpha|UV|Position|Dissolve Shape|Point|Line|Border|Blur", Vector) = (0,0,0.5,0.1)
        [lilDissolveP]  _DissolvePos                ("Dissolve Position", Vector) = (0,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Encryption
        [lilToggle]     _IgnoreEncryption           ("Ignore Encryption", Int) = 0
                        _Keys                       ("Keys", Vector) = (0,0,0,0)

        //----------------------------------------------------------------------------------------------------------------------
        // Advanced
        [lilEnum]                                       _Cull               ("Cull Mode|Off|Front|Back", Int) = 2
        [Enum(UnityEngine.Rendering.BlendMode)]         _SrcBlend           ("SrcBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]         _DstBlend           ("DstBlend", Int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]         _SrcBlendAlpha      ("SrcBlendAlpha", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]         _DstBlendAlpha      ("DstBlendAlpha", Int) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]           _BlendOp            ("BlendOp", Int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]           _BlendOpAlpha       ("BlendOpAlpha", Int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]         _SrcBlendFA         ("ForwardAdd SrcBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]         _DstBlendFA         ("ForwardAdd DstBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]         _SrcBlendAlphaFA    ("ForwardAdd SrcBlendAlpha", Int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]         _DstBlendAlphaFA    ("ForwardAdd DstBlendAlpha", Int) = 1
        [Enum(UnityEngine.Rendering.BlendOp)]           _BlendOpFA          ("ForwardAdd BlendOp", Int) = 4
        [Enum(UnityEngine.Rendering.BlendOp)]           _BlendOpAlphaFA     ("ForwardAdd BlendOpAlpha", Int) = 4
        [lilToggle]                                     _ZWrite             ("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]   _ZTest              ("ZTest", Int) = 4
        [IntRange]                                      _StencilRef         ("Stencil Reference Value", Range(0, 255)) = 0
        [IntRange]                                      _StencilReadMask    ("Stencil ReadMask Value", Range(0, 255)) = 255
        [IntRange]                                      _StencilWriteMask   ("Stencil WriteMask Value", Range(0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]   _StencilComp        ("Stencil Compare Function", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)]         _StencilPass        ("Stencil Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]         _StencilFail        ("Stencil Fail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]         _StencilZFail       ("Stencil ZFail", Float) = 0
                                                        _OffsetFactor       ("Offset Factor", Float) = 0
                                                        _OffsetUnits        ("Offset Units", Float) = 0
        [lilColorMask]                                  _ColorMask          ("Color Mask", Int) = 15

        //----------------------------------------------------------------------------------------------------------------------
        // Refraction
                        _RefractionStrength         ("Strength", Range(0,1)) = 0.1
        [PowerSlider(3.0)]_RefractionFresnelPower   ("Fresnel Power", Range(0.01, 10)) = 0.5
        [lilToggle]     _RefractionColorFromMain    ("RefractionColorFromMain", Int) = 0
                        _RefractionColor            ("Color", Color) = (1,1,1,1)
    }
    HLSLINCLUDE
        #define LIL_RENDER 2
        #define LIL_REFRACTION
        #define LIL_REFRACTION_BLUR2
    ENDHLSL

//----------------------------------------------------------------------------------------------------------------------
// BRP Start
//
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent"}

        // GrabPass
        GrabPass {"_BackgroundTexture"}

        // Forward Blur
        Pass
        {
            Name "FORWARD_BLUR"
            Tags {"LightMode" = "ForwardBase"}

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
            Blend One Zero
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest

            //------------------------------------------------------------------------------------------------------------------------------
            // Shader
            #include "Includes/lil_pass_refblur.hlsl"

            ENDHLSL
        }

        // GrabPass
        GrabPass {"_BackgroundTexture2"}

        // Forward
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode" = "ForwardBase"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            BlendOp [_BlendOp], [_BlendOpAlpha]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest

            // Skip receiving shadow
            #pragma skip_variants SHADOWS_SCREEN

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        // ForwardAdd
        Pass
        {
            Name "FORWARD_ADD"
            Tags {"LightMode" = "ForwardAdd"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
			ZWrite Off
            ZTest LEqual
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            Blend [_SrcBlendFA] [_DstBlendFA], Zero One
            BlendOp [_BlendOpFA], [_BlendOpAlphaFA]
            Fog { Color(0,0,0,0) }

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #define LIL_PASS_FORWARDADD
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        UsePass "Hidden/ltspass_transparent/SHADOW_CASTER"
        UsePass "Hidden/ltspass_transparent/META"
    }
//
// BRP End

//----------------------------------------------------------------------------------------------------------------------
// LWRP Start
/*
    //------------------------------------------------------------------------------------------------------------------
    // Lightweight Render Pipeline SM4.5
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent" "ShaderModel" = "4.5"}

        // GrabPass
        GrabPass {"_BackgroundTexture"}

        // Blur
        Pass
        {
            Name "FORWARD_BLUR"
            Tags {"LightMode" = "SRPDefaultUnlit"}

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
            Blend One Zero
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            //------------------------------------------------------------------------------------------------------------------------------
            // Shader
            #include "Includes/lil_pass_refblur.hlsl"

            ENDHLSL
        }

        // GrabPass
        GrabPass {"_BackgroundTexture2"}

        // Forward
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode" = "LightweightForward"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            BlendOp [_BlendOp], [_BlendOpAlpha]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // Skip receiving shadow
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        UsePass "Hidden/ltspass_transparent/SHADOW_CASTER"
        UsePass "Hidden/ltspass_transparent/DEPTHONLY"
        UsePass "Hidden/ltspass_transparent/META"
    }

    //------------------------------------------------------------------------------------------------------------------
    // Lightweight Render Pipeline
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent"}

        // GrabPass
        GrabPass {"_BackgroundTexture"}

        // Blur
        Pass
        {
            Name "FORWARD_BLUR"
            Tags {"LightMode" = "SRPDefaultUnlit"}

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
            Blend One Zero
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing

            //------------------------------------------------------------------------------------------------------------------------------
            // Shader
            #include "Includes/lil_pass_refblur.hlsl"

            ENDHLSL
        }

        // GrabPass
        GrabPass {"_BackgroundTexture2"}

        // Forward
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode" = "LightweightForward"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            BlendOp [_BlendOp], [_BlendOpAlpha]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            // Skip receiving shadow
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        UsePass "Hidden/ltspass_transparent/SHADOW_CASTER"
        UsePass "Hidden/ltspass_transparent/DEPTHONLY"
        UsePass "Hidden/ltspass_transparent/META"
    }
*/
// LWRP End

//----------------------------------------------------------------------------------------------------------------------
// URP Start
/*
    //------------------------------------------------------------------------------------------------------------------
    // Universal Render Pipeline SM4.5
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent" "ShaderModel" = "4.5"}

        // GrabPass
        GrabPass {"_BackgroundTexture"}

        // Blur
        Pass
        {
            Name "FORWARD_BLUR"
            Tags {"LightMode" = "SRPDefaultUnlit"}

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
            Blend One Zero
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            //------------------------------------------------------------------------------------------------------------------------------
            // Shader
            #include "Includes/lil_pass_refblur.hlsl"

            ENDHLSL
        }

        // GrabPass
        GrabPass {"_BackgroundTexture2"}

        // Forward
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode" = "UniversalForward"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            BlendOp [_BlendOp], [_BlendOpAlpha]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // Skip receiving shadow
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        UsePass "Hidden/ltspass_transparent/SHADOW_CASTER"
        UsePass "Hidden/ltspass_transparent/DEPTHONLY"
        UsePass "Hidden/ltspass_transparent/DEPTHNORMALS"
        UsePass "Hidden/ltspass_transparent/UNIVERSAL2D"
        UsePass "Hidden/ltspass_transparent/META"
    }

    //------------------------------------------------------------------------------------------------------------------
    // Universal Render Pipeline
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Transparent"}

        // GrabPass
        GrabPass {"_BackgroundTexture"}

        // Blur
        Pass
        {
            Name "FORWARD_BLUR"
            Tags {"LightMode" = "SRPDefaultUnlit"}

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
		    Cull [_Cull]
            Blend One Zero
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing

            //------------------------------------------------------------------------------------------------------------------------------
            // Shader
            #include "Includes/lil_pass_refblur.hlsl"

            ENDHLSL
        }

        // GrabPass
        GrabPass {"_BackgroundTexture2"}

        // Forward
        Pass
        {
            Name "FORWARD"
            Tags {"LightMode" = "UniversalForward"}

            Stencil
            {
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]
            Offset [_OffsetFactor], [_OffsetUnits]
            BlendOp [_BlendOp], [_BlendOpAlpha]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM

            //------------------------------------------------------------------------------------------------------------------
            // Build Option
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            // Skip receiving shadow
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            //------------------------------------------------------------------------------------------------------------------
            // Pass
            #include "Includes/lil_pass_normal.hlsl"

            ENDHLSL
        }

        UsePass "Hidden/ltspass_transparent/SHADOW_CASTER"
        UsePass "Hidden/ltspass_transparent/DEPTHONLY"
        UsePass "Hidden/ltspass_transparent/DEPTHNORMALS"
        UsePass "Hidden/ltspass_transparent/UNIVERSAL2D"
        UsePass "Hidden/ltspass_transparent/META"
    }
*/
// URP End

    Fallback "Unlit/Texture"
    CustomEditor "lilToon.lilToonInspector"
}
