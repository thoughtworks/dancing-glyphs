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

import Cocoa

class Sprite
{
    let glyphId: Int
    let anchor: Vector2
    let size: Float
    let r0: Double
    let r1: Double
    
    let animation: (Sprite, Double) -> ()

    var pos: Vector2
    var rotation: Float
    
    init(glyphId: Int, anchor: Vector2, size: Float, animation: @escaping (Sprite, Double) -> ())
    {
        self.glyphId = glyphId
        self.size = size
        self.r0 = Util.randomDouble()
        self.r1 = Util.randomDouble()
        
        self.anchor = anchor
        self.pos = Vector2(0, 0)
        self.rotation = 0
        
        self.animation = animation
    }
    
    func move(to now: Double)
    {
        animation(self, now)
    }

    var corners: (Vector2, Vector2, Vector2, Vector2)
    {
        get
        {
            let rotationMatrix = Matrix2x2(rotation: rotation)

            let a = (pos + Vector2(-size/2, +size/2) * rotationMatrix)
            let b = (pos + Vector2(-size/2, -size/2) * rotationMatrix)
            let c = (pos + Vector2(+size/2, -size/2) * rotationMatrix)
            let d = (pos + Vector2(+size/2, +size/2) * rotationMatrix)

            return (a, b, c, d)
        }
    }
    

}
