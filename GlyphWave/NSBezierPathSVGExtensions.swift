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
    class func contentsOfSVG(url: URL) -> [NSBezierPath]?
    {
        var pathList: [NSBezierPath] = []
        let doc = try! XMLDocument(contentsOf: url, options: 0)
        for node in try! doc.nodes(forXPath: "//path") {
            let commands = (node as! XMLElement).attribute(forName:"d")!.stringValue!
            let path = NSBezierPath(svgCommands: commands)
            pathList.append(path)
        }
        return pathList
    }
    
    convenience init(svgCommands: String)
    {
        self.init()
        let tokens = svgCommands.components(separatedBy: " ")
        var i = 0
        while i < tokens.count {
            switch(tokens[i]) {
            case "M":
                move(to: point(tokens[i+1], tokens[i+2]))
                i += 3
            case "L":
                line(to: point(tokens[i+1], tokens[i+2]))
                i += 3
            case "C":
                curve(to: point(tokens[i+5], tokens[i+6]), controlPoint1: point(tokens[i+1], tokens[i+2]), controlPoint2: point(tokens[i+3], tokens[i+4]))
                i += 7
            case "Z":
                close()
                i += 1
            default:
                NSLog("skipping token '\(tokens[i])'")
                i += 1
            }
        }
    }

    private func point(_ string0: String, _ string1: String) -> NSPoint
    {
        let x = Double(string0)!
        let y = Double(string1)!
        return NSMakePoint(CGFloat(x), CGFloat(y))
    }
  
}
