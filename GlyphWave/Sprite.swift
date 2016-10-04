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
    let glyph: Int
    let size: Float
    let r0: Double
    let r1: Double
    
    var basePos: Vector2
    var pos: Vector2
    var rotation: Float
    
    var animation: (Sprite, Double) -> ()
    
    init(glyph: Int, size: Float, r0: Double, r1: Double, animation: @escaping (Sprite, Double) -> ())
    {
        self.glyph = glyph
        self.size = size
        self.r0 = r0
        self.r1 = r1
        
        self.basePos = Vector2(0, 0)
        self.pos = Vector2(0, 0)
        self.rotation = 0
        
        self.animation = animation
    }
    
    func move(to now: Double)
    {
        animation(self, now)
    }

    func corners(screenSize: Vector2) -> (Vector2, Vector2, Vector2, Vector2)
    {
        let rotationMatrix = Matrix2x2(rotation: rotation)
        let s = Float(size) * min(screenSize.x, screenSize.y) // TODO: coupling to same logic in view

        let a = ((pos * screenSize) + Vector2(-s/2, +s/2) * rotationMatrix)
        let b = ((pos * screenSize) + Vector2(-s/2, -s/2) * rotationMatrix)
        let c = ((pos * screenSize) + Vector2(+s/2, -s/2) * rotationMatrix)
        let d = ((pos * screenSize) + Vector2(+s/2, +s/2) * rotationMatrix)

        return (a, b, c, d)
    }
}
