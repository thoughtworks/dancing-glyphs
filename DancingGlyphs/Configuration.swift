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

import ScreenSaver

class Configuration
{
    enum Glyph: Int {
        case square, circle
    }
    
    enum Size: Int {
        case small, medium, large
    }
    
    enum Movement: Int {
        case tight, normal, wild
    }
    
    static let sharedInstance = Configuration()

    var defaults: UserDefaults
    let glyphPaths: [NSBezierPath]
    
    var glyph: Glyph = Glyph.square
    var size: Size = Size.medium
    var movement: Movement = Movement.normal

    
    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [
                String(describing: Glyph.self): -1,
                String(describing: Size.self): -1,
                String(describing: Movement.self): -1
        ])
        let url = Bundle(for: Configuration.self).url(forResource: "Glyphs", withExtension: "svg")!
        glyphPaths = NSBezierPath.contentsOfSVG(url: url)!
        glyphPaths.forEach { $0.normalize() }

        update()
    }
    
    
    var glyphCode: Int
    {
        set { defaults.set(newValue, forKey: String(describing: Glyph.self)); update() }
        get { return defaults.integer(forKey: String(describing: Glyph.self)) }
    }
    
    var sizeCode: Int
    {
        set { defaults.set(newValue, forKey: String(describing: Size.self)); update() }
        get { return defaults.integer(forKey: String(describing: Size.self)) }
    }
    
    var movementCode: Int
    {
        set { defaults.set(newValue, forKey: String(describing: Movement.self)); update()}
        get { return defaults.integer(forKey: String(describing: Movement.self)) }
    }

    
    private func update()
    {
        defaults.synchronize()

        glyph = Util.enumForCode(glyphCode, defaultCase: Glyph.square)
        size = Util.enumForCode(sizeCode, defaultCase: Size.medium)
        movement = Util.enumForCode(movementCode, defaultCase: Movement.normal)

        if sizeCode == -1 && movementCode == -1 {
            switch(Util.randomInt(7)) {
                case 0: (size, movement) = (.small  , .normal)
                case 1: (size, movement) = (.small  , .wild)
                case 2: (size, movement) = (.medium , .tight)
                case 3: (size, movement) = (.medium , .normal)
                case 4: (size, movement) = (.medium , .wild)
                case 5: (size, movement) = (.large , .tight)
                case 6: (size, movement) = (.large , .normal)
                default: break // keep compiler happy
            }
        }
    }

    var viewSettings: DancingGlyphsView.Settings
    {
        get
        {
            let glyphPath = (glyph == .square) ? glyphPaths[10] : glyphPaths[2]
            let glyphColors = [NSColor.twGreen02, NSColor.twBrightPink, NSColor.twBlue02]
            let sizeValue: Double = (Double(size.rawValue) + 1) * 0.2

            return DancingGlyphsView.Settings(backgroundColor: NSColor.black, glyph: glyphPath, glyphColors: glyphColors, glyphSize: sizeValue)
        }
    }

    
    var animationSettings: Animation.Settings
    {
        get
        {
            let animationSettings: Animation.Settings
            switch(movement)
            {
                case .wild:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*Double.pi * 3/60,
                        MVMID:    0.22,
                        MVAMP:    0.16,
                        MVSPEED:  2*Double.pi * 11/60,
                        CRRAD:    0.20,
                        CRSPEED:  2*Double.pi * 10/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*Double.pi * 8/360,
                        RTSPEED1: 2*Double.pi * 8/60,
                        RTSPEED2: 2*Double.pi * -7/60,
                        RTSPEED3: 2*Double.pi * 6/60
                        )
                case .normal:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*Double.pi * 1/60,
                        MVMID:    0.08,
                        MVAMP:    0.06,
                        MVSPEED:  2*Double.pi * 11/60,
                        CRRAD:    0.04,
                        CRSPEED:  2*Double.pi * 17/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*Double.pi * 8/360,
                        RTSPEED1: 2*Double.pi * 8/60,
                        RTSPEED2: 2*Double.pi * -7/60,
                        RTSPEED3: 2*Double.pi * 6/60
                        )
                case .tight:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*Double.pi * 4/60,
                        MVMID:    0.020,
                        MVAMP:    0.006,
                        MVSPEED:  2*Double.pi * 33/60,
                        CRRAD:    0.006,
                        CRSPEED:  2*Double.pi * 37/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*Double.pi * 4/360,
                        RTSPEED1: 2*Double.pi * 4/60,
                        RTSPEED2: 2*Double.pi * -3/60,
                        RTSPEED3: 2*Double.pi * 2/60
                    )
            }
            return animationSettings
        }
    }
  
}

