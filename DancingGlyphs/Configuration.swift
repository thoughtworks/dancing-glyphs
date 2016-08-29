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
    let DGDefaultsKeyScheme = "Scheme"
    let DGDefaultsKeyGlyph = "Glyph"
    let DGDefaultsKeySize = "Size"
    let DGDefaultsKeyMovement = "Movement"
    
    var defaults: NSUserDefaults
    
    init()
    {
        let identifier = NSBundle(forClass: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier) as NSUserDefaults!
        defaults.registerDefaults([
            DGDefaultsKeyScheme: 0,
            DGDefaultsKeyGlyph: 0,
            DGDefaultsKeySize: 1,
            DGDefaultsKeyMovement: 1
        ])
    }
   
    
    var scheme: Int
    {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyScheme); defaults.synchronize() }
        get { return defaults.integerForKey(DGDefaultsKeyScheme) }
    }
    
    var glyph: Int
    {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyGlyph); defaults.synchronize() }
        get { return defaults.integerForKey(DGDefaultsKeyGlyph) }
    }
    
    var size: Int
    {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeySize); defaults.synchronize() }
        get { return defaults.integerForKey(DGDefaultsKeySize) }
    }
    
    var movement: Int
    {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyMovement); defaults.synchronize()}
        get { return defaults.integerForKey(DGDefaultsKeyMovement) }
    }

    
    var viewSettings: DancingGlyphsView.Settings
    {
        get
        {
            let backgroundColor = (self.scheme == 1) ? NSColor.blackColor() : NSColor.TWGrayColor().lighter(0.1)
            let filter = (self.scheme == 1) ? "CILinearDodgeBlendMode" : "CIColorBurnBlendMode"

            let glyphIndex = max(0, min(self.glyph, 2))
            let glyphPath = [NSBezierPath.TWSquareGlyphPath(), NSBezierPath.TWCircleGlyphPath(), NSBezierPath.TWLozengeGlyphPath()][glyphIndex]

            let glyphColors = [NSColor.TWLightGreenColor(), NSColor.TWHotPinkColor(), NSColor.TWTurquoiseColor()]

            let size: Double = (Double(self.size) + 1) * 0.16

            return DancingGlyphsView.Settings(glyph: glyphPath, glyphColors: glyphColors, backgroundColor: backgroundColor, filter: filter, size: size)
        }
    }

    
    var animationSettings: Animation.Settings
    {
        get
        {
            let animationSettings: Animation.Settings
            switch(self.movement)
            {
                case 2: // wild
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 3/60,
                        MVMID:    0.22,
                        MVAMP:    0.16,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.20,
                        CRSPEED:  2*M_PI * 10/60,
                        RTMAX:    2*M_PI * ((self.glyph == 1) ? 80 : 8)/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * 7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )
                case 1: // normal
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 1/60,
                        MVMID:    0.08,
                        MVAMP:    0.06,
                        MVSPEED:  2*M_PI * 11/60,
                        CRRAD:    0.04,
                        CRSPEED:  2*M_PI * 17/60,
                        RTMAX:    2*M_PI * ((self.glyph == 1) ? 80 : 8)/360,
                        RTSPEED1: 2*M_PI * 8/60,
                        RTSPEED2: 2*M_PI * 7/60,
                        RTSPEED3: 2*M_PI * 6/60
                        )

                default: // tight
                    animationSettings = Animation.Settings(
                        GRTSPEED: 2*M_PI * 4/60,
                        MVMID:    0.020,
                        MVAMP:    0.006,
                        MVSPEED:  2*M_PI * 33/60,
                        CRRAD:    0.006,
                        CRSPEED:  2*M_PI * 37/60,
                        RTMAX:    2*M_PI * ((self.glyph == 1) ? 40 : 4)/360,
                        RTSPEED1: 2*M_PI * 16/60,
                        RTSPEED2: 2*M_PI * 14/60,
                        RTSPEED3: 2*M_PI * 12/60
                    )
            }
            return animationSettings
        }
    }
    
    
}

