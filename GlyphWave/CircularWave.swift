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

class CircularWave: Wave
{
    var scaleMode: ScaleMode
    {
        get
        {
            return .fit
        }
    }

    func makeSprites(_ numSprites: Int, glyphs: [Glyph], size maximumSize: Double) -> [Sprite]
    {
        var list: [Sprite] = []
        let step = Float(2 * M_PI) / Float(numSprites)
        for i in 0..<numSprites {
            let pos = Vector2(sin(step * Float(i)), cos(step * Float(i)))
            let size = Float(maximumSize * (0.7 + Util.randomDouble() * 0.3))
            let sprite = Sprite(glyphId: Util.randomInt(glyphs.count), anchor: pos, size: size, animation: CircularWave.move)
            list.append(sprite)
        }
        return list
    }
 
    
    static func move(sprite s: Sprite, to nowIn: Double)
    {
        let now = nowIn * 0.5                                        // global slow-down
        
        var y = sin(now * (0.6 + s.r0)) * 0.11                         // sprite swinging up and down, speed based on r0
        y *= s.r1 * (0.7 + s.r1 * 0.3)                                 // dampening, amplitude based on r1
        y += sin(now * 1.5 + Double(s.anchor.x) * M_PI * 1) * 0.04  //  large wave across sprites
        y += 0.28                                                    // move up (transformed into move-out-of-centre below)
        
        s.pos = s.anchor * Matrix2x2(rotation: Float(now * 0.15))     // move around centre point
        s.pos = s.pos * Vector2(Float(y), Float(y))                  // make movement orthogonal to circle
        s.pos = s.pos + Vector2(0.5, 0.5)                            // move origin to middle of screen
        
        s.rotation = Float(sin(now * (s.r0-0.5)) * 2 * M_PI)         // rotation based on r0
    }

    
}
