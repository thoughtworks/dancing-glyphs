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
    class var twYellow:     NSColor { get { return NSColor(webcolor: "#fff350") } }
    class var twOrange:     NSColor { get { return NSColor(webcolor: "#f58a33") } }
    class var twRed:        NSColor { get { return NSColor(webcolor: "#ed312f") } }
    class var twDeepPink:   NSColor { get { return NSColor(webcolor: "#b51b58") } }
    class var twPurple:     NSColor { get { return NSColor(webcolor: "#702269") } }
    class var twBrightPink: NSColor { get { return NSColor(webcolor: "#ee5ba0") } }
    class var twGreen02:    NSColor { get { return NSColor(webcolor: "#85b880") } }
    class var twGreen03:    NSColor { get { return NSColor(webcolor: "#00aa5b") } }
    class var twBlue02:     NSColor { get { return NSColor(webcolor: "#00bccd") } }
    class var twBlue03:     NSColor { get { return NSColor(webcolor: "#0078bf") } }
    class var twGrey:       NSColor { get { return NSColor(webcolor: "#808184") } }


    convenience init(webcolor: NSString)
    {
        var red:   Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(1, 2))).scanHexDouble(&red)
        var green: Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(3, 2))).scanHexDouble(&green)
        var blue:  Double = 0; Scanner(string: "0x"+webcolor.substring(with: NSMakeRange(5, 2))).scanHexDouble(&blue)
        self.init(red: CGFloat(red/256), green: CGFloat(green/256), blue: CGFloat(blue/256), alpha: 1)
    }


    func lighter(_ amount :CGFloat = 0.25) -> NSColor
    {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(_ amount :CGFloat = 0.25) -> NSColor
    {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> NSColor
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
        let deviceColor = self.usingColorSpaceName("NSDeviceRGBColorSpace") 
        deviceColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
    
    
}
