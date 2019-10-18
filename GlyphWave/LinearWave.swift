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

public class LinearWave: Wave
{
    var scaleMode: ScaleMode
    {
        get
        {
            return .fill
        }
    }
    
    func makeSprites(_ numSprites: Int, glyphs: [Glyph], size maximumSize: Double) -> [Sprite]
    {
        var list: [Sprite] = []
        let xstep = 1 / Double(numSprites)
        for i in 0..<numSprites {
            let pos = Vector2(Float(xstep * Double(i)), 0)
            let size = Float(maximumSize * (0.7 + Util.randomDouble() * 0.3))
            let sprite = Sprite(glyphId: Util.randomInt(glyphs.count), anchor: pos, size: size, animation: LinearWave.move)
            list.append(sprite)
        }
        return list
    }
    
    static func move(sprite s: Sprite, to now: Double)
    {
        var y = sin(now * (0.1 + s.r0)) * 0.08                         // sprite swinging up and down, speed based on r0
        y *= s.r1 * (0.4 + s.r1/2)                                     // dampening, amplitude based on r1
        y += sin(now * -1.2 + Double(s.anchor.x) * Double.pi * 3) * 0.025   // large wave across sprites
        y += 0.5                                                       // moving to middle
        s.pos = Vector2(s.anchor.x, Float(y))
        s.rotation = Float(now * (s.r0 - 0.5) * 1.2)                   // rotation based on r0
    }
    
}
