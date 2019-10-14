//
//  Shaders.metal
//  FirstComputeShader
//

#include <metal_stdlib>
using namespace metal;

kernel void compute(texture2d<float, access::write> tex [[ texture(0) ]],
                    constant float &time [[buffer(0)]],
                    uint2 id [[ thread_position_in_grid ]]){
    
    float2 resolution = float2(tex.get_width(),tex.get_height());
    float2 fragCoord = float2(id);
    
    float2 uv = (2.0 * fragCoord.xy - resolution) / float2(resolution.x, resolution.y);
    uv.y *= -1.0;
    
    tex.write(half4(uv.x,uv.y,0,1),id);
}
