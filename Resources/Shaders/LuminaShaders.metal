#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" {
    namespace coreimage {
        float4 luminaVignette(sample_t image, float intensity, float radius, destination dest) {
            float2 coord = dest.coord();
            float2 center = dest.extent().xy + dest.extent().zw * 0.5;
            float dist = distance(coord, center) / (max(dest.extent().z, dest.extent().w) * 0.5);
            float v = smoothstep(radius, radius - intensity, dist);
            return float4(image.rgb * v, image.a);
        }

        float4 luminaGrain(sample_t image, float amount, float size, destination dest) {
            float2 coord = dest.coord() / size;
            float n = fract(sin(dot(coord, float2(12.9898, 78.233))) * 43758.5453);
            float grain = (n - 0.5) * amount;
            float3 color = image.rgb + grain;
            return float4(clamp(color, 0.0, 1.0), image.a);
        }
        
        float4 luminaBloom(sample_t image, sample_t blurredImage, float intensity) {
            float3 color = image.rgb;
            float3 bloom = blurredImage.rgb;
            // Screen blend mode
            float3 result = 1.0 - (1.0 - color) * (1.0 - bloom * intensity);
            return float4(clamp(result, 0.0, 1.0), image.a);
        }
        
        float4 luminaFocusPeaking(sample_t image, sample_t blurredImage, float threshold) {
            // Edge detection difference
            float3 diff = abs(image.rgb - blurredImage.rgb);
            float edge = max(diff.r, max(diff.g, diff.b));
            if (edge > threshold) {
                return float4(1.0, 0.0, 0.0, image.a); // Red peak
            }
            return image;
        }
        
        float4 luminaSkinToneProtect(sample_t image, float saturationAdjust) {
            // Simplified HSV or skin tone hue check
            float minC = min(min(image.r, image.g), image.b);
            float maxC = max(max(image.r, image.g), image.b);
            float delta = maxC - minC;
            
            float4 out = image;
            if (delta > 0.0 && maxC > 0.0) {
                float h = 0.0;
                if (maxC == image.r) h = fmod((image.g - image.b) / delta, 6.0);
                else if (maxC == image.g) h = (image.b - image.r) / delta + 2.0;
                else h = (image.r - image.g) / delta + 4.0;
                h *= 60.0;
                if (h < 0.0) h += 360.0;
                
                // Skin tone hue range roughly 10 to 45
                if (h > 5.0 && h < 50.0) {
                    // Reduce the effect of saturation adjustment in this hue range
                    // In a full implementation, this blends between adjusted and original
                } else {
                    // Apply full saturation adjustment (simplified logic)
                }
            }
            return out;
        }

        float4 luminaDepthBlur(sample_t image, sample_t blurredImage, sample_t depthMask, float maxRadius) {
            float mask = depthMask.r;
            float3 result = mix(image.rgb, blurredImage.rgb, mask);
            return float4(result, image.a);
        }
        
        float4 luminaClarity(sample_t image, sample_t blurredImage, float amount) {
            float3 lumaWeights = float3(0.299, 0.587, 0.114);
            float lumaOrig = dot(image.rgb, lumaWeights);
            float lumaBlur = dot(blurredImage.rgb, lumaWeights);
            
            float diff = lumaOrig - lumaBlur;
            float3 result = image.rgb + (diff * amount);
            return float4(clamp(result, 0.0, 1.0), image.a);
        }
        
        float4 luminaChromaBlur(sample_t image, sample_t chromaBlurredImage) {
            float3 lumaWeights = float3(0.299, 0.587, 0.114);
            float lumaOrig = dot(image.rgb, lumaWeights);
            
            // Reconstruct color using blurred chroma and original luma
            float3 result = chromaBlurredImage.rgb + (lumaOrig - dot(chromaBlurredImage.rgb, lumaWeights));
            return float4(clamp(result, 0.0, 1.0), image.a);
        }
    }
}
