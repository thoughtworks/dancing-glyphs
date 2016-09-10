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
        case Normal, Dark
    }
    
    enum Glyph: Int {
        case Square, Circle
    }
    
    enum Size: Int {
        case Small, Medium, Large
    }
    
    enum Movement: Int {
        case Tight, Normal, Wild
    }
    

    var defaults: NSUserDefaults
    
    var scheme: Scheme = Scheme.Dark
    var glyph: Glyph = Glyph.Square
    var size: Size = Size.Medium
    var movement: Movement = Movement.Normal
    
    
    init()
    {
        let identifier = NSBundle(forClass: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier) as NSUserDefaults!
        defaults.registerDefaults([
                String(Scheme): Scheme.Dark.rawValue,
                String(Glyph): -1,
                String(Size): -1,
                String(Movement): -1
        ])
        update()
    }
    
    
    var schemeCode: Int
    {
        set { defaults.setInteger(newValue, forKey: String(Scheme)); update() }
        get { return defaults.integerForKey(String(Scheme)) }
    }
    
    var glyphCode: Int
    {
        set { defaults.setInteger(newValue, forKey: String(Glyph)); update() }
        get { return defaults.integerForKey(String(Glyph)) }
    }
    
    var sizeCode: Int
    {
        set { defaults.setInteger(newValue, forKey: String(Size)); update() }
        get { return defaults.integerForKey(String(Size)) }
    }
    
    var movementCode: Int
    {
        set { defaults.setInteger(newValue, forKey: String(Movement)); update()}
        get { return defaults.integerForKey(String(Movement)) }
    }

    
    private func update()
    {
        defaults.synchronize()

        self.scheme = enumForCode(self.schemeCode, defaultCase: Scheme.Dark)
        self.glyph = enumForCode(self.glyphCode, defaultCase: Glyph.Square)
        self.size = enumForCode(self.sizeCode, defaultCase: Size.Medium)
        self.movement = enumForCode(self.movementCode, defaultCase: Movement.Normal)

        if sizeCode == -1 && movementCode == -1 {
            switch(randomInt(7)) {
                case 0: (self.size, self.movement) = (.Small  , .Normal)
                case 1: (self.size, self.movement) = (.Small  , .Wild)
                case 2: (self.size, self.movement) = (.Medium , .Tight)
                case 3: (self.size, self.movement) = (.Medium , .Normal)
                case 4: (self.size, self.movement) = (.Medium , .Wild)
                case 5: (self.size, self.movement) = (.Large , .Tight)
                case 6: (self.size, self.movement) = (.Large , .Normal)
                default: break // keep compiler happy
            }
        }
    }

    private func enumForCode<E: RawRepresentable where E.RawValue == Int>(code :Int, defaultCase: E) -> E
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
    
    private func randomInt(max: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(max)))
    }
    

    var viewSettings: DancingGlyphsView.Settings
    {
        get
        {
            let backgroundColor = (self.scheme == .Dark) ? NSColor.blackColor() : NSColor.TWGrayColor().lighter(0.1)
            let filter = (self.scheme == .Dark) ? "CILinearDodgeBlendMode" : "CIColorBurnBlendMode"

            let glyphPath = [NSBezierPath.TWSquareGlyphPath(), NSBezierPath.TWCircleGlyphPath(), NSBezierPath.TWLozengeGlyphPath()][glyph.rawValue]

            let glyphColors = [NSColor.TWLightGreenColor(), NSColor.TWHotPinkColor(), NSColor.TWTurquoiseColor()]

            let sizeValue: Double = (Double(self.size.rawValue) + 1) * 0.16

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
                case .Wild:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 3/60,
                        MVMID:    0.22,
                        MVAMP:    0.16,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.20,
                        CRSPEED:  2*M_PI * 10/60,
                        RTMAX:    (self.glyph == .Circle) ? -1 : 2*M_PI * 8/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * -7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )
                case .Normal:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 1/60,
                        MVMID:    0.08,
                        MVAMP:    0.06,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.04,
                        CRSPEED:  2*M_PI * 17/60,
                        RTMAX:    (self.glyph == .Circle) ? -1 : 2*M_PI * 8/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * -7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )
                case .Tight:
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 4/60,
                        MVMID:    0.020,
                        MVAMP:    0.006,
                        MVSPEED:  2*M_PI * 33/60,
                        CRRAD:    0.006,
                        CRSPEED:  2*M_PI * 37/60,
                        RTMAX:    (self.glyph == .Circle) ? -1 : 2*M_PI * 4/360,
                        RTSPEED1: 2*M_PI * 4/60,
                        RTSPEED2: 2*M_PI * -3/60,
                        RTSPEED3: 2*M_PI * 2/60
                    )
            }
            return animationSettings
        }
    }
  
}

