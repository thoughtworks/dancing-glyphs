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
    enum WaveType: Int {
        case linear, circular
    }

    static let sharedInstance = Configuration()

    let numSprites = 600
    let glyphSize = 0.1
    let backgroundColor = NSColor.black

    var defaults: UserDefaults
    var waveType: WaveType = WaveType.linear

    
    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = (ScreenSaverDefaults(forModuleWithName: identifier) as UserDefaults?)!
        defaults.register(defaults: [
                String(describing: Wave.self): -1,
        ])
        update()
    }
    
    
    var waveTypeCode: Int
    {
        set { defaults.set(newValue, forKey: String(describing: Wave.self)); update() }
        get { return defaults.integer(forKey: String(describing: Wave.self)) }
    }
    
    private func update()
    {
        defaults.synchronize()
        waveType = Util.enumForCode(waveTypeCode, defaultCase: WaveType.linear)
    }

    var wave: Wave
    {
        get
        {
            return (waveType == .linear) ? (LinearWave() as Wave) : (CircularWave() as Wave)
        }
    }

}

