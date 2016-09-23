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


fragment float4 texturedQuadFragmentShader(VertexOut vout [[ stage_in ]],
                                          texture2d<float> texture0 [[ texture(0) ]],
                                          texture2d<float> texture1 [[ texture(1) ]],
                                          texture2d<float> texture2 [[ texture(2) ]])
{
    constexpr sampler linearSampler(coord::normalized, address::repeat, filter::linear);
    float4 color0;
    switch (vout.textureId) // TODO: move sample op out of switch
    {
        case 0:
            color0 = texture0.sample(linearSampler, vout.textureCoordinate);
            break;
        case 1:
            color0 = texture1.sample(linearSampler, vout.textureCoordinate);
            break;
        case 2:
            color0 = texture2.sample(linearSampler, vout.textureCoordinate);
            break;
    }
    return color0;
}

