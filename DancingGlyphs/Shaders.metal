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


vertex float4 myVertexShader(const device float2 * vertex_array [[ buffer(0) ]], uint vid [[ vertex_id ]])
{
    return float4(vertex_array[vid],0,1);
}

fragment float4 myFragmentShader()
{
    return float4(1.0, 0.0, 1.0, 1.0);
}
