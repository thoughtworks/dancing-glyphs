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
    enum Scheme: Int {
        case normal, dark
    }
    
    enum Glyph: Int {
        case square, circle
    }
    
    enum Size: Int {
        case small, medium, large
    }
    
    enum Movement: Int {
        case tight, normal, wild
    }
    

    var defaults: UserDefaults
    
    var scheme: Scheme = Scheme.dark
    var glyph: Glyph = Glyph.square
    var size: Size = Size.medium
    var movement: Movement = Movement.normal
    
    
    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier) as UserDefaults!
        defaults.register(defaults: [
                String(describing: Scheme.self): Scheme.dark.rawValue,
                String(describing: Glyph.self): -1,
                String(describing: Size.self): -1,
                String(describing: Movement.self): -1
        ])
        update()
    }
    
    
    var schemeCode: Int
    {
        set { defaults.set(newValue, forKey: String(describing: Scheme.self)); update() }
        get { return defaults.integer(forKey: String(describing: Scheme.self)) }
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

        scheme = enumForCode(schemeCode, defaultCase: Scheme.dark)
        glyph = enumForCode(glyphCode, defaultCase: Glyph.square)
        size = enumForCode(sizeCode, defaultCase: Size.medium)
        movement = enumForCode(movementCode, defaultCase: Movement.normal)

        if sizeCode == -1 && movementCode == -1 {
            switch(randomInt(7)) {
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

    private func enumForCode<E: RawRepresentable>(_ code :Int, defaultCase: E) -> E where E.RawValue == Int
    {
        let val: Int
        if code == -1 {
            var maxValue: Int = 0
            while let _ = E(rawValue: maxValue) {
                maxValue += 1
            }
            val = randomInt(maxValue)
        } else {
            val = code
        }
        return E(rawValue: val) ?? defaultCase
    }
    
    private func randomInt(_ max: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(max)))
    }
    

    var viewSettings: DancingGlyphsView.Settings
    {
        get
        {
            let backgroundColor = (scheme == .dark) ? NSColor.black : NSColor.TWGrayColor.lighter(0.1)
            let filter = (scheme == .dark) ? "CILinearDodgeBlendMode" : "CIColorBurnBlendMode"

            let glyphPath = [NSBezierPath.TWSquareGlyphPath(), NSBezierPath.TWCircleGlyphPath(), NSBezierPath.TWLozengeGlyphPath()][glyph.rawValue]

            let glyphColors = [NSColor.TWLightGreenColor, NSColor.TWHotPinkColor, NSColor.TWTurquoiseColor]

            let sizeValue: Double = (Double(size.rawValue) + 1) * 0.16

            return DancingGlyphsView.Settings(glyph: glyphPath, glyphColors: glyphColors, backgroundColor: backgroundColor, filter: filter, size: sizeValue)
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
                        GRTSPEED: 2*M_PI * 3/60,
                        MVMID:    0.22,
                        MVAMP:    0.16,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.20,
                        CRSPEED:  2*M_PI * 10/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*M_PI * 8/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * -7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )
                case .normal:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 1/60,
                        MVMID:    0.08,
                        MVAMP:    0.06,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.04,
                        CRSPEED:  2*M_PI * 17/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*M_PI * 8/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * -7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )
                case .tight:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 4/60,
                        MVMID:    0.020,
                        MVAMP:    0.006,
                        MVSPEED:  2*M_PI * 33/60,
                        CRRAD:    0.006,
                        CRSPEED:  2*M_PI * 37/60,
                        RTMAX:    (self.glyph == .circle) ? -1 : 2*M_PI * 4/360,
                        RTSPEED1: 2*M_PI * 4/60,
                        RTSPEED2: 2*M_PI * -3/60,
                        RTSPEED3: 2*M_PI * 2/60
                    )
            }
            return animationSettings
        }
    }
  
}

