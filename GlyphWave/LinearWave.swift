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

public class LinearWave
{
    func makeSprites(_ numSprites: Int, glyphs: [Glyph], size maximumSize: Double) -> [Sprite]
    {
        var list: [Sprite] = []
        let xstep = 1 / Double(numSprites)
        for i in 0..<numSprites {
            let size = Float(maximumSize * (0.7 + Util.randomDouble() * 0.3))
            let sprite = Sprite(glyph: Util.randomInt(glyphs.count), size: size,
                                r0: Util.randomDouble(), r1: Util.randomDouble(),
                                animation: LinearWave.move)
            sprite.pos.x = Float(xstep * Double(i))
            list.append(sprite)
        }
        return list
    }
    
    static func move(sprite s: Sprite, to now: Double)
    {
        var y = sin(now * (0.2 + s.r0)) * 0.12                      // sprite swinging up and down, speed based on r0
        y *= s.r1 * (0.5 + s.r1/2)                                  // dampening, amplitude based on r1
        y += sin(now * -1.8 + Double(s.pos.x) * M_PI * 3) * 0.04    // large wave across sprites
        y += 0.5                                                    // moving to middle
        s.pos.y = Float(y)
        s.rotation = Float(now * (s.r0 - 0.5) * 1.2)                // rotation based on r0
    }
    
}
