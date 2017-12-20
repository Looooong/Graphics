#ifndef SHADOW_HLSL
#define SHADOW_HLSL

//
// Shadow master include header.
//
// There are four relevant files for shadows.
// First ShadowContext.hlsl provides a macro SHADOWCONTEXT_DECLARE that must be used in order to define the specific ShadowContext struct and accompanying loader.
// ShadowContext loading and resource setup from C# must be in sync.
//

/* Required defines: (define these to the desired numbers - must be in sync with loading and resource setup from C#)
#define SHADOWCONTEXT_MAX_TEX2DARRAY   0
#define SHADOWCONTEXT_MAX_TEXCUBEARRAY 0
#define SHADOWCONTEXT_MAX_SAMPLER      0
#define SHADOWCONTEXT_MAX_COMPSAMPLER  0
*/

/* Default values for optional defines:
#define SHADOW_SUPPORTS_DYNAMIC_INDEXING 0        // Dynamic indexing only works on >= sm 5.1
#define SHADOW_OPTIMIZE_REGISTER_USAGE   0        // Redefine this as 1 in your ShadowContext.hlsl to optimize for register usage over instruction count
// #define SHADOW_DISPATCH_USE_CUSTOM_PUNCTUAL    // Enable custom implementations of GetPunctualShadowAttenuation. If not defined, a default implementation will be used.
// #define SHADOW_DISPATCH_USE_CUSTOM_DIRECTIONAL // Enable custom implementations of GetDirectionalShadowAttenuation. If not defined, a default implementation will be used.
*/

#ifndef SHADOW_SUPPORTS_DYNAMIC_INDEXING
    #define SHADOW_SUPPORTS_DYNAMIC_INDEXING 0
#endif
#ifndef SHADOW_OPTIMIZE_REGISTER_USAGE
    #define SHADOW_OPTIMIZE_REGISTER_USAGE   0
#endif

#include "Shadow/ShadowBase.cs.hlsl"	// ShadowData definition, auto generated (don't modify)
#include "ShadowTexFetch.hlsl"						// Resource sampling definitions (don't modify)

struct ShadowContext
{
    StructuredBuffer<ShadowData>	shadowDatas;
    StructuredBuffer<int4>			payloads;
    SHADOWCONTEXT_DECLARE_TEXTURES( SHADOWCONTEXT_MAX_TEX2DARRAY, SHADOWCONTEXT_MAX_TEXCUBEARRAY, SHADOWCONTEXT_MAX_COMPSAMPLER, SHADOWCONTEXT_MAX_SAMPLER )
};

SHADOW_DEFINE_SAMPLING_FUNCS( SHADOWCONTEXT_MAX_TEX2DARRAY, SHADOWCONTEXT_MAX_TEXCUBEARRAY, SHADOWCONTEXT_MAX_COMPSAMPLER, SHADOWCONTEXT_MAX_SAMPLER )

// helper function to extract shadowmap data from the ShadowData struct
void UnpackShadowmapId( uint shadowmapId, out uint texIdx, out uint sampIdx, out REAL slice )
{
	texIdx  = (shadowmapId >> 24) & 0xff;
	sampIdx = (shadowmapId >> 16) & 0xff;
	slice   = (REAL)(shadowmapId & 0xffff);
}
void UnpackShadowmapId( uint shadowmapId, out uint texIdx, out uint sampIdx )
{
	texIdx  = (shadowmapId >> 24) & 0xff;
	sampIdx = (shadowmapId >> 16) & 0xff;
}
void UnpackShadowmapId( uint shadowmapId, out REAL slice )
{
	slice = (REAL)(shadowmapId & 0xffff);
}

void UnpackShadowType( uint packedShadowType, out uint shadowType, out uint shadowAlgorithm )
{
	shadowType		= packedShadowType >> 10;
	shadowAlgorithm = packedShadowType & 0x1ff;
}

void UnpackShadowType( uint packedShadowType, out uint shadowType )
{
	shadowType = packedShadowType >> 10;
}

// shadow sampling prototypes
REAL GetPunctualShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL4 L );
REAL GetPunctualShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL4 L, REAL2 positionSS );

// shadow sampling prototypes with screenspace info
REAL GetDirectionalShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL3 L );
REAL GetDirectionalShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL3 L, REAL2 positionSS );

#include "ShadowSampling.hlsl"			// sampling patterns (don't modify)
#include "ShadowAlgorithms.hlsl"		// engine default algorithms (don't modify)

#ifndef SHADOW_DISPATCH_USE_CUSTOM_PUNCTUAL
REAL GetPunctualShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL4 L )
{
    return EvalShadow_PunctualDepth(shadowContext, positionWS, normalWS, shadowDataIndex, L);
}

REAL GetPunctualShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL4 L, REAL2 positionSS )
{
    return GetPunctualShadowAttenuation( shadowContext, positionWS, normalWS, shadowDataIndex, L );
}
#endif

#ifndef SHADOW_DISPATCH_USE_CUSTOM_DIRECTIONAL
REAL GetDirectionalShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL3 L )
{
    return EvalShadow_CascadedDepth_Blend( shadowContext, positionWS, normalWS, shadowDataIndex, L );
}

REAL GetDirectionalShadowAttenuation( ShadowContext shadowContext, REAL3 positionWS, REAL3 normalWS, int shadowDataIndex, REAL3 L, REAL2 positionSS )
{
    return GetDirectionalShadowAttenuation( shadowContext, positionWS, normalWS, shadowDataIndex, L );
}
#endif

#endif // SHADOW_HLSL
