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

extension NSBezierPath
{
    class func TWSquareGlyphPath() -> NSBezierPath {
        let points = [
            NSMakePoint(0.23852567599158547, -0.50000000000000178),
            NSMakePoint(0.0080651445492083695, -0.50000000000000178),
            NSMakePoint(0.0080651445492083695, -0.49987869966036058),
            NSMakePoint(-0.22235642484220364, -0.49987869966036058),
            NSMakePoint(-0.36281461856152042, -0.49987869966036058),
            NSMakePoint(-0.49999999999999822, -0.41945657447841),
            NSMakePoint(-0.49999999999999822, -0.26358563803978896),
            NSMakePoint(-0.49999999999999822, -0.003881610868512908),
            NSMakePoint(-0.47822021351203858, -0.003881610868512908),
            NSMakePoint(-0.47822021351203858, 0.25582241630276314),
            NSMakePoint(-0.47822021351203858, 0.41165291929483772),
            NSMakePoint(-0.36281461856152042, 0.49381368267830794),
            NSMakePoint(-0.22235642484220364, 0.49381368267830794),
            NSMakePoint(0.0080651445492083695, 0.49381368267830794),
            NSMakePoint(0.0080651445492083695, 0.5),
            NSMakePoint(0.23852567599158547, 0.5),
            NSMakePoint(0.37894490765993893, 0.5),
            NSMakePoint(0.48246707706693925, 0.41165291929483772),
            NSMakePoint(0.48246707706693925, 0.25582241630276314),
            NSMakePoint(0.48246707706693925, -0.003881610868512908),
            NSMakePoint(0.49290890672485155, -0.0037198770823252403),
            NSMakePoint(0.50000000000000178, -0.26338347080705482),
            NSMakePoint(0.50000000000000178, -0.41925440724567409),
            NSMakePoint(0.37894490765993893, -0.50000000000000178),
            NSMakePoint(0.23852567599158547, -0.50000000000000178),
            ]
        
        let path = NSBezierPath()
        path.moveToPoint(points[0])
        var i = 1
        while i < points.count {
            path.curveToPoint(points[i+2], controlPoint1: points[i+0], controlPoint2: points[i+1])
            i += 3
        }
        path.closePath()
        
        return path
    }
}
