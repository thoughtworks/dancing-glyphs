/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

#include <metal_stdlib>

using namespace metal;


struct Uniforms {
    float4x4 ndcMatrix;
};

struct VertexOut
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    uint textureId [[user(textureid)]];
};

struct FragmentOut {
    half4 color0 [[ color(0) ]];
};



vertex VertexOut vertexShader(uint vid [[ vertex_id ]],
                              constant packed_float2* vertices [[ buffer(0) ]],
                              constant packed_float2* textureCoordinates [[ buffer(1) ]],
                              constant Uniforms& uniforms [[ buffer(2) ]])
{
    VertexOut vout;
    float2 position = vertices[vid];
    vout.position = uniforms.ndcMatrix * float4(position.x, position.y, 0, 1);
    vout.textureCoordinate = textureCoordinates[vid];
    vout.textureId = vid / 6;
    return vout;
    
};


fragment FragmentOut texturedQuadFragmentShader(VertexOut vout [[ stage_in ]],
                                          texture2d<half> texture0 [[ texture(0) ]],
                                          texture2d<half> texture1 [[ texture(1) ]],
                                          texture2d<half> texture2 [[ texture(2) ]])
{
    FragmentOut fout;
    constexpr sampler quad_sampler(coord::normalized,
                                   address::repeat,
                                   filter::linear);
    switch (vout.textureId) // TODO: move sample op out of switch
    {
        case 0:
            fout.color0 = texture0.sample(quad_sampler, vout.textureCoordinate);
            break;
        case 1:
            fout.color0 = texture1.sample(quad_sampler, vout.textureCoordinate);
            break;
        case 2:
            fout.color0 = texture2.sample(quad_sampler, vout.textureCoordinate);
            break;
    }
    return fout;
}

kernel void computeShader(texture2d<float, access::read> g0 [[ texture(0) ]],
                          texture2d<float, access::read> g1 [[ texture(1) ]],
                          texture2d<float, access::write> dest [[ texture(2) ]],
                          uint2 gid [[ thread_position_in_grid ]])
{
    float4 g0Color = g0.read(gid);
    float4 g1Color = g1.read(gid);
    float4 resultColor = g0Color + g1Color;
    
    dest.write(resultColor, gid);
}

