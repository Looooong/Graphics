#ifndef UNITY_NOISE_INCLUDED
#define UNITY_NOISE_INCLUDED

#if !defined(SHADER_API_GLES)

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
uint JenkinsHash(uint x)
{
    x += (x << 10u);
    x ^= (x >>  6u);
    x += (x <<  3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

// Compound versions of the hashing algorithm.
uint JenkinsHash(uint2 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.y));
}

uint JenkinsHash(uint3 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.y) ^ JenkinsHash(v.z));
}

uint JenkinsHash(uint4 v)
{
    return JenkinsHash(v.x ^ JenkinsHash(v.y) ^ JenkinsHash(v.z) ^ JenkinsHash(v.w));
}

// Construct a REAL with REAL-open range [0, 1) using low 23 bits.
// All zeros yields 0, all ones yields the next smallest representable value below 1.
REAL ConstructFloat(int m) {
    const int ieeeMantissa = 0x007FFFFF; // Binary FP32 mantissa bitmask
    const int ieeeOne      = 0x3F800000; // 1.0 in FP32 IEEE

    m &= ieeeMantissa;                   // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                        // Add fractional part to 1.0

    REAL  f = asfloat(m);               // Range [1, 2)
    return f - 1;                        // Range [0, 1)
}

REAL ConstructFloat(uint m)
{
    return ConstructFloat(asint(m));
}

// Pseudo-random value in REAL-open range [0, 1). The distribution is reasonably uniform.
// Ref: https://stackoverflow.com/a/17479300
REAL GenerateHashedRandomFloat(uint x)
{
    return ConstructFloat(JenkinsHash(x));
}

REAL GenerateHashedRandomFloat(uint2 v)
{
    return ConstructFloat(JenkinsHash(v));
}

REAL GenerateHashedRandomFloat(uint3 v)
{
    return ConstructFloat(JenkinsHash(v));
}

REAL GenerateHashedRandomFloat(uint4 v)
{
    return ConstructFloat(JenkinsHash(v));
}

#endif // SHADER_API_GLES

#endif // UNITY_NOISE_INCLUDED
