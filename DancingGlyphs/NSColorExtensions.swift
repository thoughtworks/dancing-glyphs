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

// see http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

import Cocoa
import Metal

extension NSColor
{
    class func TWGrayColor()       -> NSColor { return NSColor(red: 0x80/0x100, green: 0x82/0x100, blue: 0x85/0x100, alpha: 1) }
    class func TWLightGreenColor() -> NSColor { return NSColor(red: 0x8A/0x100, green: 0xB6/0x100, blue: 0x81/0x100, alpha: 1) }
    class func TWHotPinkColor()    -> NSColor { return NSColor(red: 0xED/0x100, green: 0x5C/0x100, blue: 0xA0/0x100, alpha: 1) }
    class func TWTurquoiseColor()  -> NSColor { return NSColor(red: 0x32/0x100, green: 0xBE/0x100, blue: 0xCE/0x100, alpha: 1) }

    func lighter(amount :CGFloat = 0.25) -> NSColor
    {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(amount :CGFloat = 0.25) -> NSColor
    {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    private func hueColorWithBrightnessAmount(amount: CGFloat) -> NSColor
    {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(hue: hue, saturation: saturation, brightness: brightness*amount, alpha: alpha)
    }
    
    
    func toMTLClearColor() -> MTLClearColor
    {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let deviceColor = self.colorUsingColorSpaceName("NSDeviceRGBColorSpace") 
        deviceColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
    
    
}