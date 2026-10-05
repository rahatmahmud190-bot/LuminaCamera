#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

[[stitchable]] float4 antigravityShader(coreimage::sample_t s, float2 uv, float time) {
    return float4(s);
}

[[stitchable]] float4 chromaticAberration(coreimage::sample_t s, float2 uv, float intensity) {
    return float4(s);
}
