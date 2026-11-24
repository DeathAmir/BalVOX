#ifndef BALVOX_PROCEDURAL_SURFACE_HLSLI
#define BALVOX_PROCEDURAL_SURFACE_HLSLI

float BalVoxHash31(float3 p)
{
    p = frac(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return frac((p.x + p.y) * p.z);
}

float BalVoxNoise3D(float3 p)
{
    float3 cell = floor(p);
    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);

    float n000 = BalVoxHash31(cell + float3(0, 0, 0));
    float n100 = BalVoxHash31(cell + float3(1, 0, 0));
    float n010 = BalVoxHash31(cell + float3(0, 1, 0));
    float n110 = BalVoxHash31(cell + float3(1, 1, 0));
    float n001 = BalVoxHash31(cell + float3(0, 0, 1));
    float n101 = BalVoxHash31(cell + float3(1, 0, 1));
    float n011 = BalVoxHash31(cell + float3(0, 1, 1));
    float n111 = BalVoxHash31(cell + float3(1, 1, 1));

    float z0 = lerp(lerp(n000, n100, f.x), lerp(n010, n110, f.x), f.y);
    float z1 = lerp(lerp(n001, n101, f.x), lerp(n011, n111, f.x), f.y);
    return lerp(z0, z1, f.z);
}

float BalVoxFBM(float3 p)
{
    float value = 0.0;
    float amplitude = 0.5;
    [unroll]
    for (int octave = 0; octave < 5; ++octave)
    {
        value += BalVoxNoise3D(p) * amplitude;
        p = p * 2.03 + 17.17;
        amplitude *= 0.5;
    }
    return value;
}

float3 BalVoxTriplanarWeights(float3 worldNormal, float sharpness)
{
    float3 weights = pow(abs(normalize(worldNormal)), sharpness);
    return weights / max(weights.x + weights.y + weights.z, 1e-4);
}

float BalVoxSurfaceVariation(float3 worldPosition, float3 worldNormal, float scale)
{
    float3 weights = BalVoxTriplanarWeights(worldNormal, 4.0);
    float x = BalVoxFBM(worldPosition.yzx * scale);
    float y = BalVoxFBM(worldPosition.xzy * scale);
    float z = BalVoxFBM(worldPosition.xyz * scale);
    return dot(float3(x, y, z), weights);
}

#endif
