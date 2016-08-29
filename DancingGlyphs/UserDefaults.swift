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

class UserDefaults {
    
    let DGDefaultsKeyScheme = "Scheme"
    let DGDefaultsKeyGlyph = "Glyph"
    let DGDefaultsKeySize = "Size"
    let DGDefaultsKeyMovement = "Movement"

    var defaults: NSUserDefaults
    
    init()
    {
        let identifier = NSBundle(forClass: UserDefaults.self).bundleIdentifier!
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
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyScheme) }
        get { return defaults.integerForKey(DGDefaultsKeyScheme) }
    }

    var glyph: Int
        {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyGlyph) }
        get { return defaults.integerForKey(DGDefaultsKeyGlyph) }
    }

    var size: Int
        {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeySize) }
        get { return defaults.integerForKey(DGDefaultsKeySize) }
    }

    var movement: Int
        {
        set { defaults.setInteger(newValue, forKey: DGDefaultsKeyMovement) }
        get { return defaults.integerForKey(DGDefaultsKeyMovement) }
    }
    
}

