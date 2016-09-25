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
    class func TWSquareGlyphPath() -> NSBezierPath
    {
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
        return PathBuilder(points: points).applyRatio(0.964).scale(0.95).flip().path
    }
    
    class func TWCircleGlyphPath() -> NSBezierPath
    {
       let points = [
            NSMakePoint(-0.033596626037198263, -0.50000000000000355),
            NSMakePoint(-0.067038798326681359, -0.50000000000000355),
            NSMakePoint(-0.10089029953035578, -0.49668395544597033),
            NSMakePoint(-0.13461900205977351, -0.48988181277102782),
            NSMakePoint(-0.35000787670758271, -0.44626307286795708),
            NSMakePoint(-0.54562616479991988, -0.21188674432446675),
            NSMakePoint(-0.49061235873252151, 0.056330244026867149),
            NSMakePoint(-0.43662187495060145, 0.3197432191140166),
            NSMakePoint(-0.22160139632556586, 0.49999999999999645),
            NSMakePoint(0.064273917346101328, 0.49999999999999645),
            NSMakePoint(0.065051642283066258, 0.49999999999999645),
            NSMakePoint(0.065870300111448898, 0.49999999999999645),
            NSMakePoint(0.066607092156992564, 0.49995748660828099),
            NSMakePoint(0.083717040770217466, 0.49914973216563041),
            NSMakePoint(0.10999595706134002, 0.49961737947453244),
            NSMakePoint(0.13590647732969252, 0.49638636170393369),
            NSMakePoint(0.27311352936683697, 0.47912592466626691),
            NSMakePoint(0.38981320280296394, 0.42462375648328887),
            NSMakePoint(0.44969802294924932, 0.28641272000679763),
            NSMakePoint(0.50413876853677841, 0.16061559391208036),
            NSMakePoint(0.51559997813415315, 0.027718731400387497),
            NSMakePoint(0.47814638248559049, -0.10577331859536088),
            NSMakePoint(0.41179416549507231, -0.34295553099226339),
            NSMakePoint(0.19730581445848649, -0.50000000000000355),
            NSMakePoint(-0.033596626037198263, -0.50000000000000355)
        ]
 
        return PathBuilder(points: points).applyRatio(0.963).flip().path
    }
    
    class func TWLozengeGlyphPath() -> NSBezierPath
    {
        let points = [
            NSMakePoint(-0.031012314495498572, -0.5),
            NSMakePoint(-0.0750703214653754, -0.5),
            NSMakePoint(-0.1183669954823543, -0.48431183830606273),
            NSMakePoint(-0.15514268725059743, -0.44764196342637064),
            NSMakePoint(-0.30505907610602456, -0.29831568816169707),
            NSMakePoint(-0.29201711160855481, -0.28527430221366856),
            NSMakePoint(-0.44193350046398017, -0.13599615014437205),
            NSMakePoint(-0.53187009320414091, -0.046294513955729144),
            NSMakePoint(-0.51012245189744831, 0.069826756496627951),
            NSMakePoint(-0.42604481275132855, 0.15360923965350892),
            NSMakePoint(-0.28801183824765708, 0.29109720885466572),
            NSMakePoint(-0.29158679298300427, 0.29470644850817962),
            NSMakePoint(-0.1535538184793328, 0.43224254090471348),
            NSMakePoint(-0.10956201437492474, 0.47608277189605275),
            NSMakePoint(-0.057658967846926146, 0.5),
            NSMakePoint(-0.0052593998279064635, 0.5),
            NSMakePoint(0.042439764742786323, 0.5),
            NSMakePoint(0.090602349371764035, 0.48012512030798504),
            NSMakePoint(0.13350180619592855, 0.43739172281039274),
            NSMakePoint(0.28338509361861952, 0.28806544754571206),
            NSMakePoint(0.28950885867453735, 0.29441770933589595),
            NSMakePoint(0.44366223092000467, 0.14927815206929651),
            NSMakePoint(0.5335988236601672, 0.059672762271411273),
            NSMakePoint(0.50764730039616701, -0.05904716073147398),
            NSMakePoint(0.42360276268277985, -0.14282964388835495),
            NSMakePoint(0.285536686746374, -0.28041385948027298),
            NSMakePoint(0.28547048388090523, -0.28031761308951175),
            NSMakePoint(0.14743750937723554, -0.417805582290665),
            NSMakePoint(0.097785360275194577, -0.4673243503368667),
            NSMakePoint(0.032575537787847608, -0.5),
            NSMakePoint(-0.031012314495498572, -0.5),
        ]
        return PathBuilder(points: points).applyRatio(0.688).flip().path
    }
    
    fileprivate class PathBuilder
    {
        var path: NSBezierPath
        
        init(points: [NSPoint])
        {
            path = NSBezierPath()
            path.move(to: points[0])
            var i = 1
            while i < points.count {
                path.curve(to: points[i+2], controlPoint1: points[i+0], controlPoint2: points[i+1])
                i += 3
            }
            path.close()
        }
        
        func flip() -> PathBuilder
        {
            var transform = AffineTransform.identity
            transform.scale(x: 1, y: -1)
            path.transform(using: transform)
            return self
        }

        func scale(_ factor:CGFloat) -> PathBuilder
        {
            var transform = AffineTransform.identity
            transform.scale(x: factor, y: factor)
            path.transform(using: transform)
            return self
        }

        func applyRatio(_ ratio: CGFloat) -> PathBuilder
        {
            var transform = AffineTransform.identity
            transform.scale(x: 1, y: ratio)
            path.transform(using: transform)
            return self
        }
        
    }
    
}
