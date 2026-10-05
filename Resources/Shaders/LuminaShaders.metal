#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

[[stitchable]] half4 antigravityShader(coreimage::sample_t s, float2 uv, float time) {
    float2 center = float2(0.5, 0.5);
    float dist = distance(uv, center);
    float wave = sin(dist * 20.0 - time * 3.0) * 0.05;
    float2 displaced = uv + (uv - center) * wave;
    return s;
}

[[stitchable]] half4 chromaticAberration(coreimage::sample_t s, float2 uv, float intensity) {
    return s;
}
