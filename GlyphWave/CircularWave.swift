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

class CircularWave
{
    func makeSprites(_ numSprites: Int, glyphs: [Glyph], size maximumSize: Double) -> [Sprite]
    {
        var list: [Sprite] = []
        let step = 2 * M_PI / Double(numSprites)
        for i in 0..<numSprites {
            let size = Float(maximumSize * (0.7 + Util.randomDouble() * 0.3))
            let sprite = Sprite(glyph: Util.randomInt(glyphs.count), size: size,
                                                      r0: Util.randomDouble(), r1: Util.randomDouble(),
                                                      animation: CircularWave.move)
            sprite.basePos.x = Float(sin(step * Double(i)))
            sprite.basePos.y = Float(cos(step * Double(i)))
            list.append(sprite)
        }
        return list
    }
 
    
    static func move(sprite s: Sprite, to nowIn: Double)
    {
        let ASPECT_RATIO = 16.0/9.0 // TODO: need to get real ratio to this place somehow
        
        let now = nowIn * 0.5
        var y = sin(now * (1 + s.r0)) * 0.06                         // sprite swinging up and down, speed based on r0
        y *= s.r1 * (0.5 + s.r1/2)                                   // dampening, amplitude based on r1
        y += sin(now * 2.8 + Double(s.basePos.x) * M_PI * 1) * 0.02  // large wave across sprites
        y *= 2
        y += 0.28
        s.pos = s.basePos.normalized() * Matrix2x2(rotation: Float(now * 0.2)) * Vector2(Float(y * 1/ASPECT_RATIO), Float(y)) + Vector2(0.5, 0.5)
        s.rotation = Float(sin(now * (s.r0-0.5)) * 2 * M_PI)         // rotation based on r0
    }

    
}
