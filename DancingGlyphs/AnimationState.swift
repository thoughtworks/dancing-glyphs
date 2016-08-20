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

class AnimationState
{
    var now: Double = 0
    
    func moveToTime(time: Double) {
        now = time
    }
    
    
    var p0: (x: Double, y: Double) { return position(phaseOffset: 4/3*M_PI) }
    var p1: (x: Double, y: Double) { return position(phaseOffset: 0/3*M_PI) }
    var p2: (x: Double, y: Double) { return position(phaseOffset: 2/3*M_PI) }
    
    func position(phaseOffset phaseOffset: Double) -> (x: Double, y: Double)
    {
        let dist = (MVMID + sin(now*MVSPEED) * MVAMP)
        let xpos = dist * cos(now*GRTSPEED + phaseOffset) + (sin(now*CRSPEED + phaseOffset) * CRRAD)
        let ypos = dist * sin(now*GRTSPEED + phaseOffset) + (cos(now*CRSPEED + phaseOffset) * CRRAD)
        return (xpos, ypos)
    }

    
    var r0: Double { return rotation(glyphRotationSpeed: RTSPEED1, phaseOffset: -1/2*M_PI) }
    var r1: Double { return rotation(glyphRotationSpeed: RTSPEED2, phaseOffset: +1/2*M_PI) }
    var r2: Double { return rotation(glyphRotationSpeed: RTSPEED3, phaseOffset:  0/2*M_PI) }

    func rotation(glyphRotationSpeed grt: Double, phaseOffset: Double) -> Double
    {
        return sin(now*grt + phaseOffset) * RTMAX
    }
   
}
