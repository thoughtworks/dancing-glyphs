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

class GlyphFactory
{
    func makeAllGlyphs() -> [Glyph]
    {
        let colors = [NSColor.twYellow, NSColor.twOrange, NSColor.twDeepPink, NSColor.twBrightPink,
                      NSColor.twGreen03, NSColor.twBlue02, NSColor.twBlue03]

        let url = Bundle(for: GlyphFactory.self).url(forResource: "Glyphs", withExtension: "svg")!
        let paths = NSBezierPath.contentsOfSVG(url: url)!
        
        var allGlyphs: [Glyph] = []
        for p in paths {
            for c in colors {
                normalizePath(p)
                allGlyphs.append(Glyph(path: p, color: c))
            }
        }

        return allGlyphs
    }
    
    private func normalizePath(_ path: NSBezierPath)
    {
        let origin = path.bounds.origin
        path.transform(using: AffineTransform(translationByX: -origin.x, byY: -origin.y))
        
        let w = path.bounds.size.width
        let h = path.bounds.size.height
        
        if w > h {
            path.transform(using: AffineTransform(translationByX: 0, byY: (w-h)/2))
            path.transform(using: AffineTransform(scale: 1/w))
            
        } else {
            path.transform(using: AffineTransform(translationByX: (h-w)/2, byY: 0))
            path.transform(using: AffineTransform(scale: 1/h))
        }
    }
    
}


