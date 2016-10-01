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
    
    var pos: Vector2
    var rotation: Float

    init(glyph: Int, size: Float, r0: Double, r1: Double)
    {
        self.glyph = glyph
        self.size = size
        self.r0 = r0
        self.r1 = r1
        
        self.pos = Vector2(0, 0)
        self.rotation = 0
    }

    func move(_ now: Double)
    {
        var y = sin(now * (1 + r0)) * 0.12                    // sprite swinging up and down, speed based on r0
        y *= r1 * (0.5 + r1/2)                                // dampening, amplitude based on r1
        y += sin(now * -2 + Double(pos.x) * M_PI * 3) * 0.03  // large wave across sprites
        y += 0.5                                              // moving to middle
        pos.y = Float(y)
        rotation = Float(sin(now * (r0-0.5)) * 2 * M_PI)      // rotation based on r0
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
