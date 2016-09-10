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
    return vout;
    
};


fragment half4 texturedQuadFragmentShader(VertexOut vout [[ stage_in ]],
                                          texture2d<half> texture [[ texture(0) ]])
{
    constexpr sampler quad_sampler;
    half4 color = texture.sample(quad_sampler, vout.textureCoordinate);
    return color;
}
