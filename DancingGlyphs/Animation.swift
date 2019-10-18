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

class Animation
{
    struct Settings
    {
        // the centre points of the glyphs are set on an equilateral triangle
        // GRTSPEED is the speed with which the triangle revolves around its centre
        // for the speed x/60 means x rotations per minute
        var GRTSPEED: Double

        // the glyphs move away from the centre
        // MVMID is the middle distance, MVAMP the amplitude
        var MVMID: Double
        var MVAMP: Double
        var MVSPEED: Double

        // the glyphs travel on a circle around their individual "ideal" centre point
        // CRRAD is the radius of that circle
        var CRRAD: Double
        var CRSPEED: Double

        // the glyphs each rotate around their centre point
        // RTMAX is the maximum angle to either side they rotate
        var RTMAX: Double
        var RTSPEED1: Double
        var RTSPEED2: Double
        var RTSPEED3: Double
    }

    var settings: Settings!


    struct State
    {
        var p0: (x: Double, y: Double)
        var p1: (x: Double, y: Double)
        var p2: (x: Double, y: Double)
        
        var r0: Double
        var r1: Double
        var r2: Double
    }
    
    var currentState: State?


    func moveToTime(_ time: Double)
    {
        currentState = State(
            p0: position(time, phaseOffset: 4/3*Double.pi),
            p1: position(time, phaseOffset: 0/3*Double.pi),
            p2: position(time, phaseOffset: 2/3*Double.pi),
            r0: rotation(time, glyphRotationSpeed: settings.RTSPEED1, phaseOffset: -1/2*Double.pi),
            r1: rotation(time, glyphRotationSpeed: settings.RTSPEED2, phaseOffset: +1/2*Double.pi),
            r2: rotation(time, glyphRotationSpeed: settings.RTSPEED3, phaseOffset:  0/2*Double.pi)
        )
    }

    private func position(_ now: Double, phaseOffset: Double) -> (x: Double, y: Double)
    {
#if true
        let dist = (settings.MVMID + sin(now*settings.MVSPEED) * settings.MVAMP)
        let xpos = dist * cos(now*settings.GRTSPEED + phaseOffset) + (sin(now*settings.CRSPEED + phaseOffset) * settings.CRRAD)
        let ypos = dist * sin(now*settings.GRTSPEED + phaseOffset) + (cos(now*settings.CRSPEED + phaseOffset) * settings.CRRAD)
#else
        let xpos = 0.0 + (phaseOffset - 2/3*Double.pi) / 3
        let ypos = 0.0
#endif
        return (xpos, ypos)
    }

    fileprivate func rotation(_ now: Double, glyphRotationSpeed grt: Double, phaseOffset: Double) -> Double
    {
        if settings.RTMAX >= 0 {
            return sin(now*grt + phaseOffset) * settings.RTMAX
        }
        else {
            return (now*grt + phaseOffset)
        }
        
    }
   
}
