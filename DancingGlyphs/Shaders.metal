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

struct VertexInOut
{
    float4  position [[position]];
    float4  color;
    
};

vertex VertexInOut vertexShader(uint vid [[ vertex_id ]],
                                constant packed_float4* position [[ buffer(0) ]],
                                constant packed_float4* color    [[ buffer(1) ]])
{
    VertexInOut outVertex;
    outVertex.position = position[vid];
    outVertex.color    = color[vid];
    return outVertex;
    
};

fragment half4 fragmentShader(VertexInOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};
